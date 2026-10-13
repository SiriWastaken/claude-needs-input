# Troubleshooting

- **Nothing happens:** check `jq --version` works in the shell Claude Code starts from, and `claude plugin list` shows `needs-input@needs-input` enabled. Without `jq` the plugin silently does nothing.
- **Title never changes:** some terminals or shell prompts overwrite the title on every prompt (e.g. oh-my-zsh: set `DISABLE_AUTO_TITLE="true"`).
- **Notifications don't appear:** allow notifications for your terminal app in system settings, and check [terminal support](terminals.md).
- **Wrong notification style in tmux/SSH:** set `CNI_NOTIFY_STYLE`.
