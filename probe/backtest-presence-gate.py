#!/usr/bin/env python3 -I
"""Backtest cổng presence trên 30 ngày dữ liệu THẬT, trước khi viết dòng Swift nào.

Trả lời đúng một câu: nếu cổng đã chạy suốt 30 ngày qua, nó im lặng bao nhiêu lần,
và trong đó bao nhiêu lần là IM NHẦM (⇒ lỡ họp)?

Chạy:  python3 -I probe/backtest-presence-gate.py <events.json> [W] [LEAD]
  events.json  output của Google Calendar list_events
  W            cửa sổ "đã vào", giây (mặc định 600 — PM §A2)
  LEAD         automaticEventJoinTime thật của Duy, giây (mặc định 180)

Hai bẫy đã trả giá, đừng gỡ:
  · regex mã phòng phải CHẶT — match lỏng nuốt /home và làm cổng im cả ngày
  · visit_duration chỉ dùng ở ĐÂY, không bao giờ ở runtime: tab đang mở có duration = 0
"""
import json, os, re, shutil, sqlite3, sys, tempfile
from datetime import datetime, timezone

ROOM = re.compile(r"\b([a-z]{3}-[a-z]{4}-[a-z]{3})\b")
CHROMIUM_EPOCH = 11644473600  # giây giữa 1601-01-01 và 1970-01-01

BROWSERS = {
    "Vivaldi": "Vivaldi/Default/History",
    "Chrome":  "Google/Chrome/Default/History",
    "Brave":   "BraveSoftware/Brave-Browser/Default/History",
}

def doc_lich_su():
    """{room: [(epoch, dwell_sec, browser)]}. Mọi lỗi -> bỏ qua trình duyệt đó, không ném."""
    base = os.path.expanduser("~/Library/Application Support")
    visits = {}
    for ten, rel in BROWSERS.items():
        src = os.path.join(base, rel)
        if not os.path.exists(src):
            print(f"  · {ten:8} không có file, bỏ qua"); continue
        with tempfile.TemporaryDirectory() as td:
            cp = os.path.join(td, "h.db")
            try:
                shutil.copy2(src, cp)          # KHÔNG mở DB gốc: trình duyệt giữ khoá
                con = sqlite3.connect(f"file:{cp}?mode=ro", uri=True)
                rows = con.execute(
                    "SELECT u.url, v.visit_time, v.visit_duration "
                    "FROM visits v JOIN urls u ON v.url = u.id"
                ).fetchall()
                con.close()
            except Exception as e:
                print(f"  · {ten:8} lỗi đọc ({type(e).__name__}), bỏ qua"); continue
        n = 0
        for url, vt, dur in rows:
            if "meet.google.com" not in url: continue
            path = url.split("meet.google.com", 1)[1].split("?")[0]
            m = ROOM.search(path)             # CHẶT, và chỉ trong path
            if not m: continue
            visits.setdefault(m.group(1), []).append(
                (vt / 1e6 - CHROMIUM_EPOCH, (dur or 0) / 1e6, ten))
            n += 1
        print(f"  · {ten:8} {n:4} lượt vào phòng")
    return visits

def doc_lich(path):
    """[(start_epoch, room, summary)] — dedupe theo event id."""
    data = json.load(open(path))
    seen, evs = set(), []
    for e in data.get("events", []):
        eid = e.get("id")
        if eid in seen: continue
        st = (e.get("start") or {}).get("dateTime")
        if not st: continue                   # all-day: không có giờ, bỏ
        m = ROOM.search(json.dumps(e, ensure_ascii=False))
        if not m: continue
        seen.add(eid)
        evs.append((datetime.fromisoformat(st).timestamp(), m.group(1), e.get("summary", "?")))
    return sorted(evs)

def main():
    ev_path = sys.argv[1]
    W    = int(sys.argv[2]) if len(sys.argv) > 2 else 600
    LEAD = int(sys.argv[3]) if len(sys.argv) > 3 else 180

    print(f"W = {W}s ({W//60} phút) · LEAD = {LEAD}s\n")
    visits = doc_lich_su()
    evs = doc_lich(ev_path)
    print(f"\n{len(evs)} cuộc họp có giờ + có mã phòng\n")

    im, qua, im_nham = 0, 0, []
    for t, room, ten in evs:
        # cổng chạy lúc T-LEAD; nó thấy các lượt vào trong [T-LEAD-W, T-LEAD]
        hits = [v for v in visits.get(room, []) if t - LEAD - W <= v[0] <= t - LEAD]
        if not hits:
            qua += 1; continue
        im += 1
        # IM NHẦM: mọi lượt ghé trong cửa sổ đều đã KẾT THÚC trước giờ họp
        # (dwell > 0 nghĩa là tab đã đóng — chỉ tin được khi backtest)
        con_mo = [v for v in hits if v[1] == 0 or v[0] + v[1] > t]
        if not con_mo:
            im_nham.append((ten, room, [(round(t - v[0]), round(v[1])) for v in hits]))

    print(f"IM LẶNG : {im:3}/{len(evs)}   ({im/max(len(evs),1)*100:.0f}%)")
    print(f"CHO QUA : {qua:3}/{len(evs)}")
    print(f"\nG1 — IM NHẦM (⇒ LỠ HỌP): {len(im_nham)}   ← ngưỡng ship là 0")
    for ten, room, chi_tiet in im_nham:
        print(f"   ✗ {ten[:48]:48} {room}  (trước {chi_tiet[0][0]}s, dwell {chi_tiet[0][1]}s)")
    print("\nĐẠT G1" if not im_nham else "\nKHÔNG ĐẠT G1 — không được ship")

if __name__ == "__main__":
    main()
