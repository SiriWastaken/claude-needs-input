# Terminal support

The title and bell work in nearly every terminal. Desktop notifications need a terminal that understands one of these escapes; the plugin picks one from your environment:

| Terminal | Detected by | Escape |
| --- | --- | --- |
| iTerm2, WezTerm | `TERM_PROGRAM` | OSC 9 |
| Windows Terminal | `WT_SESSION` | OSC 9 |
| Kitty | `KITTY_WINDOW_ID` / `TERM=xterm-kitty` | OSC 99 |
| Ghostty, Warp, urxvt, others | fallback | OSC 777 |

Terminals that don't support the chosen escape ignore it. macOS Terminal.app has no notification escape, so you get the title and bell only.

## tmux and SSH

Detection may guess wrong. Set `CNI_NOTIFY_STYLE` (`777`, `9` or `99`) explicitly; tmux also needs `set -g allow-passthrough on` for some escapes.
