---
stage: 01-spec
date: 2026-10-13
status: ĐÃ ĐO 2026-10-13 — kết quả XẤU cho Tầng 2
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

---

# ĐÃ ĐO — 2026-10-13 21:18, Zoom 7.1.9, macOS 26.5.1

Claude tự dựng cuộc họp (nút `Start new meeting` qua AX, phòng cá nhân, **không mời ai**),
đo, rồi kết thúc và đóng Zoom. Tổng thời gian trong cuộc: ~20 giây.

## Kết quả

```
CỬA SỔ [0]  AXTitle = <nil>
CỬA SỔ [1]  AXTitle = "Duy Pham's Zoom Meeting"      ← cửa sổ cuộc họp
              AXButton.desc = "Audio, turn off, currently unmuted"
CỬA SỔ [2]  AXTitle = "Zoom Workplace"               ← cửa sổ chính, vẫn còn

MEETING ID  (\d{9,11}) trong TOÀN BỘ cây AX:  KHÔNG CÓ
tiến trình:  caphost        CptHost: KHÔNG CÓ — kể cả khi ĐANG HỌP
```

## Ba kết luận

**① HIỆN DIỆN: phát hiện được.** Một cửa sổ thứ hai xuất hiện, tách khỏi "Zoom Workplace".
Có mặt / không có mặt là tín hiệu sạch.

**② DANH TÍNH: KHÔNG phát hiện được — với cuộc họp cá nhân (PMI).** Tiêu đề là tên phòng
(`"Duy Pham's Zoom Meeting"`), không phải meeting ID, và **không có số nào dạng meeting ID ở
bất kỳ đâu trong cây AX.**

⇒ **Tầng 2 KHÔNG thoả được Quyết định B cho cuộc Zoom ad-hoc.** Nó chứng minh được
*"đang ở trong MỘT cuộc Zoom"*, không chứng minh được *"đang ở trong ĐÚNG cuộc này"*.
Theo đúng chỉ dẫn của PM: **không tự hạ chuẩn xuống "chỉ cần hiện diện"** — đó là sửa
Quyết định B sau lưng người đã ra nó.

**③ `pgrep CptHost` ĐÃ CHẾT.** Heuristic được trích dẫn khắp nơi (brunerd 2022, Home Assistant,
nhiều plugin Stream Deck) dựa vào tiến trình `CptHost`. Trên Zoom 7.1.9 nó **không xuất hiện
kể cả khi đang họp** — chỉ có `caphost`, và `caphost` có mặt cả lúc idle. Heuristic này
**false-positive 100%** nếu dùng `caphost`, và **false-negative 100%** nếu dùng `CptHost`.
Gạch khỏi mọi bảng phương án.

## Chưa đo được — và đây là nhánh còn sống của Tầng 2

Tôi đo **cuộc họp cá nhân (PMI)**, vốn không có chủ đề. Nhưng auto-join **chỉ bắn cho sự kiện
lịch**, và một cuộc Zoom **đặt lịch** thường mang **chủ đề** làm tiêu đề cửa sổ — thứ khớp mờ
được với `summary` của sự kiện.

**Tôi đã đo sai ca.** Ca đáng đo là: đặt một cuộc Zoom có chủ đề, vào, rồi đọc tiêu đề cửa sổ.
Nếu tiêu đề = chủ đề ⇒ Tầng 2 **có** đường thoả Quyết định B qua khớp mờ.
Cho tới khi đo được, **Tầng 2 ở trạng thái: hiện diện CÓ, danh tính CHƯA RÕ.**
