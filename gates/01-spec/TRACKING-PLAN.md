---
owner: Phòng Data
freshness: 2026-10-13
status: draft — CHƯA được Duy duyệt
---

# TRACKING-PLAN — presence-gate

**Thời gian đọc: ~3 phút.**

## TL;DR — ba dòng

| | Quyết định |
|---|---|
| **Analytics / mạng / SDK đo đạc** | `N/A — because` công cụ cá nhân ≤5 người, và sản phẩm đọc lịch sử trình duyệt của người dùng. Một sản phẩm đọc lịch sử duyệt web mà còn gửi số liệu đi đâu đó thì **tự phản bội lời hứa của chính nó**. · **Khi nào thì đo:** nếu phát cho >5 người ngoài Ringkas, viết lại file này từ đầu trước khi phát. |
| **Log cục bộ, chỉ trên máy người dùng** | **CÓ. Đây là đề xuất của phòng Data.** Lý do ở §1 |
| **`os_log` / unified logging** | **KHÔNG**, cho bất kỳ dòng nào có mã phòng. Lý do ở §4 |

## 1. Vì sao phải có log, dù đây là công cụ cá nhân

Lập luận chỉ có một bước, và nó đến thẳng từ Quyết định B:

```
   Quyết định B:  cổng phát hiện đã ở trong cuộc  ⇒  IM HẲN, không notify.
   Hệ quả:        một lần im NHẦM không tạo ra tab, không tạo ra thông báo,
                  không tạo ra bất kỳ dấu vết nào ở bất kỳ đâu.
   ⇒              Duy lỡ cuộc họp, và SẼ KHÔNG BAO GIỜ BIẾT là vì cái app này.
                  Anh ấy sẽ nghĩ mình quên.
```

Đây là loại lỗi tệ nhất trong các loại lỗi: **đắt, và im lặng.** Log là thứ duy nhất biến nó
thành thứ nhìn thấy được. Chi phí: ~2,4 dòng/ngày, ~900 dòng/năm. Không đáng để tiết kiệm.

Ngược lại — nếu Duy quyết **không** làm log, thì `SUCCESS-CRITERIA` cổng **G3 không bao giờ đạt
được**, và câu "ship an toàn" sẽ dựa trên 0 lỗi trên 1 mẫu. Phòng Data không ký vào đó.

## 2. Hợp đồng event — tên là hợp đồng, đổi tên là cắt đôi lịch sử

Định dạng: **JSONL**, mỗi dòng một object, chỉ nối thêm.
Vị trí: `~/Library/Application Support/<AppName>/presence-gate.jsonl` · quyền `0600`.

### `presence_gate.decided`
**Bắn khi:** mỗi lần cổng presence chạy bên trong `shouldConsiderActionEvent`, cho **mọi** sự
kiện sắp bắn — kể cả khi quyết định là `pass`. Ghi cả `pass` mới phân biệt được *"cổng chạy và
để qua"* với *"cổng không chạy"*.

| Trường | Kiểu | Ghi chú |
|---|---|---|
| `ts` | ISO 8601 có offset | thời điểm quyết định |
| `event_id` | string | id sự kiện lịch |
| `event_start` | ISO 8601 | T |
| `room` | string | mã phòng, **để nguyên, không hash** — xem §4 |
| `decision` | `"silence"` \| `"pass"` | |
| `tier` | `"t1"` \| `"t2"` \| `"none"` | tầng nào ra quyết định |
| `evidence_ts` | ISO 8601 \| null | lần ghé gần nhất làm bằng chứng |
| `evidence_age_s` | int \| null | `T − evidence_ts` |
| `window_s` | int | W đang dùng, để sau này biết cấu hình lúc đó |
| `lead_s` | int | `automaticEventJoinTime` lúc đó |
| `browser` | string | nguồn lịch sử đã đọc |
| `error` | string \| null | nếu detector lỗi ⇒ `decision` **bắt buộc** là `pass` |

### `presence_gate.tier2_probe`
**Bắn khi:** mỗi lần Tầng 2 chạy một lượt dò Accessibility.
Trường: `ts` · `app` · `ax_granted` (bool) · `signal` (`"leave_button"` \| `"meeting_menu"` \| null) · `ms`.

**Đây là nguồn duy nhất của metric M3.** Không có event này thì sáu mươi ngày sau không trả lời
được câu *"Tầng 2 có bao giờ có ích không"* — và câu đó là thứ quyết định có giữ quyền
Accessibility hay không.

### `presence_gate.missed`
**Bắn khi:** Duy tự ghi, bằng tay, khi phát hiện mình vừa lỡ một cuộc.
Trường: `ts` · `note`.
**Không viết UI, không viết code.** Một dòng `echo` là đủ:

```sh
echo '{"event":"presence_gate.missed","ts":"'$(date -Iseconds)'","note":"lỡ standup 16:30"}' \
  >> ~/Library/Application\ Support/<AppName>/presence-gate.jsonl
```

Đây là **nhãn ground-truth duy nhất ở runtime**. Không có nó thì log chỉ nói cổng đã quyết định
gì, không nói quyết định đó đúng hay sai.

### Quy tắc đổi hợp đồng
Thêm trường mới: tự do. **Đổi tên event hoặc đổi ý nghĩa một trường: ghi một dòng có ngày vào
cuối file này, không sửa tại chỗ** (Quy tắc 14).

## 3. "Xong" nghĩa là đã NHÌN THẤY SỐ — bài kiểm của S4

S4 **không được** kết luận từ việc đọc code. Ba việc phải làm bằng mắt:

| # | Việc | Đạt khi |
|---|---|---|
| 1 | Chạy app, chờ một cuộc họp thật đi qua | File tồn tại, có ≥1 dòng `decided` với `decision="pass"` |
| 2 | **Dựng kịch bản im lặng**: tự mở link phòng 6 phút trước giờ họp, để tab đó, chờ | Có ≥1 dòng `decided` với `decision="silence"`, `tier="t1"`, `evidence_age_s` trong khoảng 180–900 |
| 3 | Sau 2 ngày dùng thường | File có ≥4 dòng. **Nếu file không tồn tại ⇒ instrumentation hỏng, KHÔNG phải "không có gì xảy ra"** |

Việc #3 là cái bẫy kinh điển: code đúng, event bắn, không ai nhận, sáu tháng sau không có gì để
đọc. Với sản phẩm này nó tệ hơn — vì cổng im lặng vốn đã không nhìn thấy được.

## 4. Lời hứa của sản phẩm, và công cụ đo không được vi phạm

| Ràng buộc | Lý do |
|---|---|
| **Không mạng. Không SDK.** | Đã kiểm source tại `fdd799b`: **không có** Sentry/Firebase/analytics/crash reporter nào; `Package.swift` không khai dependency ngoài; chỉ 2 file gọi `URLSession` và cả hai là Google Calendar sync. **Giữ nguyên con số 2 đó.** |
| **Không `os_log`** cho dòng có mã phòng | `sysdiagnose` của macOS thu gom unified log archive, và các tiến trình khác đọc được. Mã phòng ra khỏi tay người dùng theo đường đó |
| **Không để trong `~/Library/Logs`** | Chưa xác minh được `sysdiagnose` có quét thư mục này không ⇒ chọn `Application Support` cho chắc |
| **Mã phòng ghi NGUYÊN, không hash** | Hash không thêm quyền riêng tư nào: **chính lịch sử Vivaldi trên cùng ổ đĩa đó đã có mã phòng ở dạng rõ**. Hash chỉ làm việc debug bất khả thi. Cái bảo vệ ở đây là *file không bao giờ rời máy*, không phải mã hoá |
| **Không tự xoá, không tự xoay vòng theo thời gian** | 900 dòng/năm. Nếu vượt 5 MB thì đổi tên thành `.1` và mở file mới — không xoá. Dữ liệu không hồi tố được |

## 5. Chưa xác minh được

| # | |
|---|---|
| 1 | `~/Library/Logs` có bị `sysdiagnose` quét không — **chưa kiểm**. Đề xuất ở §4 là đề phòng, không phải kết luận |
| 2 | Khi Duy phát `.app` cho đồng nghiệp, log của họ nằm trên máy họ. **Chưa có cách nào gom lại để đo** — và cố ý không làm. Hệ quả: `SUCCESS-CRITERIA` G3 chỉ xác minh được trên máy Duy |
| 3 | Chưa quyết tên app ⇒ `<AppName>` là placeholder. Apache-2.0 §6 cấm dùng tên "MeetingBar" cho bản phân phối (`ONE-PAGER.md`), nên đường dẫn log không được chứa chuỗi đó |
| 4 | Chưa biết sẽ có bao nhiêu dòng `tier2_probe` mỗi ngày — phụ thuộc nhịp poll của Tầng 2, mà Tầng 2 chưa được đặc tả. Nếu nó dò mỗi giây thì log sẽ phình. **Đặt trần: tối đa 1 dòng `tier2_probe` mỗi sự kiện mỗi lần bắn**, không ghi theo nhịp poll |
