# Auditing features that call a language model

Read when the system sends text to an LLM, uses its output or lets it call tools. Category names
follow the OWASP Top 10 for LLM Applications (2025 edition). Check the current edition for changes.

## The core idea

Any text that reaches the model from outside (user input, retrieved documents, web pages, emails, file
contents, tool results) can carry instructions. No input filter reliably removes them. So the audit asks
a different question: **if the model followed the worst instruction it could be given, what could it
do?** The answer must be "nothing the triggering user could not already do".

## Checks

| Risk | What to check |
|---|---|
| Prompt injection (direct and indirect) | Which untrusted sources reach the prompt? Retrieved content and tool output count. What can the model do after reading them? |
| Sensitive information disclosure | What secrets, personal data or other users' records are in the context? Assume the model can be made to repeat any of it. |
| Supply chain | Are model versions, weights, adapters and plugins pinned and from a known source? |
| Data and model poisoning | If fine-tuning or building a retrieval index, who can write to the source data? |
| Improper output handling | Is output rendered as HTML, run as code or SQL, passed to a shell or used as a URL to fetch? Treat it as untrusted input at every sink. |
| Excessive agency | Does each tool run with the triggering user's permissions, not a service account's? Do destructive or external actions need a human to confirm? |
| System prompt leakage | Does the system prompt hold secrets or access rules? It will leak. Enforce rules in code. |
| Vector and embedding weaknesses | Is the retrieval index partitioned by tenant? Can one user's documents be retrieved for another? |
| Misinformation | Is output used for decisions with material impact without review or a source the user can check? |
| Unbounded consumption | Are there token limits, timeouts, per-user rate limits and a spend cap on every call path? |

## Minimum controls

- [ ] Tools run with the calling user's identity and permissions.
- [ ] Consequential actions (send, pay, delete, publish, change permissions) need explicit confirmation.
- [ ] Output is encoded for its sink (HTML-escaped, parameterised, never `eval`ed).
- [ ] Retrieved content is filtered by the caller's access rights before it enters the prompt.
- [ ] No secrets in the system prompt or context.
- [ ] Token budget, timeout and per-user rate limit on every call.
- [ ] Prompts and tool calls are logged without personal data, so abuse can be reconstructed.

## How to test

Plant an instruction in each untrusted source the feature reads (a document, a profile field, a web
page it fetches) that asks the model to call a tool, reveal its context or emit a script tag. Record
what the system did, not what the model said. A finding is any effect beyond the triggering user's own
permissions.
