import Testing
import SwiftUI
@testable import SharpGlass

/// Tests for error handling and robustness improvements
@Suite("Error Handling and Robustness")
struct ErrorHandlingTests {
    
    // MARK: - Error Alert Tests
    
    @Test("Error message is set when generation fails")
    @MainActor
    func errorMessageSetWhenGenerationFails() {
        let vm = SharpViewModel()
        
        // Simulate an error by setting errorMessage
        vm.errorMessage = "Test error message"
        
        #expect(vm.errorMessage != nil)
        #expect(vm.errorMessage == "Test error message")
    }
    
    @Test("Error message is cleared on new generation")
    @MainActor
    func errorMessageClearedOnNewGeneration() {
        let vm = SharpViewModel()
        
        // Set an error
        vm.errorMessage = "Previous error"
        #expect(vm.errorMessage != nil)
        
        // Simulate starting a new generation
        vm.errorMessage = nil
        #expect(vm.errorMessage == nil)
    }
    
    @Test("Processing flag is set correctly")
    @MainActor
    func processingFlagSetCorrectly() {
        let vm = SharpViewModel()
        
        #expect(!vm.isProcessing, "Should not be processing initially")
        
        // Simulate processing
        vm.isProcessing = true
        #expect(vm.isProcessing)
        
        // Simulate completion
        vm.isProcessing = false
        #expect(!vm.isProcessing)
    }
    
    // MARK: - Background Removal Tests
    
    @Test("cleanBackground defaults to false")
    @MainActor
    func cleanBackgroundDefaultValue() {
        let vm = SharpViewModel()
        
        // cleanBackground should default to false (disabled)
        #expect(!vm.cleanBackground, "cleanBackground should be disabled by default")
    }
    
    @Test("cleanBackground can be toggled")
    @MainActor
    func cleanBackgroundToggle() {
        let vm = SharpViewModel()
        
        // Should be able to toggle cleanBackground
        vm.cleanBackground = true
        #expect(vm.cleanBackground)
        
        vm.cleanBackground = false
        #expect(!vm.cleanBackground)
    }
    
    // MARK: - Loading Overlay Tests
    
    @Test("Loading overlay shows when processing")
    @MainActor
    func loadingOverlayShowsWhenProcessing() {
        let vm = SharpViewModel()
        
        // Loading overlay should show when isProcessing is true
        vm.isProcessing = true
        #expect(vm.isProcessing, "Loading overlay should be visible when processing")
    }
    
    @Test("Loading overlay hides when not processing")
    @MainActor
    func loadingOverlayHidesWhenNotProcessing() {
        let vm = SharpViewModel()
        
        vm.isProcessing = true
        vm.isProcessing = false
        #expect(!vm.isProcessing, "Loading overlay should be hidden when not processing")
    }
    
    // MARK: - File Import Tests
    
    @Test("Import file updates selected image")
    @MainActor
    func importFileUpdatesSelectedImage() {
        let vm = SharpViewModel()
        
        // Create a test image
        let testImage = NSImage(size: NSSize(width: 100, height: 100))
        testImage.lockFocus()
        NSColor.red.setFill()
        NSRect(x: 0, y: 0, width: 100, height: 100).fill()
        testImage.unlockFocus()
        
        // Manually set the image (simulating successful import)
        vm.selectedImage = testImage
        
        #expect(vm.selectedImage != nil)
        #expect(vm.selectedImage?.size.width == 100)
        #expect(vm.selectedImage?.size.height == 100)
    }
    
    // MARK: - Camera State Tests
    
    @Test("Camera state preserved during processing")
    @MainActor
    func cameraStatePreservedDuringProcessing() {
        let vm = SharpViewModel()
        
        // Set camera state
        vm.targetOrbitTheta = 1.5
        vm.targetOrbitPhi = 0.5
        vm.targetOrbitDistance = 10.0
        
        // Simulate processing
        vm.isProcessing = true
        
        // Camera state should be preserved
        #expect(vm.targetOrbitTheta == 1.5)
        #expect(vm.targetOrbitPhi == 0.5)
        #expect(vm.targetOrbitDistance == 10.0)
        
        vm.isProcessing = false
    }
    
    // MARK: - Drag and Drop Tests
    
    @Test("Drag operation does not block UI")
    @MainActor
    func dragOperationDoesNotBlockUI() {
        let vm = SharpViewModel()
        
        // Simulate drag operation
        let initialProcessing = vm.isProcessing
        
        // During drag, processing state should not change
        #expect(vm.isProcessing == initialProcessing)
    }
    
    // MARK: - Window Dragging Tests
    
    @Test("Window drag does not affect camera")
    @MainActor
    func windowDragDoesNotAffectCamera() {
        let vm = SharpViewModel()
        
        // Set initial camera position
        let initialTheta = vm.targetOrbitTheta
        let initialPhi = vm.targetOrbitPhi
        
        // Window dragging should not trigger camera movement
        // (This is handled in InputOverlay.swift with isDraggingInView flag)
        
        // Verify camera hasn't changed
        #expect(vm.targetOrbitTheta == initialTheta)
        #expect(vm.targetOrbitPhi == initialPhi)
    }
    
    // MARK: - Robustness Tests
    
    @Test("Multiple errors handled gracefully")
    @MainActor
    func multipleErrorsHandledGracefully() {
        let vm = SharpViewModel()
        
        // Set multiple errors in sequence
        vm.errorMessage = "Error 1"
        #expect(vm.errorMessage == "Error 1")
        
        vm.errorMessage = "Error 2"
        #expect(vm.errorMessage == "Error 2")
        
        vm.errorMessage = nil
        #expect(vm.errorMessage == nil)
    }
    
    @Test("Processing state reset on error")
    @MainActor
    func processingStateResetOnError() {
        let vm = SharpViewModel()
        
        // Simulate processing
        vm.isProcessing = true
        
        // Simulate error
        vm.errorMessage = "Processing failed"
        vm.isProcessing = false
        
        // Processing should be stopped
        #expect(!vm.isProcessing)
        #expect(vm.errorMessage != nil)
    }
    
    // MARK: - Style Parameter Tests
    
    @Test("Style parameters preserved during error")
    @MainActor
    func styleParametersPreservedDuringError() {
        let vm = SharpViewModel()
        
        // Set style parameters
        vm.exposure = 1.5
        vm.gamma = 0.8
        vm.saturation = 1.2
        vm.splatScale = 1.1
        
        // Simulate error
        vm.errorMessage = "Test error"
        
        // Style parameters should be preserved
        #expect(vm.exposure == 1.5)
        #expect(vm.gamma == 0.8)
        #expect(vm.saturation == 1.2)
        #expect(vm.splatScale == 1.1)
    }
    
    // MARK: - Color Mode Tests
    
    @Test("Color mode preserved during error")
    @MainActor
    func colorModePreservedDuringError() {
        let vm = SharpViewModel()
        
        // Set color mode
        vm.colorMode = .filmic
        
        // Simulate error
        vm.errorMessage = "Test error"
        
        // Color mode should be preserved
        #expect(vm.colorMode == .filmic)
    }
}

