# tmux-windows-terminal-skill

Codex skill for diagnosing and fixing tmux problems in Windows Terminal, WSL, SSH, and nested terminal setups.

This repository packages a ready-to-dispatch skill directory:

- `tmux-windows-terminal/`

The skill covers:

- mouse coordinate leakage such as `61;...c`
- clipboard failures over OSC 52
- passthrough issues in nested or remote tmux
- `focus-events` and terminal capability mismatches
- full `~/.tmux.conf` generation, not only clipboard snippets

## Repository Layout

```text
tmux-windows-terminal/
  SKILL.md
  agents/openai.yaml
  assets/tmux.conf.full
  references/
  scripts/
scripts/
  package-skill.sh
```

## Install Into Codex

Clone or copy this repository, then copy the skill folder into your Codex skills directory:

```bash
mkdir -p "${CODEX_HOME:-$HOME/.codex}/skills"
cp -R tmux-windows-terminal "${CODEX_HOME:-$HOME/.codex}/skills/"
```

If the skill is already present, replace it intentionally:

```bash
rm -rf "${CODEX_HOME:-$HOME/.codex}/skills/tmux-windows-terminal"
cp -R tmux-windows-terminal "${CODEX_HOME:-$HOME/.codex}/skills/"
```

## Use The Skill

Example prompts:

- `Use $tmux-windows-terminal to diagnose mouse garbage in tmux over Windows Terminal SSH.`
- `Use $tmux-windows-terminal to rebuild my full ~/.tmux.conf for WSL and Windows Terminal.`
- `Use $tmux-windows-terminal to fix clipboard and passthrough in nested tmux.`

## Included Utilities

Run diagnostics:

```bash
./tmux-windows-terminal/scripts/collect_tmux_diagnostics.sh
```

Install the full template with a timestamped backup:

```bash
./tmux-windows-terminal/scripts/install_tmux_windows_terminal_conf.sh
```

The installer writes:

- `~/.tmux.conf`
- `~/.tmux.conf.bak.<timestamp>` when a previous config exists

After installing or editing terminal capability settings, restart tmux fully:

```bash
tmux source-file ~/.tmux.conf
tmux kill-server
tmux
```

## Validation

Validate the skill structure with the upstream validator from your Codex environment:

```bash
python3 ~/.codex/skills/.system/skill-creator/scripts/quick_validate.py ./tmux-windows-terminal
```

## Packaging

Create a release tarball from the repository root:

```bash
./scripts/package-skill.sh
```

This writes `dist/tmux-windows-terminal-skill.tar.gz`.

## Notes

- This repository intentionally keeps GitHub-facing docs at the repository root and AI-facing instructions inside `tmux-windows-terminal/`.
- No license file is included yet. Add one before public release if you want explicit reuse terms.
