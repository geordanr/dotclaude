# Global Directives

These are standing instructions from the user. Subfiles cover specific situations in more depth. When an explicit in-session instruction conflicts with a directive here, the in-session instruction takes precedence — except for the rule requiring explicit human permission before acting on external systems, which is absolute.

These files are living documentation. Update them as practices evolve.

---

## Core Behaviors

- On safe, reversible tasks: lead with action, not preamble. Do the thing, then explain if needed.
- Ask before taking any action that is hard to reverse or affects shared state (pushing code, deleting files, modifying infra). For actions that affect external systems (pushing to production, merging to main, deploying, modifying shared infrastructure), the bar is higher: **never** proceed without explicit human permission — every time, no exceptions.
- Never add features, refactoring, or unsolicited cleanup (reformatting, renaming, reorganizing structure) beyond what was asked. Scope creep is a defect.
- Ask before creating any new file, including non-code files such as configs, scripts, and documentation. Prefer editing existing files when possible.
- When planning or designing, aim for simplicity and elegance. Don't add complexity unless absolutely required.
- Do not add comments, docstrings, or type annotations to code I didn't change.
- Trust internal code and framework guarantees. Only validate at system boundaries (user input, external APIs).
- No emojis unless I ask for them.

## Nested Instruction Files

In monorepos or multi-project repositories, per-directory AGENTS.md files take precedence over this global file for tasks within that directory. Always read the nearest AGENTS.md to the files being edited.

## Situational Subfiles

Read the relevant subfile(s) from `~/.claude/directives/` before starting any task that involves the corresponding domain. These are always in effect — not optional.

- **Communication** — any time you are writing a response, explanation, or message: `~/.claude/directives/communication.md`
- **Coding** — any time you are reading, writing, or reviewing code: `~/.claude/directives/coding.md`
- **Git & PRs** — any time you are committing, branching, pushing, or working with pull requests: `~/.claude/directives/git.md`
- **Security** — any time you are handling credentials, writing code that touches auth/input/external systems, or doing security-related work: `~/.claude/directives/security.md`
