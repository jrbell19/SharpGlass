# SharpGlass Tests

This directory contains all tests for the SharpGlass application using **Swift Testing** (Swift 6's modern testing framework).

## 📚 Documentation

- **[TESTING_GUIDE.md](TESTING_GUIDE.md)** - Comprehensive guide to writing Swift Testing tests
- **[SWIFT_TESTING_QUICK_REF.md](SWIFT_TESTING_QUICK_REF.md)** - Quick reference card for common patterns

## 🧪 Test Files

- **ErrorHandlingTests.swift** - Error handling and robustness tests (Swift Testing ✅)
- **SharpViewModelTests.swift** - ViewModel state and behavior tests (Swift Testing ✅)
- **SharpServiceTests.swift** - Service layer tests (Swift Testing ✅)
- **GaussianSplatTests.swift** - Gaussian splat data tests (Swift Testing ✅)
- **SharpGlassTests.swift** - Example tests (Swift Testing ✅)

## 🚀 Running Tests

### Command Line
```bash
swift test
```

### Xcode
1. Open project in Xcode
2. Press `Cmd+U` to run all tests
3. Click diamond icons to run individual tests

## ✨ Swift Testing vs XCTest

**Use Swift Testing** (recommended):
```swift
import Testing
@testable import SharpGlass

@Suite("My Tests")
struct MyTests {
    @Test("Something works")
    @MainActor
    func something() {
        let vm = SharpViewModel()
        #expect(vm.isProcessing == false)
    }
}
```

**Old XCTest** (legacy):
```swift
import XCTest
@testable import SharpGlass

final class MyTests: XCTestCase {
    @MainActor
    func testSomething() {
        let vm = SharpViewModel()
        XCTAssertFalse(vm.isProcessing)
    }
}
```

## 📝 Writing New Tests

1. Create a new `.swift` file in `Tests/SharpGlassTests/`
2. Import Testing framework: `import Testing`
3. Use `@Suite` to group related tests
4. Use `@Test` for individual test functions
5. Use `#expect` for assertions
6. Add `@MainActor` for ViewModel/UI tests

See [TESTING_GUIDE.md](TESTING_GUIDE.md) for detailed examples.

## 🎯 Test Coverage

Current test coverage includes:
- ✅ Error handling and robustness
- ✅ ViewModel state management
- ✅ Camera controls
- ✅ Loading overlay behavior
- ✅ Background removal fallback
- ✅ Drag-and-drop functionality
- ✅ Style parameter preservation
- ✅ Gaussian splat data parsing

## 🔄 Migration Status

| File | Framework | Status |
|------|-----------|--------|
| ErrorHandlingTests.swift | Swift Testing | ✅ Migrated |
| SharpViewModelTests.swift | Swift Testing | ✅ Migrated |
| SharpServiceTests.swift | Swift Testing | ✅ Migrated |
| GaussianSplatTests.swift | Swift Testing | ✅ Migrated |
| SharpGlassTests.swift | Swift Testing | ✅ Migrated |

**All tests have been migrated to Swift Testing! 🎉**

## 🐛 Known Issues

- ~~XCTest import fails with Swift Package Manager~~ (Fixed - all tests now use Swift Testing)
- One test failure in `Initial state` test due to gamma default value change (unrelated to framework)

## 📖 Resources

- [Swift Testing Documentation](https://developer.apple.com/documentation/testing)
- [WWDC 2024: Meet Swift Testing](https://developer.apple.com/videos/play/wwdc2024/10179/)
- [Swift Testing GitHub](https://github.com/apple/swift-testing)
