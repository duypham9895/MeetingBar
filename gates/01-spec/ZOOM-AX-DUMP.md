---
stage: 01-spec
date: 2026-10-13
status: CHỜ ĐO — chặn Lát 5 (Tầng 2)
---

# ZOOM-AX-DUMP — chưa đo được, và đây là lý do

## Câu hỏi duy nhất

**Tiêu đề cửa sổ Zoom khi ĐANG TRONG cuộc họp có mang meeting ID không?**

Nếu **có** ⇒ Tầng 2 thoả được Quyết định B (khớp danh tính cuộc họp).
Nếu **không** ⇒ Tầng 2 chỉ chứng minh được *"đang ở trong MỘT cuộc Zoom"*, **không** thoả
Quyết định B. Khi đó **DỪNG và leo lên Duy** — tuyệt đối không tự hạ chuẩn xuống "chỉ cần
hiện diện", vì đó là sửa Quyết định B sau lưng người đã ra quyết định đó.

## Đã đo được (Zoom 7.1.9, macOS 26.5.1, 2026-10-13) — lúc IDLE

```
AXWindows = 1 · title "Zoom Workplace" · AXStandardWindow
AXMenuBar: 5 menu — Apple · Zoom Workplace · Edit · Window · Help     ← KHÔNG có menu "Meeting"
tiến trình: zoom.us + caphost        ← KHÔNG có CptHost
```

Hai điều này **bác screenpipe**, vốn khẳng định Zoom *"does NOT expose AXWindow"* và rằng menu
`Meeting` *"exists even when Zoom is idle"*. Cả hai đều sai ở phiên bản này.

## Vì sao chưa đo được lúc ĐANG HỌP

Duy có **0 cuộc Zoom trong 30 ngày**. Không có dữ liệu tự nhiên nào để quan sát.

## Cách gỡ — 15 phút, cần Duy

1. Duy mở Zoom, bấm **New Meeting** (phòng cá nhân, không mời ai, không ai được thông báo).
2. Claude chạy `probe/AXBrowser.swift` đã có sẵn + dump đầy đủ cây AX của `zoom.us`.
3. Tìm trong cây: meeting ID dạng `\d{9,11}` ở bất kỳ `AXTitle` / `AXValue` / `AXDescription` nào.
4. Duy bấm End Meeting.

**Không có bước này thì Lát 5 không được bắt đầu** — xem `ACCEPTANCE.md`.
