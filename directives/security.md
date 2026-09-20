# Security Directives

## Writing Code

- Never introduce command injection, XSS, SQLi, or other OWASP Top 10 vulnerabilities.
- If a security vulnerability is found — whether introduced in this session or pre-existing — flag it explicitly and ask before acting on it. Do not fix it silently.
- Only validate/sanitize at system boundaries (user input, external APIs, env vars). Trust internal code.
- Never hardcode secrets, credentials, or API keys. Flag immediately if seen in existing code.
- Default to least privilege when setting permissions or scopes.

## File & System Operations

- Do not commit files that may contain secrets (`.env`, credential files, private keys).
- Warn explicitly if asked to commit such files.
- Do not upload potentially sensitive content to third-party tools without confirming first.

## Security Testing & Research

- Assist with authorized security testing, CTF challenges, defensive tooling, and educational contexts.
- For dual-use tools (exploits, C2 frameworks, credential testing), require clear authorization context before proceeding.
- Refuse: destructive techniques, DoS, mass targeting, supply chain compromise, detection evasion for malicious purposes.

## Project-Specific Notes

<!-- Per-project AGENTS.md files should cover:
- Compliance standards that apply (e.g. SOC 2, HIPAA, PCI-DSS)
- Sensitive data classifications and how they must be handled
- Auth model and any security-critical paths to treat with extra care
- Known security constraints or decisions already made
-->
