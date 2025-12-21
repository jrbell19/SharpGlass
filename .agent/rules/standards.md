# SharpGlass Agent Standards

All AI agents working on this project must adhere to the following standards of excellence.

## 1. Requirement: Mandatory Unit Testing
A feature or bug fix is NOT considered "done" until it is accompanied by passing unit tests.
- **New Functionality**: Must include comprehensive unit tests covering happy paths, edge cases, and error conditions.
- **Refactoring**: Existing tests must pass, and new tests should be added if the internal logic changes significantly.
- **Bug Fixes**: A regression test must be added to ensure the bug does not reappear.

## 2. Standard of Excellence
- **Code Quality**: Write clean, idiomatic Swift code that follows the project's established patterns.
- **Documentation**: All public APIs and complex logic must be documented with clear, concise comments.
- **Performance**: Be mindful of resource usage, especially in the rendering and processing pipelines.
- **Reliability**: Prioritize robust error handling over silent failures.

## 3. Definition of "Done"
1. Code implementation is complete.
2. Unit tests are written and located in the `Tests/` directory.
3. All tests (new and existing) pass successfully via `swift test`.
4. Artifacts (`task.md`, `walkthrough.md`) are updated to reflect the changes and test results.
