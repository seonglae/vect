# Vect

<img src="https://raw.githubusercontent.com/seonglae/vect/main/.github/icon.png" width="80" alt="Vect" />

**AI-native IDE.** Local-first. One shell over Claude Code, Codex, OpenCode and Hermes.

Coding is one of the things it is for. Writing and research sessions use the same surface.

<img src="https://raw.githubusercontent.com/seonglae/vect/main/docs/vect-app.webp" width="910" alt="The Vect desktop app" />

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

**Manual** — grab the installer for your platform from [releases](https://github.com/seonglae/vect/releases/latest).

macOS builds are signed and notarized, and Vect keeps itself up to date from this releases page.

## What you get

- **Workspaces** — a worktree opens as one tab holding its whole working set. Panes dock anywhere: drag one onto any edge of another and it splits there. It opens as the conversation alone, because not living in a terminal is the point.
- **Agents can drive the app** — `vect mcp serve` hands any agent CLI Vect's own surface as tools: run and read the visible terminal, point the browser pane somewhere, spawn and steer other agent sessions, read and write project memory. Every mutating call lands in the audit log.
- **Your phone as a second screen** — scan a QR code and your phone is paired to the machine running your agents: read the conversation as it streams, reply, and answer permission prompts from another room. Nothing is uploaded anywhere, the phone talks straight to your computer. iOS and Android, or any phone browser via `vect ui`.
- **Session history that resumes** — every local agent session, grouped by project, with full transcripts and one-click resume.
- **Team mode** — CRDT-backed, so several agents can work one workspace at once without overwriting each other.
- **Structured output** — agents emit UI blocks (markdown, code, chart, table, form, image) instead of walls of text.
- **Yours to shape** — skill and context editor for CLAUDE.md, .ctx and memory; workflow engine, task board and audit timeline; themes and keybindings.

Local-first throughout: SQLite plus your filesystem, and it works offline.

## Plugins

Curated skills, hooks and extensions live in [plugins/](./plugins).

## Bug reports

Open an [issue](https://github.com/seonglae/vect/issues/new/choose). Release notes for every version are in [CHANGELOG.md](./CHANGELOG.md).
