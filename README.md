# Vect

<img src="https://raw.githubusercontent.com/seonglae/vect/main/.github/icon.png" width="80" alt="Vect" />

**AI-native IDE.** Local-first. One shell over Claude Code, Codex, OpenCode and Hermes.

Coding is one of the things it is for. Writing and research sessions use the same surface.

[vectai.org](https://vectai.org) · [Documentation](https://vectai.org/docs) · [Changelog](./CHANGELOG.md)

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

**Manual.** Grab the installer for your platform from [releases](https://github.com/seonglae/vect/releases/latest).

macOS builds are signed and notarized, and Vect keeps itself up to date from this releases page.

## What you get

- **One window for the whole project.** A project opens as a single tab holding everything it needs: the conversation, your files, a terminal, a preview. Drag any pane onto the edge of another and it splits there. It opens as just the conversation, and the rest appears when you ask for it.
- **A room, not one agent.** Put several agents on the same work and they claim a file before touching it, read what the others have already written, and merge changes that land at the same moment. It is the default, not an advanced setting.
- **Agents can drive the app.** `vect mcp serve` hands any agent Vect itself as tools: reading and running things in the panel you are looking at, opening a page in the preview, starting and steering other agents. It can also read and write what the project remembers, and every change it makes is written down.
- **Your phone as a second screen.** Scan a QR code and your phone is paired to the machine running your agents. Read along as they work, reply, and answer their questions from another room. iOS and Android, or any phone browser via `vect ui`.
- **Session history that resumes.** Every local agent session, grouped by project, with full transcripts and one-click resume.
- **Structured output.** Agents emit UI blocks (markdown, code, chart, table, form, image) instead of walls of text.
- **Yours to shape.** Skill and context editor for CLAUDE.md, .ctx and memory; workflow engine, task board and audit timeline; themes and keybindings.

No account, and no server to sign in to. Nothing is uploaded, and it works offline.

## Documentation

Everything is at [vectai.org/docs](https://vectai.org/docs).

| | |
|---|---|
| [Getting started](https://vectai.org/docs/getting-started) | Install it, point it at a project, start the first session. |
| [Sessions](https://vectai.org/docs/sessions) | Browsing, resuming and searching every conversation on the machine. |
| [Workspaces](https://vectai.org/docs/workspaces) | One tab per project, panes docked where you want them. |
| [Rooms](https://vectai.org/docs/rooms) | Several agents in one shared workspace without overwriting each other. |
| [Tasks](https://vectai.org/docs/tasks) | Work items on a board, each carrying its own session. |
| [Phone](https://vectai.org/docs/mobile) | Pairing a phone as a second screen onto the same agents. |
| [Vect MCP server](https://vectai.org/docs/vect-mcp) | Letting an agent use Vect itself as a tool. |
| [Agent providers](https://vectai.org/docs/agent-providers) | What each supported agent can and cannot do inside Vect. |
| [CLI](https://vectai.org/docs/cli) | Every `vect` subcommand. |
| [Keybindings](https://vectai.org/docs/keybindings) | Default bindings and how to rebind them. |

## Plugins

Curated skills, hooks and extensions live in [plugins/](./plugins).

## Bug reports

Open an [issue](https://github.com/seonglae/vect/issues/new/choose). Release notes for every version are in [CHANGELOG.md](./CHANGELOG.md).
