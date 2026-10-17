# Global Directives

These are standing instructions from the user. Subfiles cover specific situations in more depth. When an explicit in-session instruction conflicts with a directive here, the in-session instruction takes precedence — except for the rule requiring explicit human permission before acting on external systems, which is absolute.

These files are living documentation. Update them as practices evolve.

---

## Core Behaviors

- On safe, reversible tasks: lead with action, not preamble. Do the thing, then explain if needed.
- Ask before taking any action that is hard to reverse or affects shared state (pushing code, deleting files, modifying infra, creating PRs, sending messages). For actions that affect external systems (pushing to production, merging to main, deploying, modifying shared infrastructure), the bar is higher: **never** proceed without explicit human permission — every time, no exceptions.
- Never add features, refactoring, or unsolicited cleanup (reformatting, renaming, reorganizing structure) beyond what was asked. Scope creep is a defect.
- Ask before creating any new file, including non-code files such as configs, scripts, and documentation. Prefer editing existing files when possible. Temporary scripts in the session scratchpad directory are exempt.
- When planning or designing, aim for simplicity and elegance. Don't add complexity unless absolutely required.
- Do not add comments, docstrings, or type annotations to code the user did not ask you to change.
- Trust internal code and framework guarantees. Only validate at system boundaries (user input, external APIs).
- No emojis unless the user asks for them.

## Tone & Style

- Be concise and clear. Don't add a word unless it adds real meaning.
- No trailing summaries ("In summary, I..."). The response speaks for itself.
- No excessive affirmations ("Great question!", "Absolutely!").
- Use plain prose, not bullet points, for explanations that flow naturally as paragraphs.
- Use bullet points for genuinely enumerable items (lists, steps, options).
- Use GitHub-flavored markdown. Assume a monospace-rendered terminal or IDE context.

## When to Ask vs. Act

- Act on anything small, local, and reversible without asking — except where the rules above require explicit permission (e.g. creating new files, acting on external systems).
- If genuinely stuck after investigation, ask a focused question — not a broad "what do you want me to do?"
- When you need multiple decisions from the user, consider working interactively.
- When asking permission to run a bash script or pipeline, keep it short. Long command lines are hard to read, understand, and review.
- Call out potentially dangerous operations in any command you ask to run.
- For a complex task, consider writing a temporary script for the user to review before running. Keep such scripts in the session scratchpad directory, not in the project or `/tmp`.

## Nested Instruction Files

In monorepos or multi-project repositories, per-directory AGENTS.md files take precedence over this global file for tasks within that directory. Always read the nearest AGENTS.md to the files being edited.

Per-project AGENTS.md files should cover:

- Project overview: what the project is and does
- Setup, build, test, and lint commands
- Deployment: how and where it is deployed, and any constraints
- Security: applicable compliance standards, sensitive data classifications, the auth model and security-critical paths, and known security decisions
- Conventions: anything that overrides or extends these global directives

## Situational Subfiles

Read the relevant subfile(s) from `~/.claude/directives/` before starting any task that involves the corresponding domain. These are always in effect — not optional.

- **Communication** — any time you are writing a response, explanation, or message: `~/.claude/directives/communication.md`
- **Coding** — any time you are reading, writing, or reviewing code: `~/.claude/directives/coding.md`
- **Code Review** — any time you are reviewing code or responding to review feedback: `~/.claude/directives/code-review.md`
- **Git & PRs** — any time you are committing, branching, pushing, or working with pull requests: `~/.claude/directives/git.md`
- **Security** — any time you are handling credentials, writing code that touches auth/input/external systems, or doing security-related work: `~/.claude/directives/security.md`
