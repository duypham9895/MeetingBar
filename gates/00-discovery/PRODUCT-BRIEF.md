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

⇒ Theo `../docs/lessons.md` (*"workaround là bằng chứng, lời phàn nàn thì không"*): **đây gần như
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

---

# ĐÍNH CHÍNH — 2026-10-13, sau vòng phản bác

> Quy tắc 14: không sửa tại chỗ. Mục này ghi đè các kết luận ở trên.
> Nguồn: vòng phản bác của chính workflow S0 — **tự kiểm phía tác giả, cùng vendor cùng
> priors, không có verifier bên ngoài nào chạy.**

## Đ1 — screenpipe KHÔNG phải MIT. Nó là giấy phép THƯƠNG MẠI. ⛔

`LICENSE.md` của screenpipe, nguyên văn:
> "# Screenpipe Commercial License / Copyright (c) 2024-2026 Negentropy Labs, Inc.
> (dba Screenpipe). All rights reserved." — §5 *"Prohibited Without a Commercial License"*

**Hệ quả:** bảng profile per-platform mà bản trên gọi là *"món quà lớn nhất cho S2"* **không
chép được một dòng nào.** Mũi research mô tả nó là "MIT-ish" — *-ish* không phải một giấy
phép, và lần này nó sai hẳn. Bảng tín hiệu AX phải **tự dò lại từ đầu**, cộng thêm công việc
thật vào S2/S3. Đọc screenpipe để **học** thì được; chép thì không.

## Đ2 — Cờ camera KHÔNG đọc được trong App Sandbox. Và nó hỏng theo kiểu tệ nhất.

Phép đo có đối chứng: trong App Sandbox với **đúng** bộ entitlement của MeetingBar, CMIO trả
về **0 camera** — `OSStatus=0`, `size=0`. **API không chết, nó trả rỗng.**

```
   ⇒ code chạy, không crash, không log lỗi, và LUÔN kết luận "chưa join".
      Một cổng presence luôn mở — tức là không có cổng nào.
```

Phép đo của tôi ở trên (`authorizationStatus=0` trước và sau) chạy trên binary **không**
sandbox, nên nó đúng nhưng **không áp dụng được cho app sandbox**.

**Điều này làm Quyết định A ĐÚNG HƠN, không sai đi:** phương án dự phòng *"giữ sandbox, chịu
detect thô"* vừa bị đo là chết. Không còn đường lùi về sandbox nữa.

## Đ3 — Bằng chứng nhu cầu: bảng ở trên có ba lỗi, tôi đã nói quá

| Tôi viết | Thực tế |
|---|---|
| "chỉ **2** issue trong 541" | **≥3** — bỏ sót [#628](https://github.com/leits/MeetingBar/issues/628) *"Meeting bar opens meetings multiple times"* (2023-06-22) |
| "#714 có 0 reaction ⇒ gần như không ai quan tâm" | **Thiếu base rate.** Trong cohort 106 issue năm 2024: **37% có đúng 0 reaction**. #714 nằm ở **mode** của phân phối, không phải ngoại lệ. Kết luận cũ là suy diễn xa hơn nguồn |
| "3 người downgrade để lấy lại auto-join" (cụm workaround ngược hướng) | **Sai do cắt trích dẫn.** shimonacarvalho tự rút lại trong **cùng một comment**: *"Going to downgrade. Oh wait I see a 'Show a fullscreen notification' on the general tab."* |

**Kết luận sau đính chính:** bằng chứng vẫn **mỏng**, nhưng *"gần như ngứa của riêng Duy"* là
**nói quá**. Câu đúng: *ba người lạ đã báo cáo nó; không ai vận động cho nó; upstream đã từ
chối.* Điều đó vẫn đủ để chọn công cụ-cá-nhân thay vì sản phẩm — nhưng vì **upstream đóng
cửa**, không phải vì **không ai đau**.

## Đ4 — Hai đính chính kỹ thuật nhỏ hơn

- `com.apple.security.accessibility` **không tồn tại như một entitlement**. Apple DTS (Quinn),
  thread 805556: *"It isn't a thing."* Kết luận "AX không chạy trong sandbox" vẫn đúng, nhưng
  lý do tôi viết thì sai.
- MeetingBar có **hai** dialog quyền, không phải một: nó gọi
  `requestAuthorization(options: [.alert, .badge, .sound])` — không phải `.provisional` — nên
  có thêm prompt thông báo. Đường cơ sở UX ở trên lệch một dialog.

## Đ5 — Điểm mù chung, và nó trúng đúng chỗ Duy đã chỉ ra

Phản bác tự tìm ra, độc lập với tôi:

> *"CẢ HAI ĐỀU ĐỔI CÂU HỎI CỦA DUY LẤY MỘT CÂU DỄ ĐO HƠN — và không ai nói ra là đã đổi.
> Duy hỏi: 'máy này đã join ĐÚNG cuộc họp NÀY chưa?' Cả hai phiên trả lời: 'có thiết bị media
> nào đang chạy không?'"*

**Quyết định B của Duy (2026-10-13) chính là phát hiện này, nói trước bằng tiếng người.**
Mọi thiết kế từ đây phải trả lời câu hỏi **danh tính cuộc họp**, không được lặng lẽ hạ cấp
xuống câu hỏi hiện diện.

## Đ6 — Một điểm mù mới, chưa ai trong xưởng tính tới

Phản bác đặt câu hỏi không ai hỏi: **"issue này do NGƯỜI viết hay do MODEL viết?"**

- Reaction `+1` trên #889 đến từ `dosubot[bot]`, thả **4 giây** sau khi issue được tạo.
- Hai issue của `stenoai` — nguồn cho hai phát hiện ở bản trên — có dấu hiệu sinh bằng model.
- `ZoomStat` được bản trên tôn lên là *"điều tra thực địa trong một cuộc họp thật"*; metadata
  repo **không chống đỡ được** mô tả đó.

**⇒ "Bằng chứng cộng đồng" năm 2026 có thể là output của model khác.** Chưa có cách lọc. Ghi
vào đây để các stage sau không xây lên nó.

---

# ĐO TẠI CHỖ — 2026-10-13, tự chạy trên máy Duy

> Duy: *"tôi kh muốn phải chạy bất cứ lệnh nào… tôi kh cần làm gì hết"* (2026-10-13).
> ⇒ **Quyết định C.** Mọi phép đo từ đây do Claude tự chạy. Và nó là một yêu cầu sản
> phẩm, không chỉ một lời từ chối — xem §Hệ quả của Quyết định C.

Máy: macOS 26.5.1 (25F80) · Zoom 7.1.9 · Chrome/Brave/Vivaldi/Safari cùng cài.

| # | Câu hỏi | Kết quả đo | Trạng thái trước đó |
|---|---|---|---|
| 1 | **AX có đọc được URL tab trình duyệt không?** | **CÓ.** `AXWebArea → AXURL` trả URL đầy đủ trên **Chrome, Brave, Vivaldi**, kèm `AXTitle` | chưa ai đo |
| 2 | Zoom có phơi `AXWindow` không? | **CÓ.** `AXWindows=1`, title `"Zoom Workplace"`, `AXStandardWindow` | screenpipe nói KHÔNG → **SAI** |
| 3 | Menu `Meeting` của Zoom có mặt lúc idle? | **KHÔNG.** Chỉ 5 menu: Apple · Zoom Workplace · Edit · Window · Help | screenpipe bỏ tín hiệu này vì "it exists even when Zoom is idle" → **SAI**, nên nó DÙNG ĐƯỢC |
| 4 | `CptHost` lúc idle? | **KHÔNG.** `caphost` thì **CÓ** (pid sinh cùng lúc với zoom.us) | khớp |
| 5 | Cờ camera đọc được không cần quyền? | **CÓ** ngoài sandbox — `authorizationStatus=0` trước và sau, `OSStatus=0` | — |
| 6 | …trong App Sandbox? | **KHÔNG.** Trả rỗng, không lỗi → hỏng im lặng (xem Đ2) | — |

**Còn đúng MỘT câu chưa đo được:** tiêu đề cửa sổ Zoom **khi đang trong cuộc họp** có mang
meeting ID không. Cần một cuộc họp thật. Lúc idle là `"Zoom Workplace"`.

## Hệ quả của Quyết định C — nó loại bỏ một nhánh thiết kế

Quyết định C (*không setup, app tự chạy*) + **4 trình duyệt cùng cài trên máy Duy**:

```
   AppleScript / Automation   1 dialog cho MỖI cặp (app → trình duyệt)
                              Chrome + Safari + Brave + Vivaldi = 4 dialog, + System Events
                              ⇒ VI PHẠM Quyết định C

   Accessibility (AX)         1 toggle, MỘT lần, phủ MỌI trình duyệt VÀ mọi app họp
                              ⇒ và phép đo #1 chứng minh nó đủ mạnh để thay AppleScript
```

⇒ **Kiến trúc chốt: AX-only. AppleScript bị loại khỏi bảng phương án.** Đây không phải sở
thích kỹ thuật — nó suy ra trực tiếp từ yêu cầu của Duy, và được một phép đo chống đỡ.

**Ngoại lệ duy nhất của "không cần làm gì", phải nói thẳng:** Accessibility cần **một** lần
bật trong System Settings ở lần chạy đầu. Không có đường vòng — macOS không cho app nào đọc
UI của app khác mà không có nó. Nhánh thật sự zero-permission (cờ camera) **không trả lời
được "họp NÀO"**, nên không phục vụ được Quyết định B.

```
   Sàn không hạ được nữa:  MỘT toggle · MỘT lần · lần chạy đầu tiên.
```

## Ghi chú về screenpipe — mất nó rẻ hơn tưởng

Hai trong các tín hiệu cốt lõi của screenpipe vừa **đo ra là sai** trên Zoom 7.1.9/macOS 26.
Cộng với Đ1 (giấy phép thương mại, cấm chép), kết luận: bảng profile đó **không phải món quà
bị mất, mà là một thứ đằng nào cũng phải viết lại và kiểm lại.** Chi phí của Đ1 thấp hơn
bản trên ước tính.

---

# ĐÍNH CHÍNH LỚN — 2026-10-13, critic độ-đầy-đủ lật ngược kiến trúc

> Mục này **đè lên** §Hệ quả của Quyết định C ở trên. Bản đó không sai về logic;
> nó sai về **tiền đề** — nó giả định Zoom quan trọng.

## Đ7 — Bài toán không phải DETECT. Là IDEMPOTENCE.

Sáu mũi research đều đọc đề là *"đo một trạng thái của thế giới"* (máy có đang họp không).
Đề thật là *"đừng thực hiện cùng một hành động hai lần"* (tôi đã mở link NÀY chưa).

```
   DETECT        cần cảm biến · cần quyền · cần đúng trên máy người khác
                 · gãy mỗi lần Zoom/Meet đổi bản UI
   IDEMPOTENCE   cần một dấu vết do CHÍNH máy này để lại
                 · không quyền · không hợp đồng ngầm với vendor · không bao giờ gãy
```

## Đ8 — Dữ liệu thật của Duy, tự đo, và nó xoá sổ nhánh Zoom

**Lịch 30 ngày (Google Calendar, 99 sự kiện):**

| Nền tảng | Số cuộc |
|---|---|
| **Google Meet** | **71** |
| Zoom | **0** |
| Teams | 1 |
| Webex | 1 |
| Không có link | 26 |

**Lịch sử Vivaldi (`sqlite3`, KHÔNG prompt TCC):** 127 URL phòng họp distinct ·
**96 lượt truy cập thật trong 30 ngày** · timestamp tới giây.

⚠️ **Bẫy triển khai:** phải JOIN bảng `visits`, không đọc `urls.last_visit_time` — cột đó chỉ
giữ lần CUỐI nên gộp mất mọi lần lặp (32 so với 96, chênh 3×).

## Đ9 — Kiến trúc đúng, thay cho "AX-only"

```
   TẦNG 1   so mã phòng của event với lịch sử trình duyệt N phút gần nhất
            ├─ ZERO quyền, zero dialog, zero setup        → thoả Quyết định C TUYỆT ĐỐI
            ├─ mang MÃ PHÒNG                               → thoả Quyết định B
            ├─ phủ 71/73 = 97% cuộc họp thật của Duy
            └─ không bao giờ gãy khi vendor đổi UI

   TẦNG 2   AX đọc nút Leave/Hangup — CHỈ cho app native (Zoom/Teams/Webex)
            ├─ tốn 1 toggle Accessibility + bảo trì vĩnh viễn
            └─ mua về: 2 cuộc / 30 ngày          ← OPT-IN, mặc định TẮT
```

**Hai câu tôi viết ở trên và giờ phải rút lại:**

| Tôi viết | Sai ở đâu |
|---|---|
| *"Kiến trúc chốt: AX-only"* | Suy đúng từ tiền đề sai. Tiền đề là "phải chạy cho Zoom". Zoom = 0 cuộc |
| *"Sàn không hạ được nữa: MỘT toggle"* | Sàn là **KHÔNG toggle nào** cho 97% ca. Tôi dừng tìm quá sớm |

## Đ10 — Hai phương án zero-code, nêu ra để Duy bác chứ không để lờ đi

1. **Lật hai cờ có sẵn.** `joinEventNotification = 0`, `automaticEventJoin = 1` hiện tại.
   Đảo lại ⇒ nhận thông báo có nút Join thay vì tự mở. **Nỗi đau biến mất, 0 dòng code.**
   Giá: một cú bấm mỗi cuộc họp.
2. **Đếm ngược huỷ được.** T-3 hiện banner *"sẽ mở sau 10s — [Huỷ]"*. Zero detect, và nó
   **sai an toàn**: không bao giờ gây lỡ họp.

**Cả hai đều đòi Duy bấm một cái** ⇒ mâu thuẫn với *"tôi kh cần làm gì hết"* (Quyết định C).
Tôi ghi lại để anh bác, không phải để tôi lờ đi.

## Đ11 — Câu hỏi không ai trong sáu mũi hỏi

> Dự án này lấy thời gian từ đâu? Còn **5 cuối tuần** đến 15/11, và `noelroom` đã nhận cam kết.

Chưa trả lời. Thuộc về Duy.
