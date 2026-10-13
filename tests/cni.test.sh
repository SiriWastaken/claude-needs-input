#!/usr/bin/env bash
# Pipes sample hook JSON into cni.sh and asserts on the emitted terminalSequence.
set -u
cd "$(dirname "$0")/.." || exit 1
fail=0
ESC=$'\033' BEL=$'\007'
# Detection must not pick up the developer's own terminal.
unset KITTY_WINDOW_ID WT_SESSION TERM_PROGRAM CNI_NOTIFY_STYLE CNI_BELL CNI_NOTIFY CNI_TITLE_PREFIX
export TERM=xterm-256color

ok() { echo "ok   $1"; }
bad() { echo "FAIL $1"; fail=1; }
seq_of() { jq -r .terminalSequence; }
check() { # name, haystack, needle, [expect: has|lacks]
  local found=lacks
  [[ $2 == *"$3"* ]] && found=has
  if [ "$found" = "${4:-has}" ]; then ok "$1"; else bad "$1"; fi
}

in='{"cwd":"/tmp/myproj","message":"Claude needs permission; to run rm\u0007 -rf"}'

out=$(./scripts/cni.sh notify <<<"$in" | seq_of)
check "notify sets title"        "$out" "${ESC}]2;⚠ NEEDS INPUT — myproj${BEL}"
check "notify sends OSC 777"     "$out" "${ESC}]777;notify;Claude Code — myproj;"
check "notify strips ; and BEL"  "$out" "permission to run rm -rf${BEL}"
check "notify rings bell"        "$out" "${BEL}${BEL}"

out=$(CNI_BELL=0 CNI_NOTIFY=0 ./scripts/cni.sh notify <<<"$in" | seq_of)
check "CNI_NOTIFY=0 drops notification" "$out" "777" lacks
check "CNI_BELL=0 keeps only title BEL" "$out" "${BEL}${BEL}" lacks

out=$(CNI_TITLE_PREFIX="HEY" ./scripts/cni.sh notify <<<"$in" | seq_of)
check "CNI_TITLE_PREFIX applies" "$out" "${ESC}]2;HEY — myproj${BEL}"

out=$(TERM_PROGRAM=iTerm.app ./scripts/cni.sh notify <<<"$in" | seq_of)
check "iTerm2 uses OSC 9"   "$out" "${ESC}]9;Claude Code — myproj: Claude needs"
out=$(KITTY_WINDOW_ID=1 ./scripts/cni.sh notify <<<"$in" | seq_of)
check "kitty uses OSC 99"   "$out" "${ESC}]99;;Claude Code — myproj: Claude needs"
out=$(TERM_PROGRAM=iTerm.app CNI_NOTIFY_STYLE=777 ./scripts/cni.sh notify <<<"$in" | seq_of)
check "CNI_NOTIFY_STYLE overrides detection" "$out" "${ESC}]777;notify;"

out=$(./scripts/cni.sh clear <<<"$in" | seq_of)
check "clear restores title" "$out" "${ESC}]2;✻ myproj${BEL}"

out=$(./scripts/cni.sh "done" <<<"$in" | seq_of)
check "done sets check title" "$out" "${ESC}]2;✔ myproj${BEL}"

out=$(CLAUDE_PROJECT_DIR=/x/fallback ./scripts/cni.sh clear <<<'{}' | seq_of)
check "falls back to CLAUDE_PROJECT_DIR" "$out" "✻ fallback"

./scripts/cni.sh bogus <<<"$in" 2>/dev/null; rc=$?
if [ "$rc" = 2 ]; then ok "bad mode exits 2"; else bad "bad mode exits 2 (got $rc)"; fi

if jq -e . hooks/hooks.json .claude-plugin/*.json >/dev/null; then ok "JSON valid"; else bad "JSON valid"; fi

exit $fail
