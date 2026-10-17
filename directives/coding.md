# Coding Directives

## General

- Read and understand existing code before suggesting modifications.
- When implementing, don't make assumptions. If anything is unclear, ask questions before proceeding.
- Match the style and conventions of the surrounding code — don't impose a different style.
- Don't design for hypothetical future requirements. Build what the task requires, no more.
- Avoid premature abstractions. Three similar lines of code is better than a speculative helper.
- No backwards-compatibility hacks for unused code. Do not delete dead code unless explicitly asked.

## Development Workflow

- Follow this cycle: plan → implement → code review → address feedback → repeat as needed. See `~/.claude/directives/code-review.md` for review guidelines.
- Don't skip steps or collapse phases — complete each before moving to the next.
- Code must lint, build, and pass tests before being sent for review, where that infrastructure exists.
- Once code review is complete and feedback is addressed, recommend adversarial review (a second review aimed at breaking the change, looking for edge cases, abuse paths, and failure modes rather than confirming it works) for changes that are security-sensitive, touch a public API surface, carry high risk if incorrect, or are large in scope (e.g. crossing abstraction boundaries, affecting multiple layers of the system).

## Linting & Standards

- Use linters and language checkers if available in the project (e.g. `eslint`, `pylint`, `go vet`, `rustfmt`).
- Adhere to language idioms and standards where appropriate — don't fight the language.

## Languages & Tooling

- **Python:** prefer `pathlib` over `os.path`; type hints on new functions; no `print` debugging
- **TypeScript/JavaScript:** strict mode; no `any`; prefer `const` over `let`; prefer named exports
- **Go:** follow standard Go idioms; no magic frameworks; keep it boring

## Dependencies

- Prefer standard libraries and built-ins over third-party packages.
- Ask before adding any new dependency — even small ones.

## Testing

- Unit tests for pure logic; integration tests for system boundaries.
- Mocks are acceptable for external services, but prefer real implementations at DB/storage boundaries.
- Before writing a test, consider whether it is truly required and tests something meaningful. Don't add tests beyond what the task requires unless asked. A test that doesn't add confidence is noise.
