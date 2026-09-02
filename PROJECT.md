# Project-Specific Rules

<!-- Repo-specific agent instructions. The rollout script never touches this file. -->

<!-- ── Migrated from GEMINI.md ── -->

# Sleeplab Journal: Engineering Standards
## Test-Driven Development (TDD) Mandate
All feature development and bug fixes must follow a strict TDD lifecycle:
1.  **Red:** Write a failing test case that defines the desired behavior or reproduces a reported bug.
2.  **Green:** Implement the minimal code necessary to make the test pass.
3.  **Refactor:** Clean up the implementation while ensuring tests remain passing.
## Quality Thresholds
-   **Minimum Code Coverage:** 90%
-   **Enforcement:** Every Pull Request must include new or updated tests. Coverage must be verified using `flutter test --coverage`.
## Testing Conventions
-   **Unit Tests:** For business logic and state management (located in `test/unit`).
-   **Widget Tests:** For UI components and design system adherence (located in `test/widgets`).
-   **Mocks:** Use `mockito` or `mocktail` for external dependencies (e.g., Oura Ring API, Apple Health).
## Design System Adherence
-   Validate that all new widgets correctly utilize the `AppTheme` defined in `lib/theme.dart`.
-   Shadows are strictly prohibited. Use luminance and outlines for depth.
