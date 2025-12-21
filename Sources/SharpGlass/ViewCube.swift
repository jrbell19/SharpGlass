import SwiftUI
import simd

struct ViewCube: View {
    let rotation: matrix_float4x4
    var onSnap: (_ theta: Double, _ phi: Double, _ distance: Double) -> Void
    
    // Face definitions (Normal, Label)
    private let faces: [(SIMD3<Float>, String)] = [
        (SIMD3(0, 0, 1), "BACK"),
        (SIMD3(0, 0, -1), "FRONT"),
        (SIMD3(1, 0, 0), "RIGHT"),
        (SIMD3(-1, 0, 0), "LEFT"),
        (SIMD3(0, 1, 0), "TOP"),
        (SIMD3(0, -1, 0), "BOTTOM")
    ]
    
    var body: some View {
        ZStack {
            // Background ring (Subtle)
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                .frame(width: 80, height: 80)
            
            // The Cube
            ZStack {
                ForEach(0..<faces.count, id: \.self) { i in
                    FaceView(normal: faces[i].0, label: faces[i].1, rotation: rotation) {
                        snapToFace(faces[i].0)
                    }
                }
            }
        }
        .frame(width: 100, height: 100)
    }
    
    private func snapToFace(_ normal: SIMD3<Float>) {
        // Map normal to Euler targets
        if normal == SIMD3(0, 0, 1) { onSnap(0, 0, 5.0) }      // Back (-Z starts front, so +Z is back)
        else if normal == SIMD3(0, 0, -1) { onSnap(.pi, 0, 5.0) }   // Front
        else if normal == SIMD3(1, 0, 0) { onSnap(.pi/2, 0, 5.0) } // Right
        else if normal == SIMD3(-1, 0, 0) { onSnap(-.pi/2, 0, 5.0) } // Left
        else if normal == SIMD3(0, 1, 0) { onSnap(0, .pi/2, 5.0) } // Top (theta irrelevant at poles but keep stable)
        else if normal == SIMD3(0, -1, 0) { onSnap(0, -.pi/2, 5.0) } // Bottom
    }
}

struct FaceView: View {
    let normal: SIMD3<Float>
    let label: String
    let rotation: matrix_float4x4
    let action: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        let rotatedNormal = rotation * SIMD4<Float>(normal.x, normal.y, normal.z, 0)
        let zPos = rotatedNormal.z
        let opacity = Double(max(0, zPos + 0.2)) // Only show front-facing
        
        Button(action: action) {
            Text(label)
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 2)
                        .fill(isHovering ? Color.yellow.opacity(0.8) : Color.white.opacity(0.1))
                        .overlay(RoundedRectangle(cornerRadius: 2).stroke(Color.white.opacity(0.2), lineWidth: 1))
                )
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
        .scaleEffect(opacity > 0.1 ? 1.0 : 0.8)
        .opacity(opacity)
        // Manual 3D placement based on rotated normal
        .offset(x: CGFloat(rotatedNormal.x * 30), y: CGFloat(-rotatedNormal.y * 30))
        .zIndex(Double(zPos))
    }
}

extension matrix_float4x4 {
    static func * (lhs: matrix_float4x4, rhs: SIMD4<Float>) -> SIMD4<Float> {
        return SIMD4<Float>(
            lhs.columns.0.x * rhs.x + lhs.columns.1.x * rhs.y + lhs.columns.2.x * rhs.z + lhs.columns.3.x * rhs.w,
            lhs.columns.0.y * rhs.x + lhs.columns.1.y * rhs.y + lhs.columns.2.y * rhs.z + lhs.columns.3.y * rhs.w,
            lhs.columns.0.z * rhs.x + lhs.columns.1.z * rhs.y + lhs.columns.2.z * rhs.z + lhs.columns.3.z * rhs.w,
            lhs.columns.0.w * rhs.x + lhs.columns.1.w * rhs.y + lhs.columns.2.w * rhs.z + lhs.columns.3.w * rhs.w
        )
    }
}
