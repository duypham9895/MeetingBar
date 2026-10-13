---
stage: 00-discovery
date: 2026-10-13
status: pass-with-conditions
---

# LEGAL-SCREEN — presence-gate

> Quy tắc 4 của xưởng: *nêu được giấy phép trong một dòng, từ nguồn gốc, hoặc không dùng.*
> Mọi dòng dưới đây đọc từ nguồn gốc, không qua agent trung gian.

## 1. Mã nguồn gốc — MeetingBar

| | |
|---|---|
| Giấy phép | **Apache License 2.0** |
| Nguồn gốc | [`leits/MeetingBar/LICENSE`](https://github.com/leits/MeetingBar/blob/master/LICENSE) — tự đọc 2026-10-13 |
| Fork + sửa + phân phối bản sửa đổi | **Được** |
| Copyleft | **Không có** |

**Nghĩa vụ phải làm, không được quên:**

1. Giữ nguyên `LICENSE` và mọi copyright/patent/trademark notice có sẵn (§4a, §4c).
2. **Ghi rõ đã sửa gì** — §4b: *"carry prominent notices stating that You changed the files."*
   ⇒ mỗi file Swift bị sửa phải có một dòng ghi chú ở đầu.
3. **§6 Trademarks** — *"This License does not grant permission to use the trade names,
   trademarks, service marks, or product names of the Licensor."*
   ⇒ **bản .app phát cho đồng nghiệp KHÔNG được mang tên "MeetingBar".** Repo fork giữ tên là
   bình thường; cái bị cấm là sản phẩm phân phối. **Tên mới chưa chọn — việc của Duy.**

## 2. Điều khoản dịch vụ của các nền tảng họp — RỦI RO CÒN MỞ

Detector sẽ **đọc** cây Accessibility của Zoom / Teams / trình duyệt. Nghiêm ngặt chỉ đọc,
không inject, không tự động hoá hành vi.

**Chưa ai soi ToS của Zoom, Microsoft hay Google về việc này.** ZoomStat tự đặt ranh giới
*"strictly read-only, no injection"* — nhưng đó là quy tắc của họ, **không phải điều khoản của
Zoom**. Phải soi trước S3.

Giảm nhẹ rủi ro, đáng ghi lại: phân phối nội bộ ≤5 người, không bán, không quảng bá, không
qua App Store. Bề mặt rủi ro thực tế rất nhỏ — nhưng *nhỏ* không phải *đã kiểm*.

## 3. Mã tham chiếu định chép

| Nguồn | Dùng để làm gì | Giấy phép | Trạng thái |
|---|---|---|---|
| [screenpipe `profiles.rs`](https://github.com/screenpipe/screenpipe/blob/main/crates/screenpipe-engine/src/meeting_watcher/shared/profiles.rs) | bảng tín hiệu AX per-platform | **CHƯA KIỂM** | ⛔ **không chép một dòng nào trước khi đọc LICENSE của screenpipe** |
| ZoomStat `RESEARCH.md` | kiến thức, không phải code | không áp dụng (đọc để học) | ✅ |

**Đây là món nợ pháp lý rõ ràng nhất hiện tại.** Mũi research mô tả screenpipe là "MIT-ish" —
*-ish* không phải một giấy phép. Phải mở file LICENSE ra đọc trước khi S3 bắt đầu.

## 4. Phân phối

| | |
|---|---|
| Apple Developer Program | **không bắt buộc** cho (b) — Duy tự build, tự đưa file |
| Hệ quả nếu không ký | Đồng nghiệp phải vào *System Settings → Privacy & Security → Open Anyway* + mật khẩu admin. macOS 15+ đã **bỏ** Control-click override |
| Nếu muốn cài sạch | 99 USD/năm + Developer ID + hardened runtime + notarize + staple |
| Homebrew | **đã đóng** — Homebrew 5.0.0 khai tử cask không ký, `--no-quarantine` deprecated |

## 5. Quyền riêng tư

App sẽ đọc tiêu đề cửa sổ và cây UI của **mọi app** khi quét. Dù không lưu và không gửi đi
đâu, đây là bề mặt nhạy cảm.

**Ràng buộc tự đặt, phải giữ ở S3:** detector chỉ chạy **trong cửa sổ ±N phút quanh một sự
kiện lịch**, không quét liên tục; chỉ đọc các app trong danh sách nền tảng đã biết; không
ghi log nội dung cửa sổ ra đĩa.

## 6. Ghi chú phương pháp

ECC **không có** năng lực pháp lý nào — đã soát 2026-10-11
(`grep -rilE 'copyright|legal review|takedown|dmca'` chỉ trả về vài file LICENSE và một skill
tra USPTO). Nên mục này là tự dựng, và **chưa qua luật sư nào**.

---

## ĐÍNH CHÍNH 2026-10-13 — screenpipe: ĐÃ KIỂM, và câu trả lời là KHÔNG

`LICENSE.md`: **"Screenpipe Commercial License — Copyright (c) 2024-2026 Negentropy Labs,
Inc. (dba Screenpipe). All rights reserved."** §5 liệt kê *"Prohibited Without a Commercial
License"*.

**Không phải MIT. Không "MIT-ish". Không chép một dòng nào.** Bảng tín hiệu AX phải tự dò
lại — cộng công việc thật vào S2/S3. Đọc để học thì được.

Món nợ ở §3 bản trên: **đã trả, kết quả là cấm.**
