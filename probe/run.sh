#!/usr/bin/env bash
# S0.5 — chạy MỘT LẦN khi đang ở trong một cuộc họp thật.
#   ./probe/run.sh
set -uo pipefail
cd "$(dirname "$0")/.."

echo "════ S0.5 PROBE — $(date '+%F %T') ════"
sw_vers | tr '\n' ' '; echo

echo
echo "── Q2  tiến trình Zoom ─────────────────────────────────────"
ps -axo pid,comm | grep -iE 'zoom|cpthost|caphost' | grep -v grep || echo "  (không có tiến trình Zoom nào)"
echo "  pgrep CptHost (phân biệt hoa thường!): $(pgrep -x CptHost >/dev/null && echo CÓ || echo KHÔNG)"
echo "  pgrep caphost:                         $(pgrep -x caphost >/dev/null && echo CÓ || echo KHÔNG)"

echo
echo "── Q3  tab trình duyệt (cần quyền Automation — sẽ hỏi 1 lần) ──"
for B in "Google Chrome" "Safari" "Arc"; do
  pgrep -qf "$B" || continue
  echo "  ▸ $B"
  osascript -e "tell application \"$B\" to get {URL, name} of tabs of windows" 2>&1 \
    | tr ',' '\n' | grep -iE 'meet\.google|zoom\.us|teams\.|webex|Meet|Huddle' | sed 's/^ */      /' \
    || echo "      (không tab họp nào, hoặc bị từ chối quyền)"
done

echo
echo "── Q1 + Q4  biên dịch và chạy Probe.swift ──────────────────"
if swiftc -O -o /tmp/mb-probe probe/Probe.swift 2>&1; then /tmp/mb-probe; else echo "  biên dịch THẤT BẠI"; fi

echo
echo "════ HẾT. Dán toàn bộ output này lại cho Claude. ════"
