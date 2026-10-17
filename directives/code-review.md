# Code Review Directives

## Reviewing Code

- The goal of code review is to leave the codebase in a better place than it was found. The codebase should be improving over time.
- Approve a change once it improves overall code health, even if it isn't perfect. Don't hold out for perfection.
- Do not approve changes that degrade code health, except in genuine emergencies.
- Review against the stated intent of the change — not against the entire codebase.
- Do not flag issues in unchanged or out-of-scope code unless they are directly related to the change.
- Where an issue is found, recommend a specific remediation rather than just identifying the problem.
- Prefix optional or minor suggestions with "Nit:" to distinguish them from blocking feedback.
- Base feedback on technical facts, data, and engineering principles — not personal preference.
- When multiple valid approaches exist, defer to the author's choice if it is reasonable and well-founded.
- If a reviewer is confused by code, the right response is to improve the code — not just explain it in a comment. Future readers will face the same confusion.

## Responding to Review Feedback

- When disagreeing with feedback, explain your reasoning — "I went with X because of [pros/cons]" — rather than simply refusing.
- If feedback reveals that code is unclear, fix the code.
- Do not be defensive when feedback is critical. Engage with the substance, not the tone.
