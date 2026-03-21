# Test Guidelines

## Before Writing Tests

- Read 2-3 existing test files in the same directory or feature to learn conventions, helpers, and factories
- Reuse existing test helpers — do not create new ones when equivalents exist

## Expected Values

Expected values must be independent of production code.

❌ `assert result == width + height + PADDING * 2`  (replicates production formula)
✅ `assert result == 524`  (hardcoded from manual calculation)

Rationale: If the production formula has a bug, the test copies the same bug.

## Mocking

Mock only external boundaries (API calls, network, file I/O, timers, external services).

Do NOT mock:
- Simple predicates or type checks
- Internal pure functions or utility functions
- Functions that no test case exercises
- Objects that can be constructed with real implementations

## Prohibited Patterns

- Testing what the compiler or type system already guarantees (e.g., return types, interface conformance)
- Testing implementation details (internal state shape, private method calls)
- Using loose assertions when a specific value is expected
- Creating mocks/stubs for modules that are never called in the test scenario

## Structure

- Follow Arrange / Act / Assert with blank lines separating each phase
- One behavior per test case
- Group tests by function/method or scenario
- Test name describes expected behavior and condition
