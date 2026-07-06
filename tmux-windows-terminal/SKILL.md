---
name: tmux-windows-terminal
description: Diagnose and fix tmux issues in Windows Terminal, WSL, SSH, and nested terminal setups, especially mouse coordinate leakage, broken clipboard or copy mode, passthrough errors, focus-event glitches, terminal capability mismatches, and requests to build or refactor a complete ~/.tmux.conf for reliable mouse, OSC52 clipboard, RGB, popup, pane, and status behavior.
---

# Tmux Windows Terminal

Use this skill to repair tmux in remote or nested terminal chains where terminal capabilities, clipboard forwarding, and mouse handling interact badly.

## Workflow

1. Identify whether the user needs:
   - a diagnosis of an existing setup;
   - a targeted fix for one symptom;
   - a full `~/.tmux.conf` refresh.
2. Run `scripts/collect_tmux_diagnostics.sh` when you need runtime evidence before editing.
3. Choose one of these paths:
   - For a full known-good config, start from `assets/tmux.conf.full`.
   - For a partial fix, patch only the terminal, clipboard, mouse, and copy-mode sections.
   - For symptom-specific guidance, read `references/troubleshooting.md`.
4. Reload tmux with `tmux source-file ~/.tmux.conf` for syntax checks, but require `tmux kill-server && tmux` when terminal capability state may be stale.
5. Verify runtime state with `tmux show -s`, `tmux show -g`, and terminal-specific tests after the edit.

## Decision Rules

- Prefer `default-terminal "tmux-256color"` when `infocmp tmux-256color` succeeds.
- Prefer `terminal-features` over broad legacy `terminal-overrides` when expressing classes of support such as `RGB`, `mouse`, `extkeys`, and `clipboard`.
- Keep `terminal-overrides` narrow. Avoid wildcard-heavy entries unless the user truly needs them across many outer terminals.
- Use `set -g focus-events off` when Windows Terminal, WSL, ConPTY, SSH latency, or leaked `61;...c` style responses are involved.
- Use `set -g allow-passthrough all` for remote or nested clipboard paths when visible-pane restrictions are likely to interfere.
- Prefer `set -s set-clipboard external` for remote tmux sessions that should write to the host terminal clipboard through OSC 52.
- Include a fast fallback for native terminal selection, such as a keybinding that temporarily disables tmux mouse.

## Editing Guidance

- Preserve unrelated user customizations such as prefix, status, pane movement, popup bindings, or theme choices unless they conflict with terminal behavior.
- If the user asks for a complete config, deliver a coherent whole, not only the mouse and clipboard block.
- If the user already has repeated `set -ga terminal-overrides` or `set -ga terminal-features`, collapse them into deterministic `set -g` base assignments plus a minimal append only where needed. Repeated append-only reloads create runtime drift.
- Treat `tmux source-file` success as syntax validation only. It does not prove stale capability state has been cleared.

## Resources

- Read `references/troubleshooting.md` for symptom-to-fix mapping and validation steps.
- Read `references/config-rationale.md` when you need section-by-section reasoning for a full config.
- Use `assets/tmux.conf.full` as the complete template.
- Run `scripts/install_tmux_windows_terminal_conf.sh` to install the full template with an automatic backup.
