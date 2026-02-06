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
- Follow the [Test Implementation Guidelines](@../rules/test-implementation-guidelines.md)
- Run the test and confirm it fails (failure is expected since the implementation doesn't exist yet)

### GREEN: Make the test pass

- Add the implementation to make the test pass
- Aim for the "minimum working code" (generic, not hardcoded)
- Confirm all tests (existing + new) pass

### REFACTOR: Improve

- Eliminate duplication, improve readability and maintainability
- Do not change behavior (tests must continue to pass)
- Follow the coding standards in CLAUDE.md

## Strict Rules

- Writing the implementation before writing the test is prohibited
- Do not refactor while a test is failing
- For changes that break existing tests, confirm with the user beforehand
