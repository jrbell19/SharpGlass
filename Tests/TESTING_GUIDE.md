# Swift Testing Guide for SharpGlass

## Overview

SharpGlass uses **Swift Testing** (introduced in Swift 6) instead of the legacy XCTest framework. This guide explains how to write tests using the modern Swift Testing API.

## Why Swift Testing?

- **Modern syntax**: Uses `#expect` instead of `XCTAssert*`
- **Better error messages**: More descriptive test failures
- **Parameterized tests**: Easy to test multiple inputs
- **Async/await native**: Built for modern Swift concurrency
- **Swift 6 compatibility**: Designed for the latest Swift features

## Basic Test Structure

### Old Way (XCTest) ❌
```swift
import XCTest
@testable import SharpGlass

final class MyTests: XCTestCase {
    func testSomething() {
        let value = 42
        XCTAssertEqual(value, 42)
    }
}
```

### New Way (Swift Testing) ✅
```swift
import Testing
@testable import SharpGlass

@Suite("My Test Suite")
struct MyTests {
    @Test("Something works correctly")
    func something() {
        let value = 42
        #expect(value == 42)
    }
}
```

## Key Differences

| XCTest | Swift Testing |
|--------|---------------|
| `import XCTest` | `import Testing` |
| `class MyTests: XCTestCase` | `struct MyTests` |
| `func testSomething()` | `@Test func something()` |
| `XCTAssertEqual(a, b)` | `#expect(a == b)` |
| `XCTAssertTrue(condition)` | `#expect(condition)` |
| `XCTAssertFalse(condition)` | `#expect(!condition)` |
| `XCTAssertNil(value)` | `#expect(value == nil)` |
| `XCTAssertNotNil(value)` | `#expect(value != nil)` |
| `XCTAssertThrowsError` | `#expect(throws:)` |

## Common Patterns

### 1. Basic Assertions

```swift
@Test("Values are equal")
func valuesAreEqual() {
    #expect(2 + 2 == 4)
    #expect("hello" == "hello")
}
```

### 2. Nil Checks

```swift
@Test("Optional handling")
func optionalHandling() {
    let value: String? = "test"
    #expect(value != nil)
    #expect(value == "test")
    
    let empty: String? = nil
    #expect(empty == nil)
}
```

### 3. Boolean Conditions

```swift
@Test("Boolean checks")
func booleanChecks() {
    let isValid = true
    #expect(isValid)
    #expect(!false)
}
```

### 4. Custom Messages

```swift
@Test("Custom error messages")
func customMessages() {
    let count = 5
    #expect(count > 0, "Count should be positive")
}
```

### 5. MainActor Tests

```swift
@Test("UI state updates")
@MainActor
func uiStateUpdates() {
    let vm = SharpViewModel()
    vm.isProcessing = true
    #expect(vm.isProcessing)
}
```

### 6. Async Tests

```swift
@Test("Async operations")
func asyncOperations() async {
    let result = await someAsyncFunction()
    #expect(result != nil)
}
```

### 7. Test Suites

```swift
@Suite("Error Handling")
struct ErrorHandlingTests {
    @Test("Error message is set")
    func errorMessageSet() {
        // test code
    }
    
    @Test("Error message is cleared")
    func errorMessageCleared() {
        // test code
    }
}
```

### 8. Parameterized Tests

```swift
@Test("Multiple inputs", arguments: [1, 2, 3, 4, 5])
func multipleInputs(value: Int) {
    #expect(value > 0)
}
```

### 9. Expected Failures

```swift
@Test("Known issue", .bug("JIRA-123"))
func knownIssue() {
    // Test that's expected to fail
}
```

### 10. Disabled Tests

```swift
@Test("Temporarily disabled", .disabled("Waiting for API fix"))
func temporarilyDisabled() {
    // Test that's temporarily disabled
}
```

## Testing ViewModel State

```swift
@Suite("ViewModel Tests")
struct ViewModelTests {
    @Test("Initial state is correct")
    @MainActor
    func initialState() {
        let vm = SharpViewModel()
        #expect(vm.exposure == 0.0)
        #expect(vm.gamma == 1.0)
        #expect(!vm.isProcessing)
    }
    
    @Test("State updates correctly")
    @MainActor
    func stateUpdates() {
        let vm = SharpViewModel()
        vm.exposure = 1.5
        #expect(vm.exposure == 1.5)
    }
}
```

## Testing Error Handling

```swift
@Suite("Error Handling")
struct ErrorTests {
    @Test("Error message is set on failure")
    @MainActor
    func errorMessageOnFailure() {
        let vm = SharpViewModel()
        vm.errorMessage = "Test error"
        #expect(vm.errorMessage != nil)
        #expect(vm.errorMessage == "Test error")
    }
    
    @Test("Processing stops on error")
    @MainActor
    func processingStopsOnError() {
        let vm = SharpViewModel()
        vm.isProcessing = true
        vm.errorMessage = "Error occurred"
        vm.isProcessing = false
        
        #expect(!vm.isProcessing)
        #expect(vm.errorMessage != nil)
    }
}
```

## Testing Async Operations

```swift
@Suite("Async Operations")
struct AsyncTests {
    @Test("Async function completes")
    func asyncCompletion() async throws {
        let service = SharpService()
        // Test async operations
        #expect(service != nil)
    }
}
```

## Running Tests

### Command Line
```bash
swift test
```

### Xcode
1. Open project in Xcode
2. Press `Cmd+U` to run all tests
3. Click the diamond icon next to individual tests to run them

## Best Practices

1. **Use descriptive test names**: `@Test("Error message is cleared on new generation")`
2. **Group related tests**: Use `@Suite` to organize tests
3. **Keep tests focused**: One concept per test
4. **Use `@MainActor`**: For testing UI/ViewModel state
5. **Test edge cases**: nil values, empty arrays, boundary conditions
6. **Avoid test interdependence**: Each test should be independent
7. **Use meaningful assertions**: Add custom messages when helpful

## Common Gotchas

### 1. Don't forget `@MainActor`
```swift
// ❌ Wrong - will crash if accessing @Published properties
@Test func viewModelTest() {
    let vm = SharpViewModel()
    vm.isProcessing = true
}

// ✅ Correct
@Test @MainActor func viewModelTest() {
    let vm = SharpViewModel()
    vm.isProcessing = true
}
```

### 2. Use `#expect` not `XCTAssert`
```swift
// ❌ Wrong - XCTest syntax
#expect(value == 42)
XCTAssertEqual(value, 42)

// ✅ Correct - Swift Testing syntax
#expect(value == 42)
```

### 3. Import `Testing` not `XCTest`
```swift
// ❌ Wrong
import XCTest

// ✅ Correct
import Testing
```

## Migration from XCTest

If you have existing XCTest files, here's how to migrate:

1. **Change import**: `import XCTest` → `import Testing`
2. **Change class to struct**: `class MyTests: XCTestCase` → `struct MyTests`
3. **Add @Test attribute**: `func testSomething()` → `@Test func something()`
4. **Replace assertions**: `XCTAssertEqual(a, b)` → `#expect(a == b)`
5. **Add @Suite**: `@Suite("Test Suite Name")`
6. **Keep @MainActor**: If testing UI/ViewModel

## Example: Complete Test File

```swift
import Testing
import SwiftUI
@testable import SharpGlass

@Suite("Error Handling and Robustness")
struct ErrorHandlingTests {
    
    @Test("Error message is set when generation fails")
    @MainActor
    func errorMessageSetWhenGenerationFails() {
        let vm = SharpViewModel()
        vm.errorMessage = "Test error message"
        
        #expect(vm.errorMessage != nil)
        #expect(vm.errorMessage == "Test error message")
    }
    
    @Test("Processing flag is set correctly")
    @MainActor
    func processingFlagSetCorrectly() {
        let vm = SharpViewModel()
        
        #expect(!vm.isProcessing, "Should not be processing initially")
        
        vm.isProcessing = true
        #expect(vm.isProcessing)
        
        vm.isProcessing = false
        #expect(!vm.isProcessing)
    }
    
    @Test("cleanBackground defaults to false")
    @MainActor
    func cleanBackgroundDefaultValue() {
        let vm = SharpViewModel()
        #expect(!vm.cleanBackground, "cleanBackground should be disabled by default")
    }
}
```

## Resources

- [Swift Testing Documentation](https://developer.apple.com/documentation/testing)
- [WWDC 2024: Meet Swift Testing](https://developer.apple.com/videos/play/wwdc2024/10179/)
- [Swift Testing GitHub](https://github.com/apple/swift-testing)

## Questions?

If you encounter issues with Swift Testing:
1. Ensure you're using Swift 6.0 or later
2. Check that `import Testing` is at the top of your test file
3. Verify `@MainActor` is used for ViewModel/UI tests
4. Make sure test functions are marked with `@Test`
