#!/usr/bin/env bash
# needs-input: emit a terminalSequence for a Claude Code hook.
# Usage: cni.sh notify|clear|done   (hook JSON on stdin)
# Env:   CNI_BELL=0, CNI_NOTIFY=0 disable bell / desktop notification; CNI_TITLE_PREFIX overrides "⚠ NEEDS INPUT";
#        CNI_NOTIFY_STYLE=777|9|99 forces the notification escape (default: detected from the terminal).
set -u
command -v jq >/dev/null 2>&1 || exit 0 # no jq: do nothing rather than break the session

mode=${1:-}
input=$(cat)
cwd=$(jq -r '.cwd // empty' <<<"$input" 2>/dev/null)

# OSC fields are ';'-separated and end at BEL/ESC, so strip those and other control chars.
clean() { printf '%s' "$1" | tr -d '\000-\037\177;' | cut -c1-200; }
project=$(clean "$(basename "${cwd:-${CLAUDE_PROJECT_DIR:-claude}}")")

# Each terminal family listens for a different notification OSC.
notify_style() {
  if [ -n "${CNI_NOTIFY_STYLE:-}" ]; then echo "$CNI_NOTIFY_STYLE"
  elif [ -n "${KITTY_WINDOW_ID:-}" ] || [ "${TERM:-}" = xterm-kitty ]; then echo 99
  elif [ -n "${WT_SESSION:-}" ] || [[ ${TERM_PROGRAM:-} =~ ^(iTerm\.app|WezTerm)$ ]]; then echo 9
  else echo 777
  fi
}

seq=
case $mode in
  notify)
    msg=$(clean "$(jq -r '.message // "Claude needs your input"' <<<"$input" 2>/dev/null)")
    seq=$(printf '\033]2;%s — %s\007' "${CNI_TITLE_PREFIX:-⚠ NEEDS INPUT}" "$project")
    if [ "${CNI_NOTIFY:-1}" != 0 ]; then
      case $(notify_style) in
        9) seq+=$(printf '\033]9;Claude Code — %s: %s\007' "$project" "$msg") ;;
        99) seq+=$(printf '\033]99;;Claude Code — %s: %s\007' "$project" "$msg") ;;
        *) seq+=$(printf '\033]777;notify;Claude Code — %s;%s\007' "$project" "$msg") ;;
      esac
    fi
    [ "${CNI_BELL:-1}" = 0 ] || seq+=$(printf '\007')
    ;;
  clear) seq=$(printf '\033]2;✻ %s\007' "$project") ;;
  done) seq=$(printf '\033]2;✔ %s\007' "$project") ;;
  *) echo "usage: cni.sh notify|clear|done" >&2; exit 2 ;;
esac

jq -nc --arg seq "$seq" '{terminalSequence: $seq}'
