#!/usr/bin/env bash
# claude-needs-input: emit a terminalSequence for a Claude Code hook.
# Usage: cni.sh notify|clear|done   (hook JSON on stdin)
# Env:   CNI_BELL=0, CNI_NOTIFY=0 disable bell / desktop notification; CNI_TITLE_PREFIX overrides "⚠ NEEDS INPUT".
set -u
command -v jq >/dev/null 2>&1 || exit 0 # no jq: do nothing rather than break the session

mode=${1:-}
input=$(cat)
cwd=$(jq -r '.cwd // empty' <<<"$input" 2>/dev/null)
project=$(basename "${cwd:-${CLAUDE_PROJECT_DIR:-claude}}")

# OSC fields are ';'-separated and end at BEL/ESC, so strip those and other control chars.
clean() { printf '%s' "$1" | tr -d '\000-\037\177;' | cut -c1-200; }

seq=
case $mode in
  notify)
    msg=$(clean "$(jq -r '.message // "Claude needs your input"' <<<"$input" 2>/dev/null)")
    seq=$(printf '\033]2;%s — %s\007' "${CNI_TITLE_PREFIX:-⚠ NEEDS INPUT}" "$(clean "$project")")
    [ "${CNI_NOTIFY:-1}" = 0 ] || seq+=$(printf '\033]777;notify;Claude Code — %s;%s\007' "$(clean "$project")" "$msg")
    [ "${CNI_BELL:-1}" = 0 ] || seq+=$(printf '\007')
    ;;
  clear) seq=$(printf '\033]2;✻ %s\007' "$(clean "$project")") ;;
  done) seq=$(printf '\033]2;✔ %s\007' "$(clean "$project")") ;;
  *) echo "usage: cni.sh notify|clear|done" >&2; exit 2 ;;
esac

jq -nc --arg seq "$seq" '{terminalSequence: $seq}'
