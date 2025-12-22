import XCTest
import AppKit
@testable import SharpGlassLibrary

final class ImageProcessingTests: XCTestCase {
    
    // Path to the test images directory provided by the user
    let imagesDir = URL(fileURLWithPath: #file)
        .deletingLastPathComponent() // SharpGlassTests
        .deletingLastPathComponent() // Tests
        .appendingPathComponent("images")
    
    func testLoadProvidedImages() throws {
        // Verify directory exists
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: imagesDir.path, isDirectory: &isDir), isDir.boolValue else {
            print("Warning: Test images directory not found at \(imagesDir.path). Skipping test.")
            return
        }
        
        let contents = try FileManager.default.contentsOfDirectory(at: imagesDir, includingPropertiesForKeys: nil)
        let imageFiles = contents.filter { 
            ["jpg", "jpeg", "png", "heic"].contains($0.pathExtension.lowercased()) 
        }
        
        print("Found \(imageFiles.count) test images.")
        
        for imageURL in imageFiles {
            print("Testing load of: \(imageURL.lastPathComponent)")
            
            // 1. Test basic NSImage loading
            guard let image = NSImage(contentsOf: imageURL) else {
                XCTFail("Failed to load image at \(imageURL.path)")
                continue
            }
            
            XCTAssertTrue(image.isValid, "Image \(imageURL.lastPathComponent) is invalid")
            XCTAssertGreaterThan(image.size.width, 0)
            XCTAssertGreaterThan(image.size.height, 0)
            
            // 2. Test Format Validity for ml-sharp (RGB conversion)
            // ml-sharp expects Images to be convertible to CGImage and have valid color data
            var rect = CGRect(origin: .zero, size: image.size)
            guard let cgImage = image.cgImage(forProposedRect: &rect, context: nil, hints: nil) else {
                XCTFail("Failed to convert \(imageURL.lastPathComponent) to CGImage")
                continue
            }
            
            XCTAssertNotNil(cgImage)
        }
    }
}
