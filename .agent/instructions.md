# Agent Instructions for SharpGlass

## Testing Framework

**CRITICAL: All tests MUST use Swift Testing framework, NOT XCTest.**

### When Writing Tests

1. **Always use Swift Testing**:
   ```swift
   import Testing
   @testable import SharpGlass
   
   @Suite("Test Suite Name")
   struct MyTests {
       @Test("Test description")
       @MainActor  // For ViewModel/UI tests
       func testName() {
           #expect(condition)
       }
   }
   ```

2. **Never use XCTest**:
   - ❌ Do NOT use `import XCTest`
   - ❌ Do NOT use `XCTestCase` classes
   - ❌ Do NOT use `XCTAssert*` assertions
   - ❌ Do NOT prefix test functions with `test`

3. **Quick Reference**:
   - See `Tests/SWIFT_TESTING_QUICK_REF.md` for assertion syntax
   - Use `#expect(a == b)` instead of `XCTAssertEqual(a, b)`
   - Use `#expect(condition)` instead of `XCTAssertTrue(condition)`
   - Use `#expect(throws: Error.self) { }` instead of `XCTAssertThrowsError`

### Migration from XCTest

If you encounter existing XCTest files, convert them to Swift Testing:

1. Replace `import XCTest` with `import Testing`
2. Change `class XTests: XCTestCase` to `@Suite("X Tests") struct XTests`
3. Add `@Test("description")` to each test function
4. Remove `test` prefix from function names
5. Replace all `XCTAssert*` with `#expect()`
6. Add `import Foundation` if using `Data`, `Date`, or other Foundation types

## Project Structure

- Main source: `Sources/SharpGlass/`
- Tests: `Tests/SharpGlassTests/`
- Test documentation: `Tests/SWIFT_TESTING_QUICK_REF.md`

## Code Style

- Use Swift 6 concurrency features (`async/await`, `@MainActor`)
- Mark UI/ViewModel code with `@MainActor`
- Use `Sendable` for types passed across concurrency boundaries
- Prefer structs over classes when possible
