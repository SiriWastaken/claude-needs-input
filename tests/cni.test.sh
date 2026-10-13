#!/usr/bin/env bash
# Pipes sample hook JSON into cni.sh and asserts on the emitted terminalSequence.
set -u
cd "$(dirname "$0")/.." || exit 1
fail=0
ESC=$'\033' BEL=$'\007'

seq_of() { jq -r .terminalSequence; }
check() { # name, haystack, needle, [expect: has|lacks]
  local found=lacks
  [[ $2 == *"$3"* ]] && found=has
  if [ "$found" = "${4:-has}" ]; then echo "ok   $1"; else echo "FAIL $1"; fail=1; fi
}

in='{"cwd":"/tmp/myproj","message":"Claude needs permission; to run rm\u0007 -rf"}'

out=$(./scripts/cni.sh notify <<<"$in" | seq_of)
check "notify sets title"        "$out" "${ESC}]2;⚠ NEEDS INPUT — myproj${BEL}"
check "notify sends OSC 777"     "$out" "${ESC}]777;notify;Claude Code — myproj;"
check "notify strips ; and BEL"  "$out" "permission to run rm -rf${BEL}"
check "notify rings bell"        "$out" "${BEL}" has

out=$(CNI_BELL=0 CNI_NOTIFY=0 ./scripts/cni.sh notify <<<"$in" | seq_of)
check "CNI_NOTIFY=0 drops OSC 777" "$out" "777" lacks
check "CNI_BELL=0 keeps only title BEL" "$out" "${BEL}${BEL}" lacks

out=$(./scripts/cni.sh clear <<<"$in" | seq_of)
check "clear restores title" "$out" "${ESC}]2;✻ myproj${BEL}"

out=$(./scripts/cni.sh done <<<"$in" | seq_of)
check "done sets check title" "$out" "${ESC}]2;✔ myproj${BEL}"

./scripts/cni.sh bogus <<<"$in" 2>/dev/null; rc=$?
[ "$rc" = 2 ] && echo "ok   bad mode exits 2" || { echo "FAIL bad mode exits 2 (got $rc)"; fail=1; }

jq -e . hooks/hooks.json .claude-plugin/*.json >/dev/null && echo "ok   JSON valid" || { echo "FAIL JSON valid"; fail=1; }

exit $fail
