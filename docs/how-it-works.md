# How it works

Plain hooks, no daemon. [`hooks/hooks.json`](../hooks/hooks.json) wires four events to [`scripts/cni.sh`](../scripts/cni.sh):

| Event | Mode | Result |
| --- | --- | --- |
| `Notification` (`permission_prompt`, `idle_prompt`, `elicitation_dialog`, `agent_needs_input`) | `notify` | flag title + bell + notification |
| `UserPromptSubmit`, `PostToolUse` | `clear` | restore title |
| `Stop` | `done` | `✔` title |

Hooks have no tty of their own, so the script returns a `terminalSequence` JSON field and Claude Code writes it to your terminal. Only OSC 0/2, 9, 99, 777 and BEL are allowed, and the script strips control characters and `;` from message text.

`terminalSequence` is ignored in `claude -p` and Agent SDK runs.
