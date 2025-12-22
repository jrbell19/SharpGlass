import Testing
import Foundation
@testable import SharpGlassLibrary

@Suite("Gaussian Splat Tests")
struct GaussianSplatTests {
    
    @Test("Valid minimal PLY")
    @MainActor
    func validMinimalPLY() throws {
        let header = """
        ply
        format binary_little_endian 1.0
        element vertex 2
        property float x
        property float y
        property float z
        property float f_dc_0
        property float f_dc_1
        property float f_dc_2
        property float opacity
        property float scale_0
        property float scale_1
        property float scale_2
        property float rot_0
        property float rot_1
        property float rot_2
        property float rot_3
        end_header
        """
        
        var data = header.data(using: .utf8)!
        
        // Add 2 vertices (14 floats each = 56 bytes per vertex)
        for _ in 0..<2 {
            for v in 0..<14 {
                let val = Float(v)
                let bytes = withUnsafeBytes(of: val) { Data($0) }
                data.append(bytes)
            }
        }
        
        let splats = try GaussianSplatData(data: data)
        #expect(splats.pointCount == 2)
        #expect(splats.positions[0].x == 0.0)
        #expect(splats.positions[1].x == 0.0)
        #expect(splats.positions[0].z == 2.0)
        let expectedOpacity = Float(1.0 / (1.0 + exp(-6.0)))
        #expect(abs(splats.opacities[0] - expectedOpacity) < 0.0001)
    }
    
    @Test("Missing property PLY")
    @MainActor
    func missingPropertyPLY() throws {
        let header = """
        ply
        format binary_little_endian 1.0
        element vertex 1
        property float x
        property float y
        end_header
        """
        
        let data = header.data(using: .utf8)!
        
        #expect(throws: Error.self) {
            try GaussianSplatData(data: data)
        }
        // Should fail because z is missing for SIMD3<Float> positions
    }
    
    @Test("Corrupt data short PLY")
    @MainActor
    func corruptDataShortPLY() throws {
        let header = """
        ply
        format binary_little_endian 1.0
        element vertex 10
        property float x
        property float y
        property float z
        property float opacity
        end_header
        """
        
        var data = header.data(using: .utf8)!
        // Only add 1 vertex worth of data
        for _ in 0..<4 {
            let val = Float(1.0)
            data.append(withUnsafeBytes(of: val) { Data($0) })
        }
        
        #expect(throws: Error.self) {
            try GaussianSplatData(data: data)
        }
    }
    
    @Test("Packed heuristic PLY")
    @MainActor
    func packedHeuristicPLY() throws {
        // Test the case where actualStride < headerStride but matches the 56-byte packed set
        let header = """
        ply
        format binary_little_endian 1.0
        element vertex 1
        property float x
        property float y
        property float z
        property float f_dc_0
        property float f_dc_1
        property float f_dc_2
        property float f_rest_0
        property float f_rest_1
        property float opacity
        property float scale_0
        property float scale_1
        property float scale_2
        property float rot_0
        property float rot_1
        property float rot_2
        property float rot_3
        end_header
        """
        // Header implies more properties (f_rest_0, 1) but we give 56 bytes
        var data = header.data(using: .utf8)!
        for v in 0..<14 {
            let val = Float(v)
            data.append(withUnsafeBytes(of: val) { Data($0) })
        }
        
        // This should trigger the "Packed Heuristic" in parseBinaryPLY
        let splats = try GaussianSplatData(data: data)
        #expect(splats.pointCount == 1)
    }

    @Test("PLY Generation Header Check")
    @MainActor
    func plyGenerationHeaderCheck() throws {
        let positions: [SIMD3<Float>] = [SIMD3(0, 0, 0)]
        let colors: [SIMD3<Float>] = [SIMD3(1, 1, 1)]
        let opacities: [Float] = [1.0]
        let scales: [SIMD3<Float>] = [SIMD3(1, 1, 1)]
        let rotations: [SIMD4<Float>] = [SIMD4(0, 0, 0, 1)]
        
        let data = try GaussianSplatData.createPLYData(
            positions: positions,
            colors: colors,
            opacities: opacities,
            scales: scales,
            rotations: rotations
        )
        
        // Finder crash fix check: There should be EXACTLY ONE newline after end_header
        // and BEFORE the binary data starts.
        
        // Find "end_header" in the raw data
        let endHeaderData = "end_header".data(using: .utf8)!
        if let range = data.range(of: endHeaderData) {
            let afterOffset = range.upperBound
            let charAfter = data[afterOffset] // Should be \n (10)
            #expect(charAfter == 10)
            
            let charAfterAfter = data[afterOffset + 1]
            #expect(charAfterAfter != 10) // Should NOT be another \n
        } else {
            Issue.record("Could not find end_header in generated data")
        }
    }

    @Test("Pruned Splat Data Integrity")
    @MainActor
    func prunedSplatDataIntegrity() throws {
        // Create a 10 point splat
        let positions = (0..<10).map { i in SIMD3<Float>(Float(i), 0, 0) }
        let colors = (0..<10).map { _ in SIMD3<Float>(1, 1, 1) }
        let opacities = (0..<10).map { i in Float(i) / 10.0 }
        let scales = (0..<10).map { _ in SIMD3<Float>(1, 1, 1) }
        let rotations = (0..<10).map { _ in SIMD4<Float>(0, 0, 0, 1)}
        
        let data = try GaussianSplatData.createPLYData(
            positions: positions,
            colors: colors,
            opacities: opacities,
            scales: scales,
            rotations: rotations
        )
        
        let splats = try GaussianSplatData(data: data)
        #expect(splats.pointCount == 10)
        
        // Prune to 5 points
        let pruned = splats.pruned(maxCount: 5)
        #expect(pruned.pointCount == 5)
        #expect(!(pruned.plyData?.isEmpty ?? true))
        
        // Verify we can re-parse the pruned data
        let reParsed = try GaussianSplatData(data: pruned.plyData ?? Data())
        #expect(reParsed.pointCount == 5)
        #expect(reParsed.positions.count == 5)
    }
    @Test("Black Splat Prevention")
    func testBlackSplatPrevention() throws {
        // Regression: Merged splats were appearing black because SH coefficients were zeroed or parsed incorrectly.
        // We ensure that valid RGB inputs produce valid SH DC components.
        
        let positions: [SIMD3<Float>] = [.zero]
        let redColor = SIMD3<Float>(1.0, 0.0, 0.0) // Pure Red
        let colors: [SIMD3<Float>] = [redColor]
        let opacities: [Float] = [1.0]
        let scales: [SIMD3<Float>] = [.one]
        let rotations: [SIMD4<Float>] = [.init(0,0,0,1)]
        
        // 1. Create PLY
        let data = try GaussianSplatData.createPLYData(
            positions: positions,
            colors: colors,
            opacities: opacities,
            scales: scales,
            rotations: rotations
        )
        
        // 2. Parse back using public initializer
        let result = try GaussianSplatData(data: data)
        
        #expect(result.colors.count == 1)
        
        // 3. Verify Color is NOT black
        let parsedColor = result.colors[0]
        
        // SH conversion is approximate, but should be close to Red
        // Allow for some floating point drift from f_dc conversion
        #expect(parsedColor.x > 0.8, "Red component should be preserved")
        #expect(parsedColor.y < 0.2, "Green component should remain low")
        #expect(parsedColor.z < 0.2, "Blue component should remain low")
    }
}
