# Vect

<img src="https://raw.githubusercontent.com/seonglae/vect/main/.github/icon.png" width="80" alt="Vect" />

**AI-native IDE.** Local-first. Wraps Claude Code, Codex, Gemini, OpenCode, OpenClaw under one shell.

<img src="https://raw.githubusercontent.com/seonglae/vect/main/.github/screenshot.png" width="910" alt="Vect screenshot" />

## Install

**macOS / Linux**
```bash
curl -fsSL https://raw.githubusercontent.com/seonglae/vect/main/scripts/install.sh | bash
```

**Homebrew (macOS)**
```bash
brew install --cask seonglae/tap/vect
```

**Windows**
```powershell
irm https://raw.githubusercontent.com/seonglae/vect/main/scripts/install.ps1 | iex
```

**Manual** — grab platform installer from [releases](https://github.com/seonglae/vect/releases/latest).

## Features

- Multi-agent session orchestration (Claude, Codex, Gemini, OpenCode, OpenClaw)
- Local SQLite session history with one-click resume
- CRDT-backed team mode for concurrent agents in one workspace
- JSON-Render engine — agents emit structured UI blocks (markdown, code, chart, table, form, image)
- Skill / context editor (CLAUDE.md, .ctx, memory)
- Workflow engine, task board, roadmap, audit timeline
- Customizable themes, keybindings

## Plugins

See [plugins/](./plugins) for curated skills, hooks, and extensions.

## Bug reports

Open an [issue](https://github.com/seonglae/vect/issues/new/choose).

## Source

Source is open at [seonglae/vect](https://github.com/seonglae/vect) (MIT).
