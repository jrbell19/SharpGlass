import Testing
import SwiftUI
@testable import SharpGlass

@Suite("Sharp ViewModel Tests")
struct SharpViewModelTests {
    
    @Test("Initial state")
    @MainActor
    func initialState() {
        let vm = SharpViewModel()
        #expect(vm.exposure == 0.0)
        #expect(vm.gamma == 1.0)
        #expect(vm.saturation == 1.0)
        #expect(vm.cameraMode == .orbit)
        #expect(!vm.isProcessing)
    }
    
    @Test("Style sync")
    @MainActor
    func styleSync() {
        let vm = SharpViewModel()
        
        vm.exposure = 1.5
        vm.gamma = 0.8
        vm.saturation = 2.0
        vm.splatScale = 1.2
        
        // These are @Published, so we trust SwiftUI's binding,
        // but let's verify if there were any derived transformations (there aren't yet).
        #expect(vm.exposure == 1.5)
        #expect(vm.gamma == 0.8)
        #expect(vm.saturation == 2.0)
    }
    
    @Test("Camera mode transitions")
    @MainActor
    func cameraModeTransitions() {
        let vm = SharpViewModel()
        
        // Switch to Fly mode
        vm.cameraMode = .fly
        #expect(vm.cameraMode == .fly)
        
        // Verify default fly camera position
        #expect(vm.targetFlyEye.z == -5.0)
        #expect(vm.targetFlyYaw == 0.0)
    }
    
    @Test("Error truncation")
    @MainActor
    func errorTruncation() {
        let vm = SharpViewModel()
        let longError = String(repeating: "A", count: 1000)
        vm.errorMessage = longError
        
        // Truncation happens in the View (MainView), 
        #expect(vm.errorMessage?.count == 1000)
    }

    @Test("Focus on scene")
    @MainActor
    func focusOnScene() {
        let vm = SharpViewModel()
        vm.targetOrbitTheta = 0.5
        vm.targetOrbitDistance = 10.0
        
        vm.focusOnScene()
        
        #expect(vm.targetOrbitTarget == SIMD3<Double>(0, 0, 0))
        #expect(vm.targetOrbitDistance == 5.0)
        #expect(vm.targetOrbitTheta == .pi)
        #expect(vm.targetOrbitPhi == 0)
    }
    
    @Test("Snap camera")
    @MainActor
    func snapCamera() {
        let vm = SharpViewModel()
        vm.snapCamera(theta: 1.0, phi: 0.5, distance: 8.0)
        
        #expect(vm.targetOrbitTheta == 1.0)
        #expect(vm.targetOrbitPhi == 0.5)
        #expect(vm.targetOrbitDistance == 8.0)
    }
    
    @Test("Navigation state")
    @MainActor
    func navigationState() {
        let vm = SharpViewModel()
        #expect(!vm.isNavigating)
        
        // Simulate navigation start
        vm.isNavigating = true
        #expect(vm.isNavigating)
        
        // Handle drag: Alt + LMB (button 0) should trigger orbit change
        let initialTheta = vm.targetOrbitTheta
        vm.handleDrag(delta: CGSize(width: 100, height: 0), button: 0, modifiers: .option)
        #expect(vm.targetOrbitTheta != initialTheta)
        
        // Handle drag: Alt + MMB (button 2) should trigger pan
        let initialTarget = vm.targetOrbitTarget
        vm.handleDrag(delta: CGSize(width: 10, height: 10), button: 2, modifiers: .option)
        #expect(vm.targetOrbitTarget.x != initialTarget.x)
    }

    // --- Camera Math Tests (Consolidated) ---

    @Test("Front view matrix")
    func frontViewMatrix() {
        let cam = CameraPosition(x: 0, y: 0, z: 5, target: SIMD3<Double>(0, 0, 0))
        let matrix = cam.viewMatrix()
        #expect(abs(matrix.columns.0.x - 1.0) < 0.0001)
        #expect(abs(matrix.columns.1.y - 1.0) < 0.0001)
        #expect(abs(matrix.columns.2.z - 1.0) < 0.0001)
        #expect(abs(matrix.columns.3.z - (-5.0)) < 0.0001)
    }
    
    @Test("Top view matrix")
    func topViewMatrix() {
        let cam = CameraPosition(x: 0, y: 5, z: 0.001, target: SIMD3<Double>(0, 0, 0))
        let matrix = cam.viewMatrix()
        #expect(!matrix.columns.0.x.isNaN)
        #expect(!matrix.columns.3.z.isNaN)
    }

    @Test("Camera target logic")
    func cameraTargetLogic() {
        let cam = CameraPosition(x: 1, y: 2, z: 3)
        let matrixWithDefaultTarget = cam.viewMatrix()
        #expect(abs(matrixWithDefaultTarget.columns.2.z - 1.0) < 0.0001)
    }
}
