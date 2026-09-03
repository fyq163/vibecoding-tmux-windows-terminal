# Extended Keys and `csi-u`

## Scope

Use this reference when a user reports that modifier combinations do not reach the application inside tmux, for example:

- `Shift+Enter` behaves the same as `Enter`;
- `Ctrl+Enter`, `Option/Alt+Enter`, or `Shift+Arrow` are collapsed into a plain key;
- a TUI or coding agent requests extended key reporting but receives legacy sequences;
- a keybinding table that works outside tmux stops working inside tmux.

## Recommended Configuration

```tmux
set -s extended-keys on
set -g extended-keys-format csi-u
```

Then restart tmux fully:

```bash
tmux kill-server
tmux
```

`tmux source-file` alone is not sufficient for extended-key negotiation state.

## Why `csi-u`

With only `extended-keys on`, tmux defaults to `extended-keys-format xterm`, which forwards modified keys in xterm `modifyOtherKeys` form:

| Key | xterm form (default) |
|-----|----------------------|
| `Ctrl+C` | `\x1b[27;5;99~` |
| `Ctrl+D` | `\x1b[27;5;100~` |
| `Ctrl+Enter` | `\x1b[27;5;13~` |

With `extended-keys-format csi-u`, the same keys are forwarded as:

| Key | `csi-u` form |
|-----|--------------|
| `Ctrl+C` | `\x1b[99;5u` |
| `Ctrl+D` | `\x1b[100;5u` |
| `Ctrl+Enter` | `\x1b[13;5u` |

`csi-u` is the more reliable encoding and is the one to prefer when the terminal and tmux version support it.

## What It Fixes

Without tmux extended keys, modified Enter keys collapse to legacy sequences:

| Key | Without extkeys | With `csi-u` |
|-----|-----------------|--------------|
| Enter | `\r` | `\r` |
| Shift+Enter | `\r` | `\x1b[13;2u` |
| Ctrl+Enter | `\r` | `\x1b[13;5u` |
| Alt/Option+Enter | `\x1b\r` | `\x1b[13;3u` |

This affects any keybinding that distinguishes modified Enter, and any application binding built on modified arrows or function keys.

## Requirements

- tmux 3.5 or later for `extended-keys-format` (check with `tmux -V`).
- A terminal emulator that supports extended keys, such as Ghostty, Kitty, iTerm2, WezTerm, or Windows Terminal.
- On tmux 3.2 through 3.4, omit `extended-keys-format csi-u`. The default xterm `modifyOtherKeys` format still forwards modified keys, and most applications accept both.

An unconditional `set -g extended-keys-format csi-u` on tmux older than 3.5 fails with an unknown-option error, which aborts the rest of the config. When targeting mixed-version environments, guard it:

```tmux
if-shell -b '[ "$(tmux -V | cut -d" " -f2 | cut -d. -f1)" -ge 3 ] && [ "$(tmux -V | cut -d" " -f2 | cut -d. -f2)" -ge 5 ]' \
  'set -g extended-keys-format csi-u'
```

## Interaction With `terminal-features`

`extended-keys-format` control encoding. Terminal capability declaration is separate and lives in `terminal-features` via the `extkeys` feature:

```tmux
set -g terminal-features "xterm-ghostty:RGB:mouse:extkeys:clipboard,xterm-256color:RGB:mouse:extkeys:clipboard,tmux-256color:RGB:mouse:extkeys:clipboard,tmux:RGB:mouse:extkeys:clipboard"
```

Both are needed: `extkeys` tells tmux the outer terminal can do extended keys, and `extended-keys-format` selects how tmux forwards them inward.

## Verification

```bash
tmux -V
tmux show -sv extended-keys
tmux show -gv extended-keys-format
tmux show -gv terminal-features
```

Then test a modified key directly inside a pane, for example with `cat -v` followed by `Shift+Enter`, and confirm the sequence contains the modifier field rather than a bare `\r`.

## Source

Adapted from the Pi coding-agent tmux documentation:

- <https://github.com/earendil-works/pi/blob/b8b873b9872db04a938fb4357b5e8e824ddc051c/packages/coding-agent/docs/tmux.md>

Pinned to commit `b8b873b9872db04a938fb4357b5e8e824ddc051c`. Check upstream for changes beyond that point.
