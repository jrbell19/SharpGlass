import XCTest
import simd
@testable import SharpGlassLibrary

final class MathUtilsTests: XCTestCase {
    
    func testDegreesToRadians() {
        let deg: Float = 180.0
        let rad = MathUtils.degreesToRadians(deg)
        XCTAssertEqual(rad, .pi, accuracy: 0.0001)
        
        XCTAssertEqual(MathUtils.degreesToRadians(0), 0, accuracy: 0.0001)
        XCTAssertEqual(MathUtils.degreesToRadians(90), .pi / 2, accuracy: 0.0001)
    }
    
    func testLookAtMatrix() {
        let eye = vector_float3(0, 0, 0)
        let target = vector_float3(0, 0, -1) // Looking forward (-Z)
        let up = vector_float3(0, 1, 0)
        
        let viewMatrix = MathUtils.matrix_look_at_right_hand(eye: eye, target: target, up: up)
        
        // Identity matrix is expected if we look down -Z with Y-up from origin
        let expected = matrix_identity_float4x4
        
        // Comparing columns
        for c in 0..<4 {
            for r in 0..<4 {
                XCTAssertEqual(viewMatrix[c][r], expected[c][r], accuracy: 0.0001, "Mismatch at col \(c), row \(r)")
            }
        }
    }
    
    func testLookAtMatrixTranslation() {
        let eye = vector_float3(0, 0, 5) // Back 5 units
        let target = vector_float3(0, 0, 0) // Looking at origin
        let up = vector_float3(0, 1, 0)
        
        let viewMatrix = MathUtils.matrix_look_at_right_hand(eye: eye, target: target, up: up)
        
        // Should be Identity but translated -5 in Z?
        // View Matrix moves the WORLD, not the camera.
        // If camera is at (0,0,5), the world moves (0,0,-5) to get into view.
        XCTAssertEqual(viewMatrix.columns.3.z, -5.0, accuracy: 0.0001)
    }
    
    func testPerspectiveMatrix() {
        let fov: Float = .pi / 2 // 90deg
        let aspect: Float = 1.0
        let near: Float = 0.1
        let far: Float = 100.0
        
        let proj = MathUtils.makePerspectiveMatrix(fovRadians: fov, aspect: aspect, near: near, far: far)
        
        // Verify scale factors
        // 90deg, aspect 1 => xs = 1, ys = 1
        XCTAssertEqual(proj.columns.0.x, 1.0, accuracy: 0.0001)
        XCTAssertEqual(proj.columns.1.y, 1.0, accuracy: 0.0001)
        
        // Verify Z mapping
        // Z_clip = Z_view * zs
        // zs = far / (near - far) = 100 / (0.1 - 100) = 100 / -99.9 approx -1.001
        
        let zs = far / (near - far)
        XCTAssertEqual(proj.columns.2.z, zs, accuracy: 0.0001)
        XCTAssertEqual(proj.columns.2.w, -1.0, accuracy: 0.0001) // Standard W perspective divide
    }
}
