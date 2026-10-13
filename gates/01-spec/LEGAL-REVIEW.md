---
stage: 01-spec
date: 2026-10-13
status: pass-with-conditions
owner: Phòng Legal
reviewer: same vendor, same priors — no external verifier ran
---

# LEGAL-REVIEW — presence-gate

> **Thời gian đọc ~7 phút.** Mọi dòng "đã kiểm" dưới đây tôi tự chạy lệnh trên repo và trên máy
> này hôm nay, có đường dẫn + số dòng. Dòng nào không tự kiểm được thì nằm ở §6.

## TL;DR

| | |
|---|---|
| **Kết luận** | **PASS kèm điều kiện** — 6 điều kiện, 3 là cổng chặn |
| **Chặn vào S3** | CL-1 (đo lại TCC sạch) · CL-2 (thiết kế tri-state) |
| **Chặn phát file cho đồng nghiệp** | CL-4 (gỡ patronage + mail) · CL-5 (kèm LICENSE trong bundle) · CL-6 (nói trước với đồng nghiệp) |
| **Phải sửa NGAY trong input của S1** | một dòng trong khối "SỰ THẬT ĐÃ ĐO" là **sai**, xem §2.1 |
| **Duy phải quyết** | tên sản phẩm mới · chấp nhận hạn dùng macOS 27 · bỏ patronage · chấp nhận rủi ro ToS còn lại |

---

## 1. Apache-2.0 — nghĩa vụ, cụ thể tới mức thi hành được

Trích từ `LICENSE` **trong chính repo này**, không qua trung gian.

### 1.1 Bốn khoản §4 — khoản nào phát sinh

| Khoản | Nguyên văn (rút) | Phát sinh? | Phải làm gì |
|---|---|---|---|
| §4(a) | *"give any other recipients… a copy of this License"* | **CÓ** | `LICENSE` phải đi **cùng file .app**, xem CL-5 |
| §4(b) | *"cause any modified files to carry prominent notices stating that You changed the files"* | **CÓ** | header mỗi file sửa, mẫu ở §1.2 |
| §4(c) | *"retain… all copyright, patent, trademark, and attribution notices from the Source form"* | **CÓ** | **GIỮ**, không xoá — xem bẫy ở §1.3 |
| §4(d) | *"If the Work includes a 'NOTICE' text file…"* | **KHÔNG** | đã kiểm: `ls NOTICE` → *No such file or directory* |

**Nguồn attribution — đã kiểm:** 44 / 134 file `.swift` mang dòng
`// Copyright © <năm> Andrii Leitsius. All rights reserved.`
Lấy từ header file source là **đúng**; Appendix của `LICENSE` còn nguyên placeholder
`Copyright [yyyy] [name of copyright owner]`, lấy từ đó là lấy phải chỗ trống.

> ⚠️ **Bẫy ở đúng điểm chèn.** `MeetingBar/Notifications/NotificationActionRunner.swift` —
> nơi cổng presence sẽ chèn vào — **KHÔNG có dòng copyright nào**, header chỉ có tên file.
> Nghĩa là §4(c) ở file này không có gì để giữ, nhưng **§4(b) vẫn bắt buộc**. Đừng suy ra
> "file không có copyright thì không phải ghi gì".

### 1.2 Dòng notice §4(b) — soạn sẵn, chép thẳng vào

Đặt ở **đầu mỗi file .swift bị sửa**, ngay dưới tên file:

```swift
//
//  NotificationActionRunner.swift
//  <TÊN-MỚI>
//
//  This file was modified on <YYYY-MM-DD> by Duy Pham.
//  Change: added a presence gate to shouldConsiderActionEvent(_:settings:).
//
//  Original work from MeetingBar, Copyright © 2020–2025 Andrii Leitsius,
//  licensed under the Apache License, Version 2.0.
//
```

Hai chỗ phải tự điền mỗi lần: **ngày** và **dòng `Change:`**. Một dòng `Change:` nói đúng cái
đã sửa — không phải "various improvements".

**Thêm một file ở gốc repo**, `CHANGES-FROM-UPSTREAM.md`, liệt kê mọi file đã sửa. Không bắt
buộc theo §4(b) (header đã đủ), nhưng đây là thứ Duy giữ đúng được; header rải rác thì không.

### 1.3 Bẫy §4(c) — đừng "dọn dẹp" cái phải giữ

| Chỗ | Nội dung | Làm gì |
|---|---|---|
| `MeetingBar/Info.plist` → `NSHumanReadableCopyright` | `Copyright © 2020 Andrii Leitsius. All rights reserved.` | **GIỮ NGUYÊN.** Thêm dòng của Duy *bên cạnh*, không thay thế |
| 44 header `.swift` | `Copyright © … Andrii Leitsius` | **GIỮ NGUYÊN** cả ở file bị sửa |

Phản xạ tự nhiên khi rebrand là tìm-thay toàn bộ tên và xoá copyright cũ. Ở đây **xoá là vi phạm
§4(c)**, còn giữ thì không mất gì.

Dòng `All rights reserved.` trong header **không** mâu thuẫn với Apache-2.0 — nó là chuỗi mẫu cũ
của Xcode; `LICENSE` mới là thứ cấp phép. Không cần sửa, không cần lo.

---

## 2. §6 Trademarks — danh sách đổi tên, đã soi từng chỗ

> §6 nguyên văn: *"This License does not grant permission to use the trade names, trademarks,
> service marks, or product names of the Licensor, **except as required for reasonable and
> customary use in describing the origin of the Work**…"*

**Vế sau quan trọng và S0 chưa nêu:** Duy **ĐƯỢC** viết *"fork của MeetingBar, tác giả gốc Andrii
Leitsius"* trong README và hộp About — đó là mô tả nguồn gốc, §6 cho phép rõ ràng.
Cái bị cấm là **đặt tên sản phẩm** là MeetingBar.

### 2.1 Chỗ nào đang mang tên — đã grep, có đường dẫn

| # | Vị trí | Giá trị hiện tại | Đổi? |
|---|---|---|---|
| 1 | `MeetingBar.xcodeproj/project.pbxproj` → `PRODUCT_BUNDLE_IDENTIFIER` | `leits.MeetingBar` | **ĐỔI** — mang cả tên *và* namespace `leits` của người khác |
| 2 | cùng file → `INFOPLIST_KEY_CFBundleDisplayName` | `MeetingBar` | **ĐỔI** — đây là tên hiện ở Finder và menu bar |
| 3 | cùng file → `PRODUCT_NAME = $(TARGET_NAME)`, target `MeetingBar` | ⇒ `MeetingBar.app` | **ĐỔI** tên target ⇒ đổi tên file .app |
| 4 | `MeetingBar/Info.plist` → `CFBundleURLSchemes` | `meetingbar` | **ĐỔI** — và nó còn **đụng scheme** nếu máy ai đó đã cài MeetingBar thật |
| 5 | `MeetingBar/Info.plist` → `NSHumanReadableCopyright` | Andrii Leitsius | **GIỮ** (§4(c)) |
| 6 | 22 file `Localizable.strings`, riêng `en.lproj` có **20** chỗ | `"Quit MeetingBar"`, `"Welcome to MeetingBar"`, `"MeetingBar Preferences"`… | **ĐỔI** phần hiển thị |
| 7 | `MeetingBar/App/PatronageService.swift:11-13` | `leits.MeetingBar.patronage.3Month/6Month/12Month` | **GỠ HẲN** — xem §2.2 |
| 8 | `MeetingBar/Utilities/Constants.swift:35` | `mailto:leits.dev@gmail.com?subject=MeetingBar` | **GỠ HẲN** — xem §2.2 |
| 9 | `MeetingBar/Utilities/MeetingBarLogger.swift:11` | fallback `"leits.MeetingBar"` | đổi, ưu tiên thấp (nội bộ) |
| 10 | `en.lproj/Localizable.strings:230` | *"…Application Scripts → leits.MeetingBar folder"* | đổi theo bundle id mới |

Tên mới **chưa chọn — việc của Duy** (§7, câu hỏi 1).

### 2.2 🚩 Phát hiện mới, mức CHẶN: app còn đang xin tiền cho người khác

Đây không phải chuyện giấy phép, và nó nặng hơn chuyện giấy phép.

| Thứ | Hệ quả khi Duy đưa file cho đồng nghiệp |
|---|---|
| `PatronageService.swift` + `GeneralTab.swift` dùng StoreKit với product ID `leits.MeetingBar.patronage.*` | Đồng nghiệp thấy nút ủng hộ tiền trỏ vào **sản phẩm App Store của tác giả gốc**. Ngoài App Store, product ID này **không resolve** ⇒ hoặc UI hỏng, hoặc tệ hơn: một affordance thanh toán nằm dưới một **cái tên sản phẩm đã bị đổi**. |
| `en.lproj:98` `"Thanks! You have supported MeetingBar for %d months 🎉"` | chuỗi quảng bá cho tên bị §6 cấm |
| `Constants.swift:35` `mailto:leits.dev@gmail.com` | đồng nghiệp gặp lỗi **gửi mail cho Andrii Leitsius**, không phải cho Duy |

**Không phải đổi tên — phải GỠ.** Màn hình patronage và nút mail không phục vụ mục tiêu nào của
presence-gate, và giữ lại thì vừa sai §6 vừa đẩy phiền phức sang một người lạ.
Nếu Duy muốn giữ thiện chí: thay bằng **một link tĩnh tới repo gốc** — §6 cho phép, vì đó là mô
tả nguồn gốc.

---

## 3. ĐỌC LỊCH SỬ TRÌNH DUYỆT — phần nặng nhất

### 3.1 🚩 CHẶN NHẬN THỨC: phép đo "không prompt TCC nào" là KHÔNG HỢP LỆ

Input S1 ghi phép đo này vào khối *"SỰ THẬT ĐÃ ĐO — không nghiên cứu lại, không nghi ngờ"*.
**Tôi phải nghi ngờ nó, vì nó sai về phương pháp.**

Tôi chạy phép thử Full Disk Access kinh điển ngay trong phiên này:

```
$ ls ~/Library/Application\ Support/com.apple.TCC/
AdhocSignatureCache/   TCC.db            ← lẽ ra phải bị từ chối

$ sqlite3 ~/Library/Application\ Support/com.apple.TCC/TCC.db "select count(*) from access;"
471                                       ← đọc được ⇒ có FDA

$ sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db \
    "select client, auth_value from access where service='kTCCServiceSystemPolicyAllFiles';"
/Users/edwardpham/.volta/tools/image/node/22.22.0/bin/node|2     ← 2 = ALLOWED
```

**Tiến trình đã thực hiện phép đo hôm 13/10 là `node` — và `node` có Full Disk Access.**
Mọi `sqlite3` chạy từ đó kế thừa quyền này. Vì vậy *"đọc được History mà không prompt"* **không
nói gì** về một `.app` chưa ký, mới phát, chưa có quyền gì.

Nói cho rõ phạm vi: **tôi không chứng minh Tầng 1 hỏng.** Tôi chứng minh **bằng chứng hiện có
không đỡ nổi câu "0 quyền · 0 dialog"** — và cả Quyết định C (*"tôi kh cần làm gì hết"*) đang
đứng trên câu đó.

### 3.2 Bằng chứng độc lập: Tầng 1 nhiều khả năng ĐÚNG trên macOS 26 — nhưng có hạn dùng

Vì phép đo tại chỗ hỏng, tôi đi tìm nguồn ngoài.

[Apple Developer Forums #847030](https://developer.apple.com/forums/thread/847030) — đúng tình
huống: app **không sandbox** đọc thư mục Chrome/Firefox dưới `~/Library/Application Support/`.

| Nguồn | Nguyên văn |
|---|---|
| Người hỏi | *"On macOS 26 and earlier, this worked without any special permissions."* |
| Người hỏi | *"On macOS 27, the same operations are **silently blocked** — no TCC prompt is shown to the user, access is simply denied."* |
| Người hỏi | *"Granting Full Disk Access… resolves the issue completely on macOS 27."* |
| **Apple DTS** (Quinn "The Eskimo!") | *"**This is an intentional change.** It's implemented by MAC… Honestly, **I'm not sure whether Full Disk Access will get around this.**"* |

Rút ra, nói đúng mức chắc chắn:

```
   macOS 26.5.1 (máy Duy)   Tầng 1 CHẠY, không cần quyền
                            ── nguồn: bên thứ ba, KHÔNG phải phép đo của Duy
   macOS 27                 Apple XÁC NHẬN chặn, và chặn IM LẶNG
                            ── lối thoát duy nhất (FDA) chính Apple nói "không chắc"
```

**Tầng 1 có hạn sử dụng, và hạn đó do Apple đặt.** Không phải lý do để không làm — nhưng phải
được ghi là một quyết định có ý thức, không phải một bất ngờ sáu tháng nữa (§7, câu hỏi 2).

Thêm một dữ kiện tôi tìm thấy trên chính máy này: `kTCCServiceSystemPolicyAppData`
(*"access data from other apps"*) **đang sống và đang bắn**, 16 client đã bị hỏi và người dùng đã
đồng ý (`auth_reason=2` = User Consent) — trong đó có VSCode Insiders, Zed, Warp, Codex, Cursor,
Docker. Lớp bảo vệ này **có thật trên macOS 26**. Nó có phủ đúng
`~/Library/Application Support/Vivaldi/` hay không thì **tôi chưa xác lập được** (xem §6).

### 3.3 🚩 CL-2: "bị chặn" và "không tìm thấy" KHÔNG được trả về cùng một giá trị

Đây là hệ quả thiết kế của chữ **"silently"** ở trên, và nó phải vào spec.

```
   boolean  →  đọc hỏng trả 0 dòng  →  cổng kết luận "chưa vào họp"  →  BẮN THÔNG BÁO
              tính năng chết, không ai biết, hành vi trông y hệt lúc chạy đúng
```

Đúng Quy tắc 8 của xưởng: *"code đúng, event bắn, không ai nhận, sáu tháng sau dashboard trống."*
Ở đây còn tệ hơn — không có dashboard nào để trống.

**Bắt buộc: tri-state.**

| Kết quả đọc | Cổng làm gì |
|---|---|
| `đọcĐược(cóLượtTruyCập)` | **im** — thoả Quyết định B |
| `đọcĐược(khôngCóLượtTruyCập)` | nhắc như MeetingBar gốc |
| `khôngĐọcĐược` | nhắc như MeetingBar gốc **+ báo cho người dùng MỘT lần, nhìn thấy được** |

Nhánh ba **không được im lặng**. Nó là thứ duy nhất phân biệt "Duy chưa vào họp" với
"macOS 27 vừa giết tính năng này".

### 3.4 Ràng buộc kỹ thuật biến lời hứa thành thứ thi hành được

Vấn đề thật, nói thẳng: app mở file SQLite **chứa toàn bộ lịch sử duyệt web** (27,9 MB trên máy
Duy). Dù chỉ hỏi mã phòng, **nó vẫn có quyền đọc tất cả**. Lời hứa chỉ đáng tin khi nó được viết
thành ràng buộc kiểm được.

| # | Ràng buộc | Vì sao |
|---|---|---|
| P-1 | **Không bao giờ `SELECT *`. Không bao giờ lấy `urls.title`.** | Tiêu đề trang *là* nội dung: *"Quarterly layoffs — Google Docs"*. Mã phòng thì không. |
| P-2 | Chỉ chiếu đúng cột cần, **`LIMIT 1`** | Chỉ cần biết *có hay không*. `LIMIT 1` ⇒ danh sách URL **không bao giờ được dựng ra trong bộ nhớ**. |
| P-3 | Mở **read-only** (`SQLITE_OPEN_READONLY`). **KHÔNG copy file ra tmp.** | Copy = tạo **bản sao thứ hai của toàn bộ lịch sử** trên đĩa. Đánh đổi: Vivaldi đang chạy có thể gây đọc lỡ dở ⇒ rơi vào nhánh `khôngĐọcĐược` (CL-2) ⇒ fail-open, hậu quả đúng bằng MeetingBar gốc. **Chọn riêng tư hơn, chấp nhận lỡ.** |
| P-4 | Đóng kết nối ngay trong lần đánh giá cổng. Không giữ handle. | |
| P-5 | **Không URL, không tiêu đề, không mã phòng nào đi vào `Logger`** — dù ở mức `.private` | Repo có 7 category `os.Logger` tại `MeetingBar/Utilities/MeetingBarLogger.swift:13-19`. |
| P-6 | 🚩 **Không thêm gì từ lịch sử duyệt vào `DiagnosticsReport`** | `MeetingBar/Utilities/Diagnostics/DiagnosticsReport.swift` tạo báo cáo **người dùng xuất ra và gửi đi**. Thêm một dòng history vào đó = gửi lịch sử duyệt web cho người nhận báo cáo. Đây là đường rò cụ thể nhất tôi tìm được. |
| P-7 | Chỉ truy vấn **trong cửa sổ `[T-5m, T+15s]`** quanh một sự kiện lịch | Lead time tối đa đã đo là 5 phút. Không quét nền, không định kỳ. |
| P-8 | **Safari nằm ngoài phạm vi, và phải ghi lý do** | `~/Library/Safari/History.db` là đường dẫn TCC bảo vệ **lâu đời**, đòi FDA — khác hẳn và khó hơn Chromium. `meetBrowser=Vivaldi` nên hôm nay không cần. Máy Duy cài **4** trình duyệt; đồng nghiệp dùng Safari thì Tầng 1 **không chạy** — và phải rơi vào nhánh `khôngĐọcĐược`, không phải im lặng. |

Khuôn truy vấn thoả P-1, P-2, và né đúng cái bẫy đã đo (phải JOIN `visits`; `urls.last_visit_time`
gộp mất, 32 so với 96 — chênh 3×):

```sql
-- CHỈ một cột thời gian. KHÔNG urls.title. KHÔNG SELECT *.
SELECT v.visit_time
FROM visits v JOIN urls u ON u.id = v.url
WHERE v.visit_time > ?        -- cận dưới thời gian trước, để dùng index
  AND u.url LIKE ?            -- '%' || <mã phòng từ sự kiện lịch> || '%'
LIMIT 1;
```

### 3.5 Có phải nói với đồng nghiệp không? — CÓ. Câu nói, soạn sẵn

Không phải vì luật bắt (xem §6), mà vì **im lặng ở đây là thứ phá quan hệ, không phải thứ phá
luật**. Chi phí: một tin nhắn.

> **Gửi kèm khi đưa file:**
>
> "App này mình fork từ MeetingBar, thay cho bản gốc trên máy bạn.
>
> Trước khi nó nhắc hoặc tự mở link họp, nó kiểm xem bạn đã vào cuộc họp đó chưa, để khỏi nhắc
> thừa. Cách nó kiểm: **đọc file lịch sử duyệt web của trình duyệt trên máy bạn**.
>
> Nói thẳng phần cần nói: file đó chứa **toàn bộ** lịch sử duyệt của bạn, nên về mặt kỹ thuật app
> **đọc được hết**. Cái nó thực sự làm là hỏi đúng một câu — *'N phút qua có mở đúng mã phòng này
> không'*. Nó không lấy tiêu đề trang, không ghi URL ra log, không gửi gì ra khỏi máy bạn. Mình
> gửi kèm mã nguồn, bạn xem được chỗ đó.
>
> Không thích thì nói mình tắt tầng này — app vẫn chạy bình thường như MeetingBar gốc."

Ba thứ bắt buộc phải có trong câu nói và **đừng bỏ**: (1) nó đọc file gì, (2) nó **có khả năng**
đọc hết, (3) tắt được.

---

## 4. ToS của vendor — tìm được gì, và KHÔNG tìm được gì

### 4.1 Đọc lịch sử duyệt web của chính mình

**Không tìm thấy điều khoản nào cấm.** Đây là đọc một file do trình duyệt ghi trên đĩa của chính
người dùng — không có tương tác nào với dịch vụ của vendor, nên không có hợp đồng dịch vụ nào
được kích hoạt. Rủi ro: thấp.

**Tôi đã KHÔNG đọc riêng EULA của Vivaldi.** Nếu Duy muốn chắc, đó là một việc 10 phút — nhưng
tôi không thấy lý do để nghĩ nó sẽ đổi kết luận.

### 4.2 Đọc cây Accessibility của Zoom (Tầng 2) — **KHÔNG tìm được điều khoản cụ thể**

Nói đúng như đã tìm, không bọc đường:

| Tìm thấy | Mức |
|---|---|
| Zoom API License and Terms of Use liệt kê **reverse engineering / decompiling** là hành vi bị cấm | sơ cấp — [hp.zoom.us/legal/zoom_api_license_and_tou](https://hp.zoom.us/legal/zoom_api_license_and_tou) (bản mirror; tôi **không** mở được bản canonical của Zoom) |
| Một bên thứ ba theo dõi ToS của Zoom mô tả lệnh cấm reverse engineering, xếp mức "high severity" | **thứ cấp** — [conductatlas.com](https://conductatlas.com/platform/zoom/zoom-terms-of-service/prohibition-on-reverse-engineering-software/); trang này tự ghi là phân tích, không phải nguyên văn |
| **Điều khoản nói về accessibility / assistive technology** | **KHÔNG TÌM THẤY** |

**Không tìm thấy ≠ không tồn tại.** Phương pháp của tôi là tìm kiếm web, không phải đọc hết bản
ToS hiện hành của Zoom.

Lập luận *có thể* bào chữa — và tôi ghi rõ đây là **lập luận, không phải điều khoản**: đọc cây AX
là tiêu thụ một giao diện mà Zoom **tự phơi ra cho hệ điều hành** qua framework Accessibility của
Apple, không phải dịch ngược phần mềm của Zoom. Tôi **không** tìm được điều khoản nào xác nhận
hay bác bỏ cách hiểu này.

**Khuyến nghị thu hẹp phạm vi — rẻ, và xoá luôn một ẩn số:**

| Nền tảng | 30 ngày | Cài trên máy | Đề xuất |
|---|---|---|---|
| Google Meet | 71 | — (trình duyệt) | Tầng 1 phủ, **không đụng AX của app nào** |
| Teams | 1 | **KHÔNG CÀI** | **BỎ khỏi Tầng 2.** Xoá luôn câu hỏi ToS của Microsoft, và ws://localhost:8124 dù sao cũng đã chết 30/06/2026 |
| Webex | 1 | **KHÔNG CÀI** | **BỎ** |
| Zoom | **0** | có cài | giữ, nhưng xem §6 — chưa đo được gì trong cuộc Zoom thật |

Tầng 2 sau khi thu hẹp chỉ còn **Zoom**, mua về **0 cuộc trên 30 ngày** của dữ liệu thật.
Đây là một dữ kiện Duy nên nhìn thẳng khi quyết định giữ Quyết định D.

---

## 5. screenpipe — ranh giới, vạch cụ thể

Đã chốt: **Screenpipe Commercial License, "All rights reserved", §5 Prohibited Without a
Commercial License.** Không chép một dòng nào.

Ranh giới, vì "đọc để học" là một câu quá rộng để thi hành:

| ✅ ĐƯỢC — sự kiện và ý tưởng không được bảo hộ bản quyền | ⛔ KHÔNG — đây là biểu đạt |
|---|---|
| Biết **rằng** Zoom phơi `AXWindow` | Chép **bảng tín hiệu per-platform** của họ: cấu trúc, thứ tự, cách chọn |
| Biết **rằng** menu "Meeting" chỉ xuất hiện khi đang họp | Chép tên định danh, tên hằng, bố cục struct/enum |
| Biết **rằng** `caphost` có lúc idle còn `CptHost` thì không | Chép comment, dù có diễn đạt lại |
| Tên API của Apple (`kAXWindowsAttribute`…) — của Apple, không của screenpipe | **Dịch Rust → Swift theo từng dòng.** Bản dịch là **tác phẩm phái sinh**, không phải tác phẩm mới |

**Kiểm tra thực tế trên nhánh này — kết quả sạch:**
`probe/Probe.swift` và `probe/AXBrowser.swift` là mã gốc, viết bằng tiếng Việt, chỉ dùng API của
Apple. **Không có dấu hiệu chép.**

Một điểm vệ sinh, không phải vi phạm: `probe/AXBrowser.swift:24` có comment
`← khớp với mô tả của screenpipe về Zoom`. Mã thì gốc, nên không sao — nhưng comment đó là **bằng
chứng viết tay rằng screenpipe là nguồn chọn tín hiệu**. Nên sửa lại cho trỏ vào **phép đo đã thực
hiện**, để hồ sơ xuất xứ khớp với sự thật.

**Quy tắc từ đây tới hết S3:** mọi tín hiệu AX đưa vào sản phẩm phải biện minh được bằng **một
phép đo ghi trong `gates/`**, không phải bằng screenpipe.

---

## 6. ⚠️ CHƯA XÁC MINH ĐƯỢC

| # | Chưa chắc cái gì | Vì sao chưa, và đo thế nào |
|---|---|---|
| U-1 | `kTCCServiceSystemPolicyAppData` **có phủ** `~/Library/Application Support/Vivaldi/` không | Mọi tiến trình trong phiên này đều kế thừa FDA của `node` ⇒ **không thể thử từ đây**. Cần CL-1. |
| U-2 | Trên macOS 27, FDA có cứu được Tầng 1 không | Người hỏi nói **có**, Apple DTS nói *"I'm not sure"*. Hai nguồn **mâu thuẫn**, và một trong hai là Apple. |
| U-3 | Bản ToS Zoom **hiện hành** nói gì về việc đọc cây AX | Chỉ mở được bản mirror + một nguồn thứ cấp. Chưa đọc bản canonical. |
| U-4 | EULA của Vivaldi | Chưa đọc riêng. |
| U-5 | Nghị định 13/2023/NĐ-CP về bảo vệ dữ liệu cá nhân có đặt nghĩa vụ nào lên Duy không | Lập luận của tôi: **không dữ liệu nào rời máy đồng nghiệp** ⇒ Duy không xử lý dữ liệu của họ ⇒ nghĩa vụ là **niềm tin, không phải luật**. **Tôi KHÔNG làm rà soát pháp luật Việt Nam** — đây là suy luận, không phải kết luận pháp lý. Khuyến nghị ở §3.5 đứng vững dù U-5 ngả về đâu. |
| U-6 | Tiêu đề cửa sổ Zoom **khi đang trong cuộc họp** | Kế thừa từ input S1. Chưa có cuộc Zoom thật nào (0 cuộc/30 ngày). |

---

## 7. KẾT LUẬN: **PASS kèm điều kiện**

### Sửa ngay, trong chính input của S1

**Dòng *"Tầng 1 — 0 quyền · 0 dialog"* phải bị gỡ khỏi khối "SỰ THẬT ĐÃ ĐO"** và viết lại thành:

> Tầng 1 — **nhiều khả năng** 0 quyền trên macOS 26, theo Apple Developer Forums #847030
> (nguồn bên thứ ba). **Phép đo ngày 13/10 không có giá trị**: tiến trình đo đã có Full Disk
> Access. Apple xác nhận macOS 27 chặn thao tác này, **chặn im lặng**.

Lý do phải sửa tại chỗ chứ không chỉ ghi ở đây: khối đó mang nhãn *"không nghiên cứu lại, không
nghi ngờ"* — để nguyên là **bảo mọi phòng sau đừng kiểm thứ đã biết là sai**.

### Sáu điều kiện

| # | Điều kiện | Cổng |
|---|---|---|
| **CL-1** | Đo lại TCC **trên tiến trình sạch**: build một `.app` chưa ký, chạy từ Finder (**không** từ terminal — terminal kế thừa FDA của `node`), xem có đọc được `Vivaldi/Default/History` không và có dialog nào không. Ghi kết quả vào `gates/01-spec/`. | **chặn vào S3** |
| **CL-2** | Spec phải ghi **tri-state** (§3.3). Nhánh `khôngĐọcĐược` **phải nhìn thấy được**. | **chặn vào S3** |
| **CL-3** | P-1…P-8 (§3.4) vào spec thành ràng buộc kiểm được, không phải lời hứa. Riêng **P-6** phải là một dòng cấm tường minh. | chặn S3 |
| **CL-4** | **Gỡ** `PatronageService.swift`, UI patronage trong `GeneralTab.swift`, và `Constants.swift:35`. Gỡ, không đổi tên. | **chặn phát file** |
| **CL-5** | Đổi tên theo bảng §2.1 (1,2,3,4,6,7,8,9,10), **giữ** mục 5. `LICENSE` phải nằm **trong bundle** (`Contents/Resources/LICENSE`) — đưa `Foo.app` trần cho đồng nghiệp là **vi phạm §4(a)**. Header §4(b) trên mọi file đã sửa. | **chặn phát file** |
| **CL-6** | Gửi câu nói §3.5 **trước khi** đưa file. | **chặn phát file** |

### Không chặn

Fork, sửa, phân phối nội bộ ≤5 người: Apache-2.0 **cho phép rõ ràng**. Không copyleft, không phí,
không phải xin phép. Làm xong 6 điều kiện là xong nghĩa vụ.

---

*Rà soát: một phiên Claude. **Same vendor, same priors — no external verifier ran.**
Review ≠ approve: phát file cho bất kỳ ai cần Duy duyệt riêng, ghi lại thành chữ.*

**Nguồn**
- `LICENSE`, `MeetingBar/Info.plist`, `MeetingBar.xcodeproj/project.pbxproj` + các file nêu kèm số dòng — đọc tại `fdd799b`, nhánh `feat/presence-gate`, 2026-10-13
- TCC: tự truy vấn `~/Library/Application Support/com.apple.TCC/TCC.db` và `/Library/Application Support/com.apple.TCC/TCC.db`, 2026-10-13
- [Apple Developer Forums #847030 — macOS 27 chặn đọc thư mục Chrome/Firefox](https://developer.apple.com/forums/thread/847030)
- [Apple Developer Forums #801461 — kTCCServiceSystemPolicyAppData](https://developer.apple.com/forums/thread/801461)
- [Zoom API License and Terms of Use (mirror)](https://hp.zoom.us/legal/zoom_api_license_and_tou)
- [conductatlas — Zoom ToS, reverse engineering (nguồn thứ cấp)](https://conductatlas.com/platform/zoom/zoom-terms-of-service/prohibition-on-reverse-engineering-software/)

---

## GỠ CHẶN 3.1 — 2026-10-13, đo lại bằng NHÓM ĐỐI CHỨNG

Legal chặn đúng: phép đo *"sqlite3 đọc lịch sử Vivaldi, không prompt TCC nào"* chạy từ iTerm2,
mà iTerm2 **có Full Disk Access** — xác nhận bằng hai phép thử: đọc được
`~/Library/Application Support/com.apple.TCC/TCC.db` (471 dòng) và `~/Library/Safari/History.db`
(14.541 mục). Kết luận cũ **không hợp lệ**.

**Đo lại đúng cách.** Dựng một app bundle `vn.duy.tccprobe` ký ad-hoc, `LSUIElement`, chạy bằng
`open` ⇒ nó mang **danh tính TCC của chính nó**, không thừa kế của terminal. Kết quả:

| Đường dẫn | Kết quả | Vai trò |
|---|---|---|
| `~/Library/Application Support/Vivaldi/Default/History` | **ĐỌC ĐƯỢC** | Tầng 1 cần |
| `~/Library/Application Support/Google/Chrome/Default/History` | **ĐỌC ĐƯỢC** | Tầng 1 cần |
| `~/Library/Application Support/BraveSoftware/.../History` | **ĐỌC ĐƯỢC** | Tầng 1 cần |
| `~/Library/Safari/History.db` | **BỊ CHẶN** — NSError 513 | **đối chứng** |
| `~/Library/Application Support/com.apple.TCC/TCC.db` | **BỊ CHẶN** — NSError 513 | **đối chứng** |

**Hai đối chứng bị chặn là thứ làm phép đo này có giá trị** — nó chứng minh probe thật sự
không có FDA, nên ba dòng "đọc được" ở trên không phải ảo ảnh của quyền thừa kế.

⇒ **Tầng 1 đúng là zero-permission.** Kết luận cũ sống sót, nhưng lý do thì đổi: từ *"tôi chạy
thử và không thấy prompt"* thành *"tôi chạy thử với nhóm đối chứng, và nhóm đối chứng bị chặn"*.

⇒ **Xác nhận độc lập quyết định A4 của phòng PM:** đọc Vivaldi + Chrome + Brave, **bỏ Safari** —
Safari đòi Full Disk Access (một toggle tay ⇒ vi phạm Quyết định C) và đổi lại 0 lượt Meet.

**Chặn 3.1 được gỡ.** Hai cổng chặn còn lại (§2.2 gỡ patronage/mailto, và điều kiện nhật ký)
vẫn mở.
