# Test Implementation Guidelines

## Rules

- Use clear, descriptive Japanese test case names
- Follow the AAA (Arrange-Act-Assert) pattern
- Test boundary values and edge cases
- Each test should focus on a single behavior
- Do not use mocks by default (keep to the minimum when necessary)

## Good Example

```javascript
test("ユーザーが存在しない場合、エラーメッセージを表示する", () => {
  // Arrange
  const userId = "nonexistent-user";
  const expectedErrorMessage = "ユーザーが見つかりません";

  // Act
  const result = getUserProfile(userId);

  // Assert
  expect(result.error).toBe(expectedErrorMessage);
});
```
