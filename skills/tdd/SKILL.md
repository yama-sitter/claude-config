---
name: tdd
description: |
  Implement code using the TDD cycle (Red-Green-Refactor).
  Use when the user requests code changes such as "implement", "fix", "add", "change", or "create".
  Do not use when instructed "no TDD" or "without tests", or when the task is investigation only.
---

# TDD Engine

Fulfill code creation, modification, and fix requests using TDD.

## Preparation

1. **Confirm the specification**

   - If requirements are ambiguous, clarify with AskUserQuestion
   - Understand the specification from CLAUDE.md, README, and existing code

2. **Investigate the environment**
   - Identify existing test directories (tests/, **tests**/, spec/, test/, etc.)
   - Identify the test runner (package.json scripts, pytest.ini, etc.)
   - Check the naming conventions of existing tests

## TDD Cycle

### RED: Write a failing test

- Create a test that defines the expected behavior
- Follow the project's existing test style
- Follow the Test Implementation Rules
- Run the test and confirm it fails (failure is expected since the implementation doesn't exist yet)

### GREEN: Make the test pass

- Add the implementation to make the test pass
- Aim for the "minimum working code" (generic, not hardcoded)
- Confirm all tests (existing + new) pass

### REFACTOR: Improve

- Eliminate duplication, improve readability and maintainability
- Do not change behavior (tests must continue to pass)
- Follow the coding standards in CLAUDE.md

## Test Implementation Rules

- Use clear, descriptive test case names
- Follow the AAA (Arrange-Act-Assert) pattern
- Test boundary values and edge cases
- Each test should focus on a single behavior
- Do not use mocks by default (keep them to a minimum)

## Test Writing Guide

### Good: AAA Pattern

Arrange / Act / Assert are clearly separated.

```javascript
test("displays an error message when the user does not exist", () => {
  // Arrange
  const userId = "nonexistent-user";
  const expectedErrorMessage = "User not found";

  // Act
  const result = getUserProfile(userId);

  // Assert
  expect(result.error).toBe(expectedErrorMessage);
});
```

### Good: Boundary Value Tests

Verify edge cases such as 0, empty arrays, and maximum values.

```javascript
test("returns 0 when given an empty array", () => {
  const result = sum([]);
  expect(result).toBe(0);
});

test("returns the max value when the element equals the upper bound", () => {
  const result = clamp(100, { min: 0, max: 100 });
  expect(result).toBe(100);
});
```

### Good: Error Cases

Explicitly verify abnormal behavior.

```javascript
test("returns a validation error for an invalid email address", () => {
  const result = validateEmail("invalid-email");
  expect(result.valid).toBe(false);
  expect(result.error).toBe("Invalid email format");
});
```

### Bad: Multiple Behaviors in One Test → Split Them

```javascript
// Bad: multiple behaviors crammed into a single test
test("user creation test", () => {
  const user = createUser("Alice");
  expect(user.name).toBe("Alice");
  expect(user.id).toBeDefined();
  const duplicate = createUser("Alice");
  expect(duplicate).toBeNull();
});

// Good: split into one behavior per test
test("sets the name and ID when creating a user", () => {
  const user = createUser("Alice");
  expect(user.name).toBe("Alice");
  expect(user.id).toBeDefined();
});

test("returns null when a user with the same name already exists", () => {
  createUser("Alice");
  const duplicate = createUser("Alice");
  expect(duplicate).toBeNull();
});
```

### Bad: Unclear Test Names → Describe the Intent

```javascript
// Bad: intent is not clear from the test name
test("test1", () => { /* ... */ });

// Good: describe the behavior clearly
test("redirects to the login page when accessing without authentication", () => { /* ... */ });
```

### Good: Mock Only External Dependencies

Only mock uncontrollable dependencies such as external APIs.

```javascript
test("returns a fallback value when the external API fails", () => {
  vi.spyOn(httpClient, "get").mockRejectedValue(new Error("503"));
  const result = await fetchUserData("user-1");
  expect(result).toEqual({ name: "Unknown", status: "unavailable" });
});
```

### Bad: Mocking Internal Logic

Mocking your own code reduces refactoring resilience.

```javascript
// Bad: mocking an internal calculation function
vi.spyOn(mathUtils, "calculateTax").mockReturnValue(100);
const total = getOrderTotal(1000);
expect(total).toBe(1100);

// Good: verify via input/output (no dependency on internal implementation)
const total = getOrderTotal(1000);
expect(total).toBe(1100);
```

## Strict Rules

- Writing the implementation before writing the test is prohibited
- Do not refactor while a test is failing
- For changes that break existing tests, confirm with the user beforehand
