# Security Policy

## Reporting a vulnerability

Report security issues privately via [GitHub Security Advisories](https://github.com/seonglae/vect-app/security/advisories/new).

Do **not** open a public issue for vulnerabilities. Source-level issues may also be reported in [seonglae/vect](https://github.com/seonglae/vect/security/advisories/new).

## Scope

- Vect desktop binary (Tauri shell + bundled webview)
- Agent CLI integration paths (Claude / Codex / Gemini / OpenCode / OpenClaw)
- CRDT WebSocket server (`127.0.0.1:9877`)
- MCP server configurations distributed via this repository

## Out of scope

- Vulnerabilities in the underlying agent CLIs (report upstream)
- Issues requiring physical access to the user's machine
- Issues that depend on an attacker-controlled `~/.vect/` directory
