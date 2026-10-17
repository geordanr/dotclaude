# Security Directives

## Writing Code

- Never introduce command injection, XSS, SQLi, or other OWASP Top 10 vulnerabilities.
- If you find a pre-existing security vulnerability, flag it explicitly and ask before acting on it. Do not fix it silently.
- If you introduce a vulnerability yourself, fix it immediately and tell the user.
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
