# claude-needs-input

A Claude Code plugin that makes it obvious when Claude is **waiting on you**, so you don't have to scan a busy terminal.

When Claude hits a permission prompt, a question, or goes idle:

- the terminal tab/window title becomes `⚠ NEEDS INPUT — <project>`
- the terminal bell rings
- a desktop notification shows Claude's message (terminals that support it)

When you respond the title goes back to `✻ <project>`; when Claude finishes it shows `✔ <project>`.

## Install

```
/plugin marketplace add SiriWastaken/claude-needs-input
/plugin install needs-input@needs-input
```

Requires `bash` and [`jq`](https://jqlang.github.io/jq/) on your `PATH` (if `jq` is missing the plugin silently does nothing).

## Configuration

Environment variables, set in your shell or Claude Code `env` settings:

| Variable | Default | Effect |
| --- | --- | --- |
| `CNI_BELL` | `1` | `0` disables the bell |
| `CNI_NOTIFY` | `1` | `0` disables the desktop notification |
| `CNI_TITLE_PREFIX` | `⚠ NEEDS INPUT` | Text shown in the title while waiting |
| `CNI_NOTIFY_STYLE` | auto | Force the notification escape: `777`, `9` or `99` (see below) |

## How it works

Plain hooks, no daemon. `hooks/hooks.json` wires four events to `scripts/cni.sh`:

| Event | Mode | Result |
| --- | --- | --- |
| `Notification` (`permission_prompt`, `idle_prompt`, `elicitation_dialog`, `agent_needs_input`) | `notify` | flag title + bell + notification |
| `UserPromptSubmit`, `PostToolUse` | `clear` | restore title |
| `Stop` | `done` | `✔` title |

The script returns a `terminalSequence` JSON field; Claude Code writes it to your terminal (hooks have no tty of their own). Only OSC 0/2, 9, 99, 777 and BEL are allowed by Claude Code, and the script strips control characters and `;` from message text.

## Terminal support

The title and bell work in nearly every terminal. Desktop notifications need a terminal that understands one of these escapes; the plugin picks one from your environment:

| Terminal | Detected by | Escape |
| --- | --- | --- |
| iTerm2, WezTerm | `TERM_PROGRAM` | OSC 9 |
| Windows Terminal | `WT_SESSION` | OSC 9 |
| Kitty | `KITTY_WINDOW_ID` / `TERM=xterm-kitty` | OSC 99 |
| Ghostty, Warp, urxvt, others | fallback | OSC 777 |

Terminals that don't support the chosen escape ignore it. Inside tmux or over SSH detection may guess wrong; set `CNI_NOTIFY_STYLE` explicitly (tmux also needs `set -g allow-passthrough on` for some escapes). macOS Terminal.app has no notification escape, so you get the title and bell only.

`terminalSequence` is ignored in `claude -p` and Agent SDK runs.

## Troubleshooting

- **Nothing happens:** check `jq --version` works in the shell Claude Code starts from, and `claude plugin list` shows `needs-input@needs-input` enabled.
- **Title never changes:** some terminals or shell prompts overwrite the title on every prompt (e.g. oh-my-zsh `DISABLE_AUTO_TITLE`); disable that.
- **Notifications don't appear:** allow notifications for your terminal app in system settings, and check the table above.

## Uninstall

```
/plugin uninstall needs-input@needs-input
```

## Development

```
bash tests/cni.test.sh          # unit tests
claude plugin validate .         # manifest + marketplace check
claude --plugin-dir .            # try it live
```

See [CONTRIBUTING.md](CONTRIBUTING.md) and [CHANGELOG.md](CHANGELOG.md). MIT licensed.
