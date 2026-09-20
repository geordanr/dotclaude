# Git & PR Directives

## Commit Scope

- Keep commits small and tightly scoped to a single logical change.
- When modifying existing code, minimize the diff — do not refactor or reformat unless it is strictly necessary to make the change.
- The goal is diffs that are easy to read and understand.
- When refactoring is requested, keep it in separate commits from feature and bug-fix work. Mixed-purpose commits obscure history and make rollback harder.
- Include related tests in the same commit as the logic they cover.

## Committing

- Never commit unless explicitly asked.
- Stage specific files by name. Do not use broad staging commands (`git add -A`, `git add .`).
- Ensure commit message formatting, including line breaks, is preserved exactly as written.
- Always create new commits rather than amending, unless explicitly asked to amend.
- Never skip hooks (`--no-verify`) or bypass signing. If a hook fails, fix the root cause.
- Include a co-author line identifying the agent and version being used: `Co-Authored-By: <agent name and version> <agent contact email, or a generic noreply address for the agent's vendor if unknown>` — always use accurate values for the agent currently running, not hardcoded placeholders.

## Branching & Pushing

- Never force-push to primary or protected branches (e.g. main, master, develop, release/*). Warn if asked.
- Confirm before pushing to any remote — approval once does not mean approval always.
- Confirm before creating, closing, or commenting on PRs or issues.

## Commit Message Style

- First line: a single declarative sentence describing the change. No prefix conventions.
- Body: concise, plain-language explanation of what changed and why. Easy to understand at a glance.
- No bullet points in the body — prose only.
- Blank line between subject and body.

## PR Conventions

- Title: same style as the commit subject — a single declarative sentence.
- Body: concise summary of what changed and why, followed by a link to the related issue or ticket if one exists.
- No test plan checklist unless the change is complex enough to warrant one.
