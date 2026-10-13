---
stage: 02-design
owner: Phòng Design (soạn) — **Duy duyệt và sở hữu**
freshness: 2026-10-13
status: draft — CHỜ DUY CHỌN HƯỚNG
blocked_by: ONE-PAGER §2 (PM đang đề xuất câu thay) — xem §0
---

# DESIGN-BRIEF — redesign UI + tiếng Việt

> Thời gian đọc: **~5 phút**. Duy quyết đúng **một** thứ ở file này: **chọn 1 trong 3 hướng (§4)**.
> Mọi con số trong file đo trên máy Duy hôm nay 2026-10-13, macOS Darwin 25.5.0, bằng
> AppKit/CoreText. Lệnh và kết quả: §7.
> Tự kiểm phía tác giả — **same vendor, same priors — no external verifier ran.**

---

## 0. CHẶN: tôi chưa viết được `UNDERSTOOD.md` cho S2, và lý do là lỗi thật

Quy tắc 11 bắt phòng sở hữu stage trích **nguyên văn** một câu từ `ONE-PAGER.md` trước khi bắt đầu.
Câu khớp nhất trong ONE-PAGER §2 hiện là:

> *"Mọi thứ hiện ra màn hình đều là một thất bại của thiết kế."*

**Trích câu đó rồi mở một stage redesign UI là tự mâu thuẫn trong cùng một file.** Câu đó viết cho
**cổng presence**; yêu cầu mới nói về **toàn bộ app**. Tôi **không tự sửa ONE-PAGER** — nó có
`owner: Duy`. PM đang đề xuất câu thay.

```
   Thứ tự bắt buộc:  Duy duyệt §2 mới  →  Design viết UNDERSTOOD.md  →  Design bắt đầu
   Nếu đảo:          UNDERSTOOD.md trích một câu sắp bị xoá ⇒ vibe-check [2] đúng ra phải chặn
```

Brief này vẫn viết được vì nó **đưa hướng để chọn**, chưa phải là thực thi. Nhưng không hướng nào
được dựng trước khi §2 có chủ.

---

## 1. BA TÍNH TỪ — cảm giác muốn tạo ra

| | Tính từ | Nghĩa cụ thể, kiểm được | Phản ví dụ trong code hôm nay |
|---|---|---|---|
| 1 | **Lặng** | App không bao giờ **tự** đòi chú ý. Không badge, không chấm đỏ, không animation chạy nền. Nó chỉ nói khi được mở ra | `FullscreenNotification.swift` — bề mặt duy nhất tự chiếm màn hình. Phải có lý do rất mạnh mới giữ |
| 2 | **Chắc** | Nhìn một cái là biết câu trả lời, không phải đọc hai lần. Một con số, một dòng, không phòng hờ | status item mặc định **55 ký tự** (`Constants.swift:27`) — đo được **433pt**. Đó là một đoạn văn, không phải một câu trả lời |
| 3 | **Quen** | Đọc như macOS và như tiếng Việt người ta nói ở văn phòng Ringkas — không như phần mềm được dịch | `"Woohoo! It's time to make cocoa"` (`next_meeting_empty_message`). Dịch thẳng câu này sang tiếng Việt là hỏng cả ba tính từ cùng lúc |

---

## 2. BA THỨ KHÔNG ĐƯỢC GIỐNG

| # | Không được giống | Dấu hiệu nhận ra khi đã lỡ | Vì sao |
|---|---|---|---|
| 1 | **Phần mềm dịch máy** | Hán-Việt cứng: *"Tùy chọn chung"*, *"Cấu hình hiển thị"*, *"Thiết lập thông báo"*. Câu bị động. Dịch 1-1 từng chữ của bản tiếng Anh | Đây là app cho **5 người Việt ngồi cùng công ty**, không phải bản địa hoá cho thị trường. Viết thẳng tiếng Việt, đừng dịch |
| 2 | **Dashboard / SaaS** | Thẻ bo góc, huy hiệu đếm, gradient, biểu tượng cảm xúc trong trạng thái rỗng, chữ "0 cuộc họp hôm nay 🎉" | Không có ai để gây ấn tượng. Không có trang pricing. Thêm một cái thẻ là thêm một thứ phải nhìn |
| 3 | **Spyware** | Icon con mắt, chấm đỏ kiểu "đang ghi", chỉ báo "đang theo dõi", chữ *theo dõi · giám sát · phát hiện · quét · thu thập* | App này **xin quyền Accessibility**. `WRITER-NOTES.md §4` đã cấm bộ từ vựng đó; **hình ảnh phải bị cấm y hệt**, nếu không thì cấm chữ là vô nghĩa |

---

## 3. KIỂM THỰC TẾ: macOS cho đổi cái gì, KHÔNG cho đổi cái gì

Đo từ code, không suy đoán. App dùng **AppKit `NSStatusItem` + `NSMenu`**, **không** phải
SwiftUI `MenuBarExtra` (`StatusBarItemController.swift:70-74`). Preferences thì **là SwiftUI**.

### ĐỔI ĐƯỢC

| Thứ | Ở đâu | Ghi chú |
|---|---|---|
| Chữ + font + màu của status item | `attributedTitle`, `StatusBarItemController.swift:201` | toàn quyền, kể cả nhiều dòng |
| Icon status item 16×16 | `MenuStyleConstants.iconSize:20` | nên để `isTemplate` ⇒ hệ thống tự đảo màu sáng/tối |
| Giới hạn ký tự tiêu đề 5…55 | `Constants.swift:25-28` | **đây là nút vặn chính cho tiếng Việt** |
| Bố cục 1 dòng / 2 dòng | `StatusBarPresentation.layout` → `.inline` / `.stacked` | đã có sẵn, không cần code mới |
| Toàn bộ nội dung + thứ tự menu | `MenuBuilder.swift` (1.284 dòng) | NSMenuItem tuỳ biến, có `view:` cho timeline và summary |
| Toàn bộ Preferences | SwiftUI, 9 file | cửa sổ tối thiểu **760×520**, sidebar **180–220pt** (`Preferences.swift:28,82`) |
| Onboarding 4 bước | SwiftUI | |

### macOS **KHÔNG** CHO ĐỔI — đừng vẽ hướng nào dựa vào mấy thứ này

| Thứ | Thực tế |
|---|---|
| Chiều cao thanh menu | **22pt, cố định** (đo: `NSStatusBar.system.thickness` = 22.0). Hai dòng phải nhét vào 22pt — đó là gốc của §5 |
| Vị trí icon trên thanh | Người dùng kéo bằng ⌘. App không đặt được |
| Khi thanh menu hết chỗ | macOS **âm thầm ẩn bớt** item. Status item càng rộng, càng dễ đẩy item khác biến mất. Trên MacBook có tai thỏ, chỗ trống còn ít hơn |
| Chrome của NSMenu | Chiều cao hàng, màu bôi sáng, bo góc, vật liệu mờ — của hệ thống |
| Màu nhấn | Đọc được (`Color.accentColor`, 4 chỗ), **không ghi đè được** |
| Chữ trong hộp thoại xin quyền Accessibility | Chuỗi cố định của hệ thống. Đã chứng minh ở `../01-spec/WRITER-NOTES.md §0`. **Tên app là chuỗi duy nhất ta viết được ở đó** |

---

## 4. BA HƯỚNG — **Duy chọn MỘT**

Cả ba đều dùng chung §1, §2, §3 và chung bộ chữ tiếng Việt của phòng Content. Khác nhau ở
**status item** — chỗ duy nhất chiều rộng thực sự khan hiếm.

### Hướng A — **"Giờ trước, tên sau"** ⭐ khuyến nghị

| | |
|---|---|
| **Status item** | Icon template 16×16 + **chỉ thời gian còn lại**, một dòng 13pt: `􀉉 5 ph` · `􀉉 ngay bây giờ`. **Không có tên cuộc họp trên thanh menu.** Rộng cố định ~55–70pt bất kể tên họp dài bao nhiêu |
| **Menu xổ xuống** | Chỗ duy nhất có tên. Dòng đầu là cuộc kế tiếp, in đậm, tên đầy đủ không cắt. Dưới là hôm nay. Giữ timeline. Bỏ summary card |
| **Preferences** | Sidebar giữ nguyên 3 nhóm. Nhãn ngắn: `Chung · Lịch · Liên kết họp · Hiển thị · Thông báo · Nâng cao` |
| **Trạng thái rỗng** | Trên thanh: **chỉ còn icon**, không chữ. Trong menu: *"Hôm nay hết họp."* Một câu. Không emoji, không "Woohoo" |
| **Được gì** | Bài toán chiều rộng tiếng Việt **biến mất khỏi chỗ duy nhất nó cắn**. Tên họp không hiện khi share màn hình — lợi ích riêng tư thật ở Ringkas. **Phần lớn là đổi giá trị mặc định** (`eventTitleFormat = .none`, `eventTimeFormat = .show`), không phải viết code mới |
| **Mất gì** | Liếc mắt không biết **cuộc nào**, chỉ biết **còn bao lâu**. Với người có 2 cuộc sát nhau thì phải mở menu |
| **Rủi ro** | Duy có thể thấy thiếu. Đảo ngược trong 5 giây: bật lại `eventTitleFormat = .show` |

### Hướng B — **"Một dòng, ngân sách chặt"**

| | |
|---|---|
| **Status item** | Icon + **tên cắt ngắn + giờ**, một dòng 13pt. Giới hạn ký tự **hạ từ 55 → 22** (đo: ~173pt thay vì 433pt) |
| **Menu xổ xuống** | Như hướng A |
| **Preferences** | Thêm một dòng giải thích dưới thanh trượt giới hạn ký tự: *"Tên dài hơn sẽ bị cắt. Tiếng Việt nên để 18–22."* |
| **Trạng thái rỗng** | Trên thanh: icon + *"rảnh"*. Trong menu: *"Hôm nay hết họp."* |
| **Được gì** | Giữ được thói quen hiện tại — liếc là biết cuộc nào. Thay đổi nhỏ nhất so với hôm nay |
| **Mất gì** | 22 ký tự tiếng Việt thường **không đủ cho một tên họp có nghĩa**. `"Họp giao ban hằng tuần"` vừa đúng 22. Dài hơn là `...` |
| **Rủi ro** | Cắt giữa chừng tạo nghĩa sai. Chỗ này tiếng Việt **nguy hiểm hơn tiếng Anh** — cắt một âm tiết ra khỏi từ ghép thì từ còn lại vẫn là một từ có nghĩa khác |

### Hướng C — **"Giữ hai dòng, sửa chiều cao dòng"**

| | |
|---|---|
| **Status item** | Giữ bố cục xếp chồng hôm nay: tên 12pt trên, giờ 9pt dưới. **Bắt buộc sửa `lineHeightMultiple` 0.7 → ≥0.88 và bỏ `baselineOffset: -3`** (`StatusBarItemController.swift:487-490`) — xem §5 |
| **Menu xổ xuống** | Như hướng A |
| **Preferences** | Như hướng B |
| **Trạng thái rỗng** | Hai dòng rỗng trông hỏng ⇒ tự động rơi về một dòng |
| **Được gì** | Nhiều thông tin nhất trong cùng chiều rộng. Không mất gì so với hôm nay |
| **Mất gì** | 9pt là **cỡ chữ nhỏ nhất trong app**, cứng, không theo thiết lập nào. Đọc đã khó ở tiếng Anh; thêm dấu tiếng Việt thì khó hơn |
| **Rủi ro** | **Rủi ro đã đo được, không phải giả định** — §5. Và sửa chiều cao dòng trong 22pt là bài toán zero-sum: cho dấu thêm chỗ = lấy chỗ của dòng 9pt |

**Khuyến nghị: Hướng A.** Lý do, theo thứ tự: (1) nó **xoá** bài toán chiều rộng thay vì quản lý
nó, mà quản lý thì phải quản lý mãi; (2) nó rẻ nhất — phần lớn là đổi default đã có; (3) *"build
up lại UI"* xảy ra **trong menu xổ xuống**, nơi có chỗ, chứ không phải trong dải 22pt, nơi không có.
Á quân: **C**, nếu Duy thực sự muốn thấy tên họp ngay trên thanh — nhưng C phải trả giá §5 trước.

---

## 5. TIẾNG VIỆT LÀ RÀNG BUỘC THIẾT KẾ — đo, không đoán

### 5.1 ⚠ Phát hiện: tiền đề "tiếng Việt dài hơn 20–30%" **không đúng với app này**

Đo chiều rộng thật ở 13pt, ba cặp câu thật:

| Tiếng Anh | Tiếng Việt | Lệch |
|---|---|---|
| Weekly Standup (98pt) | Họp giao ban hằng tuần (144pt) | **+47%** |
| Design Review (88pt) | Duyệt thiết kế (84pt) | **−5%** |
| No more meetings today (148pt) | Hôm nay hết họp rồi (122pt) | **−18%** |

```
   KẾT LUẬN   Chiều rộng không phải thuộc tính của TIẾNG VIỆT. Nó là hệ quả của CÁCH DỊCH.
              "Weekly Standup" phình 47% vì người dịch viết "Họp giao ban hằng tuần" —
              viết "Giao ban" thì nó NGẮN HƠN bản tiếng Anh.
   ⇒ Công cụ kiểm soát là NGÂN SÁCH KÝ TỰ TRONG FILE .strings, không phải sửa layout.
```

**Đề nghị với phòng Content, dưới dạng ngân sách cứng:** nhãn sidebar ≤ 12 ký tự · nhãn nút ≤ 16 ·
nhãn hàng Preferences ≤ 28 · mọi thứ lên thanh menu ≤ 22.

### 5.2 Nhãn Preferences có xuống dòng không — **KHÔNG**, đã đo

Sidebar tối thiểu 180pt, trừ icon ~20pt + spacing 8 + padding ~24 ⇒ **ngân sách ~128pt**.

| Nhãn tiếng Việt | Rộng | |
|---|---|---|
| Chung · Lịch · Lối tắt | 25–40pt | thoải mái |
| Nâng cao · Thông báo · Liên kết họp | 58–74pt | thoải mái |
| **Hiển thị & Sự kiện** | **107pt** | lọt, nhưng chỉ còn 21pt dư |

**Không nhãn nào tràn.** Nhưng `Hiển thị & Sự kiện` là nhãn duy nhất sát mép, và nó còn phải sống
trong sidebar hẹp nhất (180pt). **Đề nghị rút gọn thành `Hiển thị`** — rơi xuống 47pt, dư thoải mái.

### 5.3 ⚠ Dấu CÓ bị cắt ở chiều cao dòng hiện tại — đo được, chưa nhìn thấy

`StatusBarItemController.swift:487-490` đặt `lineHeightMultiple = 0.7`.
Font 12pt có `defaultLineHeight` = 15.0 ⇒ **khung dòng = 10.50pt**. Chiều cao mực thật của glyph:

| Glyph | Đỉnh mực | So với 10.50pt |
|---|---|---|
| `E` | 8.46pt | ok |
| `ộ` | 9.19pt | ok |
| `ố` | **11.03pt** | ⚠ vượt 0.53pt |
| `Ê` | **11.20pt** | ⚠ vượt 0.70pt |
| `Ế` | **11.43pt** | ⚠ **vượt 0.93pt** |
| `Ệ` | 11.20pt đỉnh, **−2.62pt đáy** ⇒ cao **13.82pt** trong khung 10.50pt | ⚠ |

Thêm `baselineOffset: -3` ở dòng 1 (`:468`) đẩy dòng trên **xuống** 3pt ⇒ đáy của `ộ`, `ặ`, `ụ`
(−2.62pt) đâm vào đỉnh dòng giờ 9pt bên dưới.

```
   ĐO ĐƯỢC   mực của Ế / Ệ / ố vượt khung dòng đã nén. Hình học, không tranh cãi.
   CHƯA ĐO   mắt có thấy bị cắt không. AppKit có thể vẫn vẽ tràn ra ngoài khung
             nếu view cha không clip.  ⇒ §6 mục 1. Phải CHỤP MÀN HÌNH mới biết.
```

Hướng A và B dùng một dòng 13pt ⇒ **không chạm bug này**. Chỉ hướng C phải trả.

### 5.4 Font: **font hệ thống macOS**, và đây là cách tôi biết nó đủ dấu

App **không dùng font tuỳ biến nào** — `grep -rnE "NSFont\(name:|Font\.custom"` trả về **0 kết quả**.
Mọi chỗ đều là `NSFont.systemFont` / SwiftUI semantic font ⇒ `.AppleSystemUIFont` (SF Pro).

Cách kiểm, chạy hôm nay trên máy Duy:

```swift
let cs = CTFontCopyCharacterSet(NSFont.systemFont(ofSize: 13)) as CharacterSet
// dò 105 code point: U+1EA0…U+1EF9 (90) + Ă ă Đ đ Ơ ơ Ư ư + 7 dấu tổ hợp U+0300/0301/0302/0303/0306/0309/0323
```

**Kết quả: thiếu 0 / 105.** Kiểm trên cả `systemFont(13)`, `systemFont(12)` và `menuBarFont`.
Đây là phép đo **CharacterSet của chính font**, không phải đọc mô tả font — tức là đúng cái mà
`../../../docs/lessons.md` cảnh báo *"mô tả ghi Latin Extended thì gần như không bao giờ bao gồm"*.

Hệ quả: **không cần nhúng font, không có vấn đề giấy phép font, không có rơi-về-font-hệ-thống
giữa câu** — vì font hệ thống **chính là** font duy nhất đang dùng.

### 5.5 NFC — chỗ thật sự cắn, và chỗ KHÔNG cắn

| Chỗ | Trạng thái | Bằng chứng |
|---|---|---|
| Cắt tên ở status item | **An toàn** | `shortenTitle` dùng `eventTitle.count` và `index(offsetBy:)` — Swift `String` đếm theo **grapheme cluster**, nên `ế` dạng NFD (3 code point) vẫn tính là **1**. Không cắt giữa chữ. `StatusBarPresentation.swift:276-285` |
| Tên file `.app`, `PRODUCT_NAME`, bundle id | **NGUY HIỂM** | zip rồi gửi qua chat là đúng chỗ NFC/NFD cắn. `WRITER-NOTES.md §1` đã chốt: **ASCII thuần**, chỉ `CFBundleDisplayName` mới có dấu |
| Khoá trong `vi.lproj/Localizable.strings` | **Không rủi ro** | khoá là ASCII (`preferences_tab_general`), chỉ giá trị có dấu |
| So sánh / lọc tên cuộc họp (regex filter) | **Chưa kiểm** | §6 mục 5 |

### 5.6 ⚠ Hai lỗi chặn việc thêm tiếng Việt, tìm thấy khi đọc code

**(a) `vi.lproj` một mình là KHÔNG ĐỦ.** `AppLanguage` là enum Swift **cứng**
(`Constants.swift:170-188`), 16 ngôn ngữ, trong khi trên đĩa có **23** thư mục `.lproj`.
Thiếu `case vietnamese = "vi"` thì Duy **không chọn được tiếng Việt trong Preferences**, kể cả
khi file dịch đã nằm đúng chỗ.

**(b) Tiền lệ chứng minh (a) là bẫy thật: tiếng Ukraina đang HỎNG.**
Enum ghi `case ukrainian = "ua"`, nhưng thư mục trên đĩa tên `uk.lproj`.
`checkLanguageAvailability("ua")` → `Bundle.main.path(forResource: "ua", …)` → `nil` →
`resetToDefault()`. **Chọn tiếng Ukraina thì app âm thầm quay về ngôn ngữ hệ thống, không báo gì.**
(`I18N.swift:41-47, 54-59`)

⇒ **Thư mục phải tên đúng `vi.lproj`, khớp từng ký tự với rawValue `"vi"`.**

**(c) Dịch thiếu thì ra UI pha trộn, âm thầm.** `I18N.localizedString` tự rơi về `englishBundle`
khi thiếu khoá (`I18N.swift:63-70`). Dịch 300/355 chuỗi ⇒ 55 chỗ tiếng Anh nằm lẫn, **không có
cảnh báo nào**. Đề nghị: **toàn bộ 355 chuỗi, hoặc không làm** — cộng một script đếm khoá hai bên
cho `vibe-check.sh`.

**(d) 20 chuỗi tiếng Anh có chữ `MeetingBar`.** Apache-2.0 §6 cấm dùng tên đó cho bản phân phối.
⇒ bản `vi.lproj` **không được** chứa chữ `MeetingBar`; nó phải mang tên Duy chọn. **Việc dịch bị
chặn bởi quyết định tên** — không phải chặn kỹ thuật, mà chặn thứ tự: dịch trước rồi đổi tên sau
là sửa 20 chuỗi hai lần.

---

## 6. ACCESSIBILITY — một dòng mỗi thứ, đo từ code

| Thứ | Hiện trạng đo được | Đề nghị |
|---|---|---|
| **VoiceOver trên status item** | **Không có nhãn nào.** Cả tầng UI chỉ có **đúng 1** `accessibilityLabel` (`DayTimelineView.swift:192`). VoiceOver đọc thẳng `attributedTitle`; ở bố cục 2 dòng nó gặp `\n` và đọc thành hai mảnh rời | Đặt `statusItem.button?.setAccessibilityLabel()` thành một câu đủ nghĩa: *"Cuộc họp kế tiếp: Giao ban, còn 5 phút"* — tách khỏi chuỗi hiển thị |
| **Tương phản** | Hai chỗ tự đặt màu: `NSColor.lightGray` cho dòng giờ (`:484`) và `disabledControlTextColor`. `lightGray` là màu **cố định**, không đổi theo sáng/tối ⇒ trên nền sáng nó **rất nhạt** | Thay bằng `NSColor.secondaryLabelColor` — màu ngữ nghĩa, tự theo sáng/tối và tự theo *Increase Contrast* |
| **Increase Contrast / Reduce Transparency / Reduce Motion** | **Không xử lý chỗ nào.** `grep ShouldIncreaseContrast\|ShouldReduceMotion\|ShouldReduceTransparency` → **0 kết quả** | Dùng màu ngữ nghĩa ở trên là đã đi được phần lớn đường, miễn phí |
| **Dynamic Type** | macOS **không có** Dynamic Type toàn hệ thống như iOS — nên nói thẳng là *không áp dụng*, đừng hứa. Nhưng status bar hardcode **13 / 12 / 9pt**; **9pt là cỡ nhỏ nhất trong app** và không theo thiết lập nào | Thêm lý do nữa để **không chọn hướng C**. Ở Preferences (SwiftUI) thì dùng font ngữ nghĩa, đừng hardcode |
| **Màu nhấn hệ thống** | Đã theo đúng — `Color.accentColor` ở 4 chỗ, không hardcode màu xanh | Giữ. Icon status item để `isTemplate` ⇒ hệ thống tự đảo sáng/tối |

---

## 7. CHƯA XÁC MINH ĐƯỢC

| # | Chưa biết | Vì sao chưa | Gỡ bằng | Tốn |
|---|---|---|---|---|
| 1 | **Mắt có thấy dấu bị cắt ở `lineHeightMultiple 0.7` không** | §5.3 là phép đo **hình học** (mực vượt khung dòng). Tràn khung ≠ chắc chắn bị cắt — còn tuỳ view cha có clip hay không | Build, đặt tên họp `"Đã Ế Ộ Ữ"`, **chụp màn hình** menu bar | ~15 phút, S3 |
| 2 | **Hành vi khi thanh menu hết chỗ / máy có tai thỏ** | Không đo được từ code. Phụ thuộc máy Duy và số item đang có | Duy đặt giới hạn 55 ký tự rồi nhìn xem item nào biến mất | 2 phút, Duy |
| 3 | **VoiceOver thật sự đọc ra cái gì** | Chưa bật VoiceOver | ⌘F5, trỏ vào status item, nghe | 3 phút, S4 |
| 4 | **Phủ font trên macOS CŨ hơn** | §5.4 đo trên **đúng một máy**: Darwin 25.5.0 của Duy. Đồng nghiệp chạy macOS cũ hơn có thể khác | Chạy lại đoạn `CTFontCopyCharacterSet` trên máy đồng nghiệp | 1 phút/máy |
| 5 | **Regex filter có normalize NFC không** | Chưa đọc `UtilsRegex` / đường lọc sự kiện | Đọc code + một test với tên NFD | 20 phút, S3 |
| 6 | **Chữ tiếng Việt trong brief này là của TÔI, không phải của Content** | Tôi cần chuỗi thật để đo chiều rộng, nên tự viết. Chúng là **vật liệu đo**, không phải bản dịch được duyệt | Content viết bản thật, Design đo lại §5.2 | S2 |
| 7 | **Ngân sách sidebar 128pt** | Đo 180pt (tối thiểu) rồi **ước lượng** icon ~20pt + padding ~24. Chưa đo bằng view inspector | Xcode view debugger | 10 phút, S3 |
| 8 | **Sáng/tối và màu nhấn** | Đọc từ code, **chưa dựng để nhìn** | Build, chụp cả hai chế độ | S3 |

---

## 8. VIỆC KHÔNG AGENT NÀO LÀM THAY ĐƯỢC — Quy tắc 6

| # | Việc | Vì sao phải là Duy |
|---|---|---|
| 1 | **Chọn 1 trong 3 hướng §4** | Là quyết định gu, và nó quyết cái Duy nhìn 50 lần mỗi ngày |
| 2 | **Câu thay cho ONE-PAGER §2** | File có `owner: Duy`. §0 đang chặn |
| 3 | **Tên app** | Apache-2.0 §6 + `WRITER-NOTES.md §1`. Chặn 20 chuỗi dịch (§5.6d) |
| 4 | **Đọc to bản dịch tiếng Việt** | Không máy nào biết câu nào nghe như phần mềm dịch máy. Đây là phép thử duy nhất cho tính từ **Quen** |
| 5 | **Chấp nhận mất tên họp trên thanh menu** (nếu chọn A) | Đổi thói quen hằng ngày của chính Duy |
| 6 | **Bỏ hay giữ `FullscreenNotification`** | Bề mặt duy nhất tự chiếm màn hình. Mâu thuẫn tính từ **Lặng**. Là quyết định sản phẩm |

---

## 9. NGUỒN SỐ LIỆU

Mọi con số ở §3, §5, §6 đo bằng ba script Swift chạy trên máy Duy ngày 2026-10-13:
`CTFontCopyCharacterSet` (phủ glyph) · `CTLineGetBoundsWithOptions(.useGlyphPathBounds)` (chiều cao
mực) · `NSString.size(withAttributes:)` (chiều rộng). Đường dẫn code trích trong bảng là
file:dòng có thật, đọc trực tiếp trên nhánh `feat/presence-gate`.

**same vendor, same priors — no external verifier ran.**
