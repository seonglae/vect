# Vect Plugins

Curated skills, hooks, and extensions for Vect.

Each subdirectory is a self-contained plugin with its own README + entry point. Install by copying into `~/.vect/skills/` (skills) or referencing from `~/.vect/settings.json` (hooks/extensions).

## Categories

- **Skills** — agent capabilities (code-review, commit-message, refactor)
- **Hooks** — pre/post-tool callbacks
- **Themes** — color presets and font packs
- **Workflows** — multi-step automations

## Submitting a plugin

Open a PR with:
- `<plugin-name>/README.md` — install + usage
- `<plugin-name>/manifest.json` — name, version, entry, kind
- Entry file (`.md` for skill, `.sh` for hook, `.json` for theme/workflow)

Plugin code is reviewed before merge.
