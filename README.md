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

## How it works

Plain hooks, no daemon. `hooks/hooks.json` wires four events to `scripts/cni.sh`:

| Event | Mode | Result |
| --- | --- | --- |
| `Notification` (`permission_prompt`, `idle_prompt`, `elicitation_dialog`, `agent_needs_input`) | `notify` | flag title + bell + notification |
| `UserPromptSubmit`, `PostToolUse` | `clear` | restore title |
| `Stop` | `done` | `✔` title |

The script returns a `terminalSequence` JSON field; Claude Code writes it to your terminal (hooks have no tty of their own). Only OSC 0/2, 9, 99, 777 and BEL are allowed by Claude Code, and the script strips control characters and `;` from message text.

## Terminal support

Title and bell work nearly everywhere. Desktop notifications use OSC 777 (Ghostty, Warp, urxvt); iTerm2/WezTerm use OSC 9 and Kitty uses OSC 99, which this version does not emit yet. Not yet tested across terminals. `terminalSequence` is ignored in `-p` and Agent SDK runs.

## Development

```
bash tests/cni.test.sh          # unit tests
claude plugin validate .         # manifest + marketplace check
claude --plugin-dir .            # try it live
```

See [CONTRIBUTING.md](CONTRIBUTING.md) and [CHANGELOG.md](CHANGELOG.md). MIT licensed.
