import XCTest
import AppKit
@testable import SharpGlassLibrary

final class InputLogicTests: XCTestCase {
    
    // Regression Test for "Window Drag vs Orbit" Bug
    func testWindowDragIgnored() {
        // Window height 800. Click at Y=790 (Top 10 pixels, assuming bottom-left origin for macOS)
        // Note: InputOverlay logic uses `location.y > window.frame.height - 40`
        
        let windowHeight: CGFloat = 800
        let titleBarHeight: CGFloat = 40
        
        // Test Case 1: Click in Title Bar (Should be IGNORED)
        let clickY_TitleBar = windowHeight - 10
        let ignoreTitleBar = shouldIgnoreEvent(y: clickY_TitleBar, windowHeight: windowHeight, titleBarHeight: titleBarHeight)
        XCTAssertTrue(ignoreTitleBar, "Events in title bar (top 40px) should be ignored to allow window dragging")
        
        // Test Case 2: Click in Content Area (Should be ACCEPTED)
        let clickY_Content = windowHeight - 50
        let ignoreContent = shouldIgnoreEvent(y: clickY_Content, windowHeight: windowHeight, titleBarHeight: titleBarHeight)
        XCTAssertFalse(ignoreContent, "Events in content area should NOT be ignored")
    }
    
    // Helper replicating InputOverlay logic logic for unit testing
    private func shouldIgnoreEvent(y: CGFloat, windowHeight: CGFloat, titleBarHeight: CGFloat) -> Bool {
        return y > windowHeight - titleBarHeight
    }
}
