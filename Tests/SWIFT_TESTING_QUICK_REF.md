# Swift Testing Quick Reference

## Import
```swift
import Testing
@testable import SharpGlass
```

## Test Structure
```swift
@Suite("Suite Name")
struct MyTests {
    @Test("Test description")
    func testName() {
        #expect(condition)
    }
}
```

## Assertions Cheat Sheet

| What you want to test | Swift Testing |
|----------------------|---------------|
| Equality | `#expect(a == b)` |
| Inequality | `#expect(a != b)` |
| True | `#expect(condition)` |
| False | `#expect(!condition)` |
| Nil | `#expect(value == nil)` |
| Not nil | `#expect(value != nil)` |
| Greater than | `#expect(a > b)` |
| Less than | `#expect(a < b)` |
| Contains | `#expect(array.contains(item))` |
| Throws error | `#expect(throws: Error.self) { try code() }` |
| Custom message | `#expect(condition, "Message")` |

## Common Attributes

```swift
@Test                           // Basic test
@Test("Description")            // Test with description
@MainActor                      // Run on main actor (for UI/ViewModel)
@Suite("Name")                  // Group tests
.disabled("Reason")             // Temporarily disable
.bug("ID")                      // Known issue
```

## Examples

### Basic Test
```swift
@Test("Addition works")
func addition() {
    #expect(2 + 2 == 4)
}
```

### ViewModel Test
```swift
@Test("ViewModel state")
@MainActor
func viewModelState() {
    let vm = SharpViewModel()
    #expect(!vm.isProcessing)
}
```

### Async Test
```swift
@Test("Async operation")
func asyncOp() async {
    let result = await fetchData()
    #expect(result != nil)
}
```

### Parameterized Test
```swift
@Test("Multiple values", arguments: [1, 2, 3])
func multipleValues(n: Int) {
    #expect(n > 0)
}
```

## Migration from XCTest

| XCTest | Swift Testing |
|--------|---------------|
| `import XCTest` | `import Testing` |
| `class Tests: XCTestCase` | `struct Tests` |
| `func testX()` | `@Test func x()` |
| `XCTAssertEqual(a, b)` | `#expect(a == b)` |
| `XCTAssertTrue(x)` | `#expect(x)` |
| `XCTAssertFalse(x)` | `#expect(!x)` |
| `XCTAssertNil(x)` | `#expect(x == nil)` |
| `XCTAssertNotNil(x)` | `#expect(x != nil)` |
| `XCTAssertGreaterThan(a, b)` | `#expect(a > b)` |
| `XCTAssertLessThan(a, b)` | `#expect(a < b)` |
| `XCTAssertThrowsError` | `#expect(throws:)` |

## Run Tests
```bash
swift test
```
