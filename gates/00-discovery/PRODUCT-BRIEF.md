---
stage: 00-discovery
date: 2026-10-13
status: in-progress
method: Workflow 6 mũi + phản bác từng mũi (tự kiểm phía tác giả, KHÔNG phải review)
---

# PRODUCT-BRIEF — presence-gate

## GO / NO-GO

**GO, với phạm vi đã thu hẹp:** công cụ cá nhân cho ≤5 người, fork không sandbox, dùng
Accessibility API. **NO-GO cho phương án sản phẩm công khai** — bằng chứng nhu cầu quá mỏng
và sandbox cắt mất chính tính năng cần làm.

## Vấn đề

MeetingBar auto-mở link họp theo timer, vô điều kiện. Ba guard hiện có trong
`NotificationActionRunner.shouldConsiderActionEvent` đều hỏi về **ý định** người dùng
(đã gạt đi chưa · sự kiện huỷ chưa · đã từ chối lời mời chưa). Không guard nào hỏi về
**hiện thực**: người dùng lúc này đang ở đâu. Đó là khoảng trống.

## Bằng chứng nhu cầu — YẾU, và phải ghi lại là yếu

| Đo | Số |
|---|---|
| Sao / tổng issue của MeetingBar | 5.367 / 541 |
| Issue mô tả đúng nỗi đau này | **2** |
| Reaction + comment trên issue còn mở (#714, từ 2024-04-10) | **0 / 0** |
| Issue mới 2025–2026 nhắc lại | **0** / 92 |
| Workaround đúng hướng tìm được | **0** |
| Workaround NGƯỢC hướng | 3 người downgrade + 1 người viết script để auto-join mạnh tay hơn |

Maintainer, [#664](https://github.com/leits/MeetingBar/issues/664), 2024-03-23:
> "this is an intended behavior so an accidental click or shortcut does not prevent the
> expected auto-join… I rarely get asked about this behavior and I don't see a better
> solution here."

⇒ Theo `docs/lessons.md` (*"workaround là bằng chứng, lời phàn nàn thì không"*): **đây gần như
là ngứa của riêng Duy.** Đó là lý do phạm vi thu về công cụ cá nhân, không phải sản phẩm.

## Bức tường kiến trúc

```
MeetingBar chạy TRONG App Sandbox — cả bản App Store lẫn bản GitHub
  (đo: codesign -d --entitlements → com.apple.security.app-sandbox=true)
        │
Apple cấm hẳn Accessibility API trong sandbox
  (Apple DTS: "We do not support the Accessibility APIs in sandboxed apps")
        │
Accessibility là đường DUY NHẤT chạy trên cả Meet + Zoom + Teams
        │
   ⇒ sandbox/App Store  XOR  tính năng này. Không có cả hai.
```

Quyết định A (2026-10-13) chọn bỏ sandbox.

## Bảng tín hiệu từng nền tảng

| Nền tảng | Tín hiệu khả dụng | Có suy ra ĐƯỢC danh tính cuộc họp không |
|---|---|---|
| **Google Meet** (browser) | nút `Leave call` trong cây AX; mã phòng trong URL tab | **CÓ** — mã `xxx-xxxx-xxx` khớp chính xác với URL trong sự kiện lịch |
| **Zoom** | chỉ AX. Không local API, không port, DB SQLCipher, không AppleScript (`sdef` lỗi -192) | **CHƯA BIẾT** — tiêu đề cửa sổ báo cáo là `Zoom Meeting`, chung chung, không mang ID |
| **Teams** | chỉ AX. WebSocket `:8124` **Microsoft gỡ vĩnh viễn 30/06/2026** (MC1266901) | **CÓ THỂ** — tiêu đề cửa sổ thường mang chủ đề họp, khớp mờ với tiêu đề sự kiện |
| **Slack Huddles** | AX, nhưng Electron phải bật `AXManualAccessibility` trước | không áp dụng |
| **Discord** | RPC chính thức cổng 6463–6472, còn sống | không áp dụng |
| **Mọi nền tảng** | cờ camera/mic đang chạy — **zero permission**, đo được trên máy Duy | **KHÔNG** — chỉ biết "đang trong MỘT cuộc gọi" |

Quy tắc tín hiệu, chép từ [screenpipe `profiles.rs`](https://github.com/screenpipe/screenpipe/blob/main/crates/screenpipe-engine/src/meeting_watcher/shared/profiles.rs)
(đã trả giá bằng hàng chục bug thật):
> "only leave/hangup/end-call buttons are standalone signals. **Mute is NOT included** because
> it appears in pre-join lobbies."

## Hệ quả của Quyết định B — phần phải đọc kỹ

Quyết định B: *"detect thấy đang ở trong ĐÚNG cuộc họp sắp nhắc ⇒ im hẳn."*

Đây là **ngữ nghĩa đúng**, nhưng nó **khó hơn hẳn** phương án *"đang trong bất kỳ cuộc gọi nào
⇒ im"*. Nó đòi **khớp danh tính cuộc họp**, không chỉ phát hiện hiện diện. Hệ quả:

```
   Google Meet   ✅ chạy được      mã phòng trong URL khớp chính xác
   Teams         ⚠️  có thể được   khớp mờ theo tiêu đề — chưa đo
   Zoom          ❌ CHƯA CÓ ĐƯỜNG  biết "đang họp", không biết "họp nào"
```

**Zoom là nền tảng Duy sẽ dùng nhiều thứ hai, và Quyết định B hiện không phục vụ được nó.**
Cần một quyết định bổ sung cho trường hợp *"biết đang họp nhưng không biết họp nào"* —
xem câu hỏi đang treo ở cuối file.

## Chưa xác minh được

| Câu hỏi | Vì sao chặn | Gỡ bằng |
|---|---|---|
| Zoom 7.1.9 có phơi `AXWindow` cho cửa sổ **meeting** không, và tiêu đề có mang meeting ID không | Quyết định kiến trúc detector Zoom. screenpipe nói KHÔNG (chỉ `AXMenuBar`), ZoomStat nói CÓ — **hai nguồn bất đồng, Quy tắc 12 cấm gọi trọng tài, phải đo** | Duy vào một cuộc Zoom thật, chạy script đọc cây AX |
| `CptHost` có mặt ở mọi cuộc Zoom hay chỉ khi share màn hình | Tên gợi ý "Capture" ⇒ có thể vô dụng. Đã chứng minh được vế âm (không có khi idle) trên máy Duy | Vào cuộc Zoom, camera tắt, không share, chạy `pgrep` |
| Tiêu đề tab Google Meet có khác giữa phòng chờ và đã vào phòng không | Nếu khác ⇒ có đường rẻ hơn hẳn, khỏi đụng cây AX | Mở một cuộc Meet, đọc tiêu đề ở hai trạng thái |
| Zoom **Plugin SDK** có trả trạng thái in-meeting + meeting ID không | Nếu có ⇒ biến nền tảng khó nhất thành chắc nhất, hợp pháp, không scrape UI | Docs render bằng JS — phải mở trình duyệt thật |
| Bỏ sandbox có làm hỏng gì khác trong MeetingBar không (EventKit, notifications) | Chưa ai thử | Build thử sau khi gỡ entitlement |
| Phép đo microphone chưa hợp lệ | Tiến trình thử đã thừa kế quyền Mic từ terminal. Chỉ **camera** là phép đo sạch | Đo lại từ app không có quyền sẵn |

## Phương pháp — nói rõ giới hạn

6 mũi research song song, mỗi mũi bị một phiên khác cố bác bỏ. **Đó là tự kiểm phía tác giả,
không phải review** — cùng vendor, cùng priors, không có verifier bên ngoài nào chạy.
Codex đã huỷ 2026-10-10.

Hai kết luận quan trọng nhất của S0 **không** đến từ research mà đến từ **đọc nguồn gốc**:
giấy phép (đọc thẳng file `LICENSE`) và điểm chèn `shouldConsiderActionEvent` (đọc thẳng code).
Ở cả hai chỗ, hai mũi research đã lệch nhau và nguồn gốc giải quyết được.
