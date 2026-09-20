# Coding Directives

## General

- Read and understand existing code before suggesting modifications.
- Match the style and conventions of the surrounding code — don't impose a different style.
- Don't design for hypothetical future requirements. Build what the task requires, no more.
- Avoid premature abstractions. Three similar lines of code is better than a speculative helper.
- No backwards-compatibility hacks for unused code. Do not delete dead code unless explicitly asked.

## Development Workflow

- Follow this cycle: plan → implement → code review → address feedback → repeat as needed.
- Don't skip steps or collapse phases — complete each before moving to the next.
- Code must lint, build, and pass tests before being sent for review, where that infrastructure exists.
- Once code review is complete and feedback is addressed, recommend adversarial review for changes that are security-sensitive, touch a public API surface, carry high risk if incorrect, or are large in scope (e.g. crossing abstraction boundaries, affecting multiple layers of the system).

## Code Review

- The goal of code review is to leave the codebase in a better place than it was found. The codebase should be improving over time.
- Approve a change once it improves overall code health, even if it isn't perfect. Don't hold out for perfection.
- Do not approve changes that degrade code health, except in genuine emergencies.
- Review against the stated intent of the change — not against the entire codebase.
- Do not flag issues in unchanged or out-of-scope code unless they are directly related to the change.
- Where an issue is found, recommend a specific remediation rather than just identifying the problem.
- Prefix optional or minor suggestions with "Nit:" to distinguish them from blocking feedback.
- Base feedback on technical facts, data, and engineering principles — not personal preference.
- When multiple valid approaches exist, defer to the author's choice if it is reasonable and well-founded.
- Code review is also a mentoring opportunity — share relevant knowledge about languages, patterns, and design.
- If a reviewer is confused by code, the right response is to improve the code — not just explain it in a comment. Future readers will face the same confusion.

## Responding to Review Feedback

- Treat review feedback as collaborative, not personal. The goal is a better codebase.
- When disagreeing with feedback, explain your reasoning — "I went with X because of [pros/cons]" — rather than simply refusing.
- If feedback reveals that code is unclear, fix the code.
- Do not be defensive when feedback is critical. Engage with the substance, not the tone.

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

## Project-Specific Notes

<!-- Per-project AGENTS.md files should cover:
- Project overview: what this project is and does
- Setup: how to install dependencies and get a working environment
- Build commands: how to build the project
- Test commands: how to run the test suite
- Lint commands: how to run linters and type checkers
- Deployment: how and where the project is deployed, and any deployment constraints
- Conventions: anything project-specific that overrides or extends these global directives
-->
