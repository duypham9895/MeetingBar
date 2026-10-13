---
loại: THAM CHIẾU — không ai "review" file này, chỉ mở ra lúc build
owner: Phòng Content (chuỗi) + SWE (hạ tầng)
freshness: 2026-10-13
nguồn số: đo trên nhánh feat/presence-gate, máy Duy, macOS 26.5.1 (build 25F80), 2026-10-13
---

# VI-LOCALIZATION — kế hoạch tiếng Việt cho 355 chuỗi

> Mọi con số trong file này **tái lập được bằng lệnh kèm theo**. Chỗ nào không có lệnh thì ghi rõ là ước lượng.
> Tự kiểm phía tác giả — **same vendor, same priors — no external verifier ran.**

---

## 1. HẠ TẦNG — hai lỗi chặn, và ba chỗ phải sửa

### 1.1 Lỗi B1 — `vi.lproj` một mình KHÔNG đủ

`AppLanguage` (`MeetingBar/Utilities/Constants.swift:170–188`) là enum Swift **cứng**, 17 case, trong khi đĩa có **23** thư mục `.lproj`. Thiếu `case vietnamese = "vi"` thì **không có dòng "Tiếng Việt" trong Tùy chọn**, dù file dịch đã nằm đúng chỗ.

Hệ quả phụ đã đo: **7 ngôn ngữ đã dịch nhưng người dùng không chọn được** — `bg` (341 khoá), `ko` (341), `ta` (341), `zh-Hans` (342), `hu` (341), `pt` (341), `enm` (2). Chúng chỉ kích hoạt qua ngôn ngữ hệ thống.

### 1.2 Lỗi B2 — tiếng Ukraina ĐANG HỎNG, và đó đúng là cơ chế tiếng Việt sắp dùng

```
Constants.swift:173   case ukrainian = "ua"
đĩa                   uk.lproj          ← lệch
```

`I18N.checkLanguageAvailability("ua")` → `Bundle.main.path(forResource:"ua", ofType:"lproj")` → `nil` → `resetToDefault()`. **Chọn Українська thì app im lặng quay về ngôn ngữ hệ thống, không báo gì.** Đã xác minh bằng script Swift chạy trên bản build thật: `ua lproj NOT resolvable`.

⇒ **Thư mục bắt buộc tên `vi.lproj`, khớp từng ký tự với rawValue `"vi"`.** Gõ `vn` là hỏng y hệt, không có cảnh báo nào.

### 1.3 Ba chỗ phải sửa — toàn bộ hạ tầng

| # | File | Sửa gì |
|---|---|---|
| 1 | `MeetingBar/Resources /Localization /vi.lproj/Localizable.strings` | tạo mới (⚠ **tên hai thư mục cha đều có dấu cách ở cuối** — mọi lệnh shell phải quote) |
| 2 | `MeetingBar/Utilities/Constants.swift:170–188` | thêm `case vietnamese = "vi"` |
| 3 | `MeetingBar/UI/Views/Shared.swift:185–202` | thêm `Text("Tiếng Việt").tag(AppLanguage.vietnamese)` — **vào Group thứ hai** (SwiftUI `Group` giới hạn 10 con; Group 1 đã đủ 10, Group 2 mới có 6) |
| (4) | `MeetingBar.xcodeproj/project.pbxproj:188–213` | thêm `vi` vào `knownRegions` — **không bắt buộc để build chạy**, nhưng nên làm cho nhất quán với 23 mục còn lại |

**Đã kiểm thực nghiệm, không phải suy luận:** tạo `vi.lproj` với một khoá thăm dò, **không** đụng `knownRegions`, **không** đụng `Info.plist` → `xcodebuild -scheme MeetingBar -configuration Debug CODE_SIGNING_ALLOWED=NO build` → **BUILD SUCCEEDED**; `MeetingBar.app/Contents/Resources/vi.lproj/Localizable.strings` tồn tại; `Bundle.localizations` trả về 25 mục gồm `vi`; `Bundle.preferredLocalizations(forPreferences:["vi-VN","vi"])` → `["vi"]`. Lý do cơ chế: `project.pbxproj` dùng `objectVersion = 71` + `PBXFileSystemSynchronizedRootGroup`, **không có một `PBXVariantGroup` nào**, hai `PBXResourcesBuildPhase` đều `files = ()` ⇒ Xcode đồng bộ tài nguyên thẳng từ đĩa.

### 1.4 Hai điều kiện build phải biết trước

```sh
# Build Debug mặc định THẤT BẠI trên máy này: "No profiles for leits.MeetingBar were found"
xcodebuild -scheme MeetingBar -configuration Debug \
  CODE_SIGNING_ALLOWED=NO CODE_SIGN_IDENTITY= CODE_SIGNING_REQUIRED=NO build
```

SwiftLint **không có trên máy** (`.swiftlint.yml` có trong repo, công cụ thì không) ⇒ mọi vi phạm quy ước hiện không được bắt.

### 1.5 Fallback theo TỪNG KHOÁ — tin tốt và tin xấu trong cùng một dòng

`I18N.localizedString` (`I18N.swift:63–70`) thiếu khoá thì **rơi về `englishBundle`**, không crash, không hiện key trần. Nghĩa là:

- **Tin tốt:** dịch dần an toàn về kỹ thuật, không bao giờ vỡ.
- **Tin xấu:** dịch 300/339 ⇒ **39 chỗ tiếng Anh nằm lẫn, không một cảnh báo nào**, và không ai phân biệt được "chưa dịch" với "dịch hỏng". Đây là **chỗ hai phòng bất đồng** — xem `batDong` #2.

---

## 2. BẢNG TỪ VỰNG

### 2.1 Nguồn — là phép đo, không phải trí nhớ

Mọi ô ghi **Apple** lấy trực tiếp từ file tiếng Việt Apple đang ship trên máy Duy:

```sh
# macOS 26.5.1 (25F80)
plutil -convert json -o - "/System/Applications/Calendar.app/Contents/Resources/<...>.loctable"
plutil -convert json -o - "/System/Library/Frameworks/AppKit.framework/Resources/<...>.loctable"
ls "/System/Library/CoreServices/Finder.app/Contents/Resources/vi.lproj"
```

### 2.2 Mười một khái niệm bắt buộc

| EN | **Chọn** | Nguồn | Không chọn — và vì sao |
|---|---|---|---|
| meeting | **cuộc họp** | — | `buổi họp` (nghe như sự kiện cả buổi) · `cuộc gọi` (sai nghĩa) |
| event | **sự kiện** | Apple: `Event → Sự kiện`, `All-Day Events → Sự kiện cả ngày` | **`cuộc họp`** — xem §2.3, đây là cái bẫy lớn nhất |
| calendar | **lịch** | Apple: `Calendar → Lịch`, `Calendar Sources → Nguồn Lịch` | `lịch biểu` (Hán-Việt thừa) |
| join | **tham gia** | Apple: `Join → Tham gia` | `vào` — ngắn hơn, nhưng chuỗi join chỉ nằm trong menu xổ xuống, mà `NSMenu` tự giãn ⇒ không có ràng buộc độ dài ở đó |
| link | **link** ⚠ | Apple nói `Liên kết` — **đây là chỗ cố ý lệch** | `liên kết cuộc họp` = 5 âm tiết; văn phòng Việt nói *"gửi link họp đi"*. **Cần Duy chốt** |
| notification | **thông báo** | Apple: `Notification Center → Trung tâm thông báo` | — |
| dismiss | **TÁCH LÀM HAI** | Apple: `Dismiss → Bỏ qua` | xem §2.4 |
| all-day | **cả ngày** | Apple: `All-Day → Cả Ngày` | `trọn ngày` · `nguyên ngày` |
| upcoming | **sắp tới** | — | `sắp diễn ra` (dài hơn, không thêm nghĩa) |
| source / provider | source = **nguồn lịch**<br>provider = **dịch vụ họp** | Apple: `Calendar Sources → Nguồn Lịch` | **Không được gộp cả hai thành `nhà cung cấp`.** App phân biệt thật: `preferences_calendar_source_title` nói về **nơi đọc dữ liệu** (macOS Calendar / Google API); `meetingProvider` nói về **Zoom/Meet/Teams** |
| status bar / menu bar | **thanh menu** (một từ duy nhất) | Apple: `Add to Menu Bar → Thêm vào thanh menu` | `thanh trạng thái` — Apple không dùng cho chỗ này. Bản gốc tiếng Anh **dùng lẫn lộn hai từ cho cùng một thứ**; bản Việt thống nhất một |

### 2.3 `event` ≠ `meeting` — quy tắc một dòng

App **thật sự phân biệt**, và có chuỗi chứng minh:

```
"preferences_appearance_events_no_meeting_link_title" = "Events without a meeting link";
"shared_fullscreen_notification_without_link_toggle"  = "Also show fullscreen notifications for events without meeting links";
"preferences_advanced_script_link_only_help"          = "Runs only for events with meeting links.";
```

```
   ✗  "Cuộc họp không có link cuộc họp"      ← vô nghĩa
   ✓  "Sự kiện không có link họp"            ← đúng, và đọc trôi
```

> **`sự kiện`** = mọi mục trong lịch. **`cuộc họp`** = sự kiện **có link vào được**.
> Tiếng Anh dùng `event` → `sự kiện`. Dùng `meeting` → `cuộc họp`. **Không hoán đổi vì nghe xuôi tai hơn.**

Hệ quả phải chấp nhận: `status_bar_section_join_next_meeting` = "Join next **event** meeting" → **"Tham gia cuộc họp kế tiếp"**. Tiếng Anh thừa chữ `event` ở đây; bản Việt bỏ, vì mục menu này chỉ bật khi sự kiện **có** link.

### 2.4 `dismiss` có HAI nghĩa trong cùng một app

| Nghĩa | Chuỗi | **Chọn** | Vì sao |
|---|---|---|---|
| Ẩn cuộc họp khỏi menu, **đảo ngược được** | `status_bar_menu_dismiss_curent_meeting` · `..._next_meeting` · `status_bar_submenu_dismiss_meeting` · `..._undismiss_meeting` · `status_bar_menu_remove_all_dismissals` · `status_bar_event_dismissed_mark` · 3 chuỗi `notification_*_dismiss*` | **ẩn / bỏ ẩn** | Apple dịch `Dismiss → Bỏ qua`, nhưng `"Bỏ bỏ qua"` không viết được. Cặp `ẩn ↔ bỏ ẩn` đọc tự nhiên và đúng cơ chế. **Cố ý lệch khỏi Apple, có lý do** |
| Tắt thông báo đang hiện | `fullscreen_notification_dismiss_action` · `notifications_meetingbar_dismiss_event_action` | **Bỏ qua** | Đúng Apple, và đúng nghĩa |

### 2.5 Phần còn lại — chốt theo Apple, không bàn thêm

| EN | VI | EN | VI |
|---|---|---|---|
| Preferences | **Tùy chọn** | Close | **Đóng** |
| Quit | **Thoát** | Refresh | **Làm mới** |
| Advanced | **Nâng cao** | General *(sidebar)* | **Chung** |
| Alerts *(kiểu thông báo macOS)* | **Cảnh báo** | Today / Tomorrow | **Hôm nay / Ngày mai** |
| Attendees | **Người tham dự** | Organizer | **Người tổ chức** |
| Accepted / Declined | **Đã chấp nhận / Đã từ chối** | Tentative | **Dự kiến** |
| Pending | **Chờ phản hồi** | Now | **Bây giờ** |

**Chính tả — đã chốt, không cần hỏi:** kiểu đặt dấu **mới**, theo đúng Apple: `Tùy chọn` (không `Tuỳ chọn`), `Xóa` (không `Xoá`), `hóa` (không `hoá`). Bằng chứng: `Preferences → Tùy chọn`, `Remove from Menu Bar → Xóa khỏi thanh menu`, `Alerts & Shortcuts Automations → Tự động hóa cảnh báo & phím tắt`. Lý do: app đứng cạnh macOS tiếng Việt trên cùng màn hình; lệch chính tả với hệ điều hành trông như lỗi.

**⚠ Chưa kiểm được:** `Banners → "Biểu ngữ"`. Quét 33 file loctable của UserNotifications, NotificationCenter, System Settings, PreferencePanes: **không tìm thấy cặp `Banner`→vi**. `"Biểu ngữ"` là **suy đoán**, khác hẳn `Cảnh báo` đã kiểm được. Nó nằm trong chuỗi dài nhất file. **Kiểm trước khi dịch nhóm thông báo:** đổi macOS sang tiếng Việt → System Settings → Thông báo → đọc nhãn thật. 5 phút.

---

## 3. PHẠM VI — 355 khoá đi về đâu

### 3.1 Trừ dần, có nguồn pháp lý

| | Số | Nguồn |
|---|---|---|
| Khoá trong `en.lproj` | **355** | `grep -cE '^"' "MeetingBar/Resources /Localization /en.lproj/Localizable.strings"` |
| − chuỗi chết (không xuất hiện ở bất kỳ `.swift` nào) | **3** | `google_oauth_unavailable_suffix` · `onboarding_calendar_source_single` · `preferences_advanced_wrong_location_button` |
| − khối Patron/Store + Contact, **CL-4 ra lệnh gỡ** | **~16** | `LEGAL-REVIEW` CL-4 *"Gỡ, không đổi tên"*, mức **chặn phát file** |
| **= cần dịch** | **~336–339** | con số chính xác chốt sau khi SWE gỡ UI Patron |

**Ba rổ của 20 chuỗi chứa chữ `MeetingBar`** (đếm: `grep -c MeetingBar en.lproj/Localizable.strings` → 20):

| Rổ | ~Số | Phải làm gì |
|---|---|---|
| **ĐỔI TÊN** | ~14 | window titles · `"\U00A0MeetingBar"` · Quit · onboarding · notifications ⇒ **bị chặn bởi quyết định tên của Duy** |
| **GIỮ TÊN** | 1 | `preferences_general_meeting_bar_description` = *"MeetingBar is an open-source app created by Andrii Leitsius 🇺🇦"*. `LEGAL-REVIEW §2`: Duy **ĐƯỢC** viết *"fork của MeetingBar, tác giả gốc…"* — đó là **mô tả nguồn gốc**, §6 cho phép rõ ràng. §4(c) **cấm xoá attribution**. ⇒ dịch phần mô tả, **không đụng tên** |
| **XOÁ KHỎI PHẠM VI** | ~16 | Contact · patron · store_patronage ⇒ CL-4. `leits.MeetingBar folder` là **đường dẫn**, đi theo bundle id, không dịch |

⇒ **~325 chuỗi KHÔNG bị chặn bởi quyết định tên. Content bắt đầu được ngay.**

### 3.2 Năm nhóm, chia theo mức người dùng nhìn thấy

| Nhóm | Gồm | Chuỗi | Thấy khi nào | Ước |
|---|---|---|---|---|
| **N1** | `status_bar_*` (70) + 29 chuỗi đầu file (`general_*`, `message_*`, `next_meeting_*`) | **99** | mỗi lần mở menu | 3–4h |
| **N2** | `notifications_*` (13) + `shared_*` (9) | **22** | mỗi cuộc họp | 1h |
| **N3** | `onboarding_*` (29) + `access_screen_*` (10) + `calendars_screen_*` (1) | **40** | **đúng một lần/người** | 1,5h |
| **N4** | 6 tab Preferences + sidebar + section + status | **173** | lúc chỉnh cài đặt | 4–5h |
| **N5** | `link_url_*` (5) + `constants_*` (5) + `window_title_*` (3) + 3 chuỗi Google OAuth | **16** | gần như không bao giờ | 0,5h |

**Tổng ≈ 10–12 giờ người — là ƯỚC, không có lần dịch nào đã bấm giờ.**

### 3.3 Thứ tự — và vì sao nó đang bị tranh cãi

```
   N4  →  N2  →  N3  →  N1  →  N5
   │                      │
   │                      └─ N1 là status_bar_*, nhóm DUY NHẤT ba hướng §3 khác nhau.
   │                         Dịch trước khi Duy chọn hướng là đặt cược 3–4 giờ.
   └─ N4 (173 chuỗi Preferences) không phụ thuộc hướng nào ⇒ đủ việc để không ai phải chờ.
```

(Phòng Content đề xuất **N1 trước** vì nó là thứ Duy gặp hằng ngày. Bất đồng này còn mở — `batDong` #3.)

### 3.4 KHÔNG ĐƯỢC DỊCH — giữ nguyên tiếng Anh

| Loại | Ví dụ trong file này |
|---|---|
| **Tên dịch vụ** | Zoom · Google Meet · Microsoft Teams · Jitsi · Slack · Workplace · Riverside · Tuple · MeetInOne · Fantastical — gồm cả 11 chuỗi `preferences_meeting_opening_mode_*`: **chúng là tên riêng, không phải nhãn** |
| **Tên kỹ thuật** | AppleScript · URL · PWA · regex · OAuth · CalDAV · iCloud · Exchange · `eventStartScript.scpt` · `docs/GOOGLE-OAUTH-SETUP.md` · đường dẫn `User → Library → Application Scripts → …` |
| **Tên app sau khi đổi** | giữ nguyên, **không dịch, không biến cách** |
| **`\U00A0`** đầu `preferences_appearance_status_bar_icon_*_value` | **non-breaking space cố ý** để canh lề icon. Giữ nguyên ký tự đó, chỉ dịch phần chữ sau nó |

### 3.5 Hai ốc đảo tiếng Anh mà `vi.lproj` KHÔNG chạm tới được

| | Chi tiết | Quyết định |
|---|---|---|
| **Changelog** | `UI/Views/Changelog/Changelog.swift`, 211 dòng, **113 chuỗi `Text("literal")` hardcode**, chưa từng dịch sang ngôn ngữ nào. Chiếm 113/132 toàn bộ chuỗi hardcode của app | **CẮT** ở Hướng 1 và 3. Đây là lịch sử phát hành của *upstream* |
| **Main.storyboard** | `Base.lproj`, 57 KB, **103 tiêu đề menu AppKit** (File, Edit, Format, Bring All to Front…), **không có `Main.strings` ở bất kỳ `.lproj` nào** | **Ở lại tiếng Anh trong MỌI ngôn ngữ**, kể cả 23 bản dịch hiện có. `LSUIElement = true` nên menu này chỉ hiện khi một cửa sổ app được focus. **Nói ra, đừng hứa** |

### 3.6 Cảnh báo cho ai định "dọn chuỗi không dùng"

**68/355 khoá được gọi GIÁN TIẾP** qua nội suy chuỗi (`preferenceLabel("key")` trong `AppearanceTab.swift`…). Một trình kiểm tĩnh chỉ tìm literal `"key".loco` sẽ báo nhầm **68 khoá đang sống là chết**. Chuỗi chết thật chỉ có **3**.

---

## 4. BẪY KỸ THUẬT

### 4.1 Placeholder — chỉ 4 chuỗi có nhiều hơn một

Soát toàn file: 33 khoá có placeholder (27 × `%@`, 6 × `%d`); **đúng 4 chuỗi** có ≥2.

| Chuỗi | EN | Có đảo thứ tự không | Kết luận |
|---|---|---|---|
| `message_event_script_execution_failed_text` | `The script in %@ failed: %@` | **CÓ** nếu muốn nêu lỗi trước | ⚠ phải dùng dạng đánh số |
| `preferences_bookmarks_new_bookmark_already_exist` | `%@ already has this link/phone number:\n%@` | Không | giữ `%@` |
| `status_bar_submenu_duration_all_day` | `%@ - %@ (%@ minutes)` | Không | giữ `%@` |
| `onboarding_progress` | `Step %@ of %@` | Không → `Bước %@/%@` | giữ `%@` |

> **Luật:** một chuỗi **hoặc toàn `%@`, hoặc toàn `%1$@ %2$@`**. Trộn hai kiểu trong cùng một chuỗi là hành vi không xác định của Foundation.

Hạ tầng đã kiểm: `I18N.localizedString(for:_:_:)` (`I18N.swift:79,84`) truyền tham số theo **đúng thứ tự cố định** rồi gọi `String.localizedStringWithFormat` ⇒ dạng đánh số **chạy được, không cần sửa Swift**. Nhưng `grep '%[0-9]\+\$'` trên cả 23 ngôn ngữ → **rỗng**: tiếng Việt sẽ là ngôn ngữ **đầu tiên** dùng nó ⇒ **test bằng mắt, không suy ra từ đọc code**.

### 4.2 Số nhiều — đây là một khoản TIẾT KIỆM

```sh
find . -name '*.stringsdict' -o -name '*.xcstrings'   # → KHÔNG CÓ FILE NÀO, cho cả 23 ngôn ngữ
```

Upstream né bài toán số nhiều bằng key riêng (`general_one_minute_before` / `_three_` / `_five_`). Bốn chuỗi `%d` còn lại không biến đổi theo số:

| Chuỗi | VI |
|---|---|
| `timeline_accessibility_label` | Dòng thời gian, %d sự kiện |
| `status_bar_submenu_attendees_title` | Người tham dự (%d) |
| `preferences_appearance_status_bar_next_event_stepper` | %d phút |
| `preferences_appearance_menu_shorten_event_title_stepper` | %d ký tự |

**Tiếng Việt có đúng một dạng số nhiều (`other`) trong CLDR ⇒ KHÔNG cần `.stringsdict`, và KHÔNG được tạo một cái.**

### 4.3 NFC — hai chỗ, kết quả khác nhau

| Chỗ | Kết luận | Bằng chứng |
|---|---|---|
| **Cắt tiêu đề trên thanh menu** | **AN TOÀN SẴN — đừng tốn công "sửa"** | `StatusBarPresentation.swift:276–286` dùng `.count` + `index(_:offsetBy:)` trên `Character`, tức **grapheme cluster**. `ế` là **một** grapheme ở cả NFC lẫn NFD |
| **Khoá trong `.strings`** | **Không rủi ro** | khoá là ASCII thuần; chỉ giá trị có dấu |
| **Nội dung file `vi.lproj`** | **Phải lưu NFC** | bộ gõ tiếng Việt có thể phát ra NFD |
| **`CFBundleDisplayName` / tên file `.app`** | **NGUY HIỂM** | zip rồi gửi là đúng chỗ NFC/NFD cắn. `WRITER-NOTES §1` đã chốt ASCII thuần cho bundle id |
| **`uniqueMetadataValues`** | **CÓ, nhưng nhẹ** | `MenuBuilder.swift:289–301` dùng `.folding([.caseInsensitive,.diacriticInsensitive])` trên `[timeRange, meetingProvider, account, calendar.title]` ⇒ lịch tên `"Cá nhân"` và tài khoản `"Ca nhan"` **gộp làm một, mất một cái**. Xác suất thấp với 5 người ⇒ **ghi lại, không sửa ngay** |
| **Regex filter lọc tên cuộc họp** | **CHƯA KIỂM** | nếu không normalize, tên gõ ở NFD không khớp bộ lọc viết ở NFC |

Lệnh kiểm NFC, phải chạy sau chuỗi tiếng Việt đầu tiên và phải in `OK`:

```sh
python3 -I -c "
import unicodedata as u
p='MeetingBar/Resources /Localization /vi.lproj/Localizable.strings'
s=open(p,encoding='utf-8').read()
print('NFD! phải chuẩn hoá lại' if s!=u.normalize('NFC',s) else 'OK — NFC')"
```

### 4.4 Độ dài — tiền đề của xưởng KHÔNG áp nguyên cho app này

`docs/lessons.md` ghi *"tiếng Việt dài hơn 20–30%"*. **Hai phép đo độc lập đều không tái lập được con số đó**, nhưng chúng cũng **không khớp nhau** — xem `batDong` #1.

| Phép đo | Đơn vị | Mẫu | Kết quả |
|---|---|---|---|
| Design | **chiều rộng pixel** 13pt, `NSString.size(withAttributes:)` | 3 cặp câu | **+47% · −5% · −18%** |
| Content | **code point** sau NFC | 12 chuỗi khó nhất | **−16,7%** |

Kết luận chung được cả hai: **chiều rộng là hệ quả của CÁCH DỊCH, không phải của ngôn ngữ.** `Weekly Standup` phình **+47%** vì dịch thành `Họp giao ban hằng tuần`; viết `Giao ban` thì **ngắn hơn** bản Anh.

**⇒ Công cụ là NGÂN SÁCH KÝ TỰ trong `.strings`, không phải sửa layout:**

```
   sidebar            ≤ 12 ký tự
   nhãn nút           ≤ 16
   hàng Preferences   ≤ 28
   mọi thứ lên thanh menu  ≤ 22      ← chỉ tồn tại nếu Duy chọn Hướng 2 hoặc 3
```

**Thuật ngữ bề mặt hệ thống KHÔNG chịu ngân sách** — nếu macOS tiếng Việt đã có từ chuẩn thì dùng từ đó, kể cả khi dài hơn. Ngân sách chỉ áp cho câu do app tự viết.

**Rủi ro độ dài thật nằm ở đâu:**

| Rủi ro | Thật không | Việc phải làm |
|---|---|---|
| Menu xổ xuống tràn | **Không** — `NSMenu` tự giãn theo nội dung dài nhất | không làm gì |
| Chữ trên thanh menu tràn | **Gần như không** — thứ hiển thị ở đó là **tiêu đề sự kiện của người dùng** (vốn đã tiếng Việt), bị cắt bởi `statusbarEventTitleLength`. Chuỗi *của ta* ở đó chỉ có **một**: `general_meeting` | dịch `Meeting → **Họp**` (3 ký tự). **Không dùng "Cuộc họp"** ở riêng chuỗi này |
| **Chiều cao dòng** | **CÓ — rủi ro thật** | `lineHeightMultiple = 0.7` ⇒ khung 10,50pt; mực `Ế` cao **11,43pt**, `Ệ` cao **13,82pt**. Cộng `baselineOffset: -3` đẩy dòng 1 xuống ⇒ đáy `ộ ặ ụ` đâm vào đỉnh dòng giờ 9pt. **Chỉ chạm nếu chọn Hướng 3** |
| Cửa sổ Preferences | thấp | **28 chỗ `.frame(width:/minWidth:)` cứng** (hay gặp: 500 × 5 lần, 700 × 4, 860, minWidth 760/700/180). Sidebar tối thiểu 180pt ⇒ ngân sách nhãn ~128pt; nhãn dài nhất đo được `Hiển thị & Sự kiện` = **107pt**, lọt nhưng chỉ dư 21pt ⇒ **đề nghị rút thành `Hiển thị` (47pt)** |

**Bản rút gọn — chỉ cho chuỗi có nguy cơ, không rút gọn đại trà:**

| key | Bản đầy đủ | **Dùng trong app** |
|---|---|---|
| `general_meeting` | Cuộc họp | **Họp** |
| `preferences_appearance_events_value_only_with_link` | chỉ hiện những sự kiện có link họp | **chỉ cái có link họp** |
| `preferences_appearance_status_bar_ongoing_time_ten_before_next_value` | ẩn trước sự kiện kế tiếp 10 phút | **ẩn trước sự kiện sau 10 phút** |
| `status_bar_event_status_now` | bây giờ (còn %@) | **còn %@** |
| `status_bar_event_status_in` | sau %@ nữa | **sau %@** |

*(Năm dòng này chỉ áp dụng nếu Duy chọn **Hướng 2 hoặc 3**. Dưới **Hướng 1**, `general_meeting` không hiện trên thanh menu và bảng này vô hiệu.)*

### 4.5 Font — đã đo, đã gỡ

```swift
let cs = CTFontCopyCharacterSet(NSFont.systemFont(ofSize: 13)) as CharacterSet
// dò 105 code point: U+1EA0…U+1EF9 (90) + Ă ă Đ đ Ơ ơ Ư ư + 7 dấu tổ hợp
//   U+0300 0301 0302 0303 0306 0309 0323
// → thiếu 0 / 105, trên systemFont(13), systemFont(12) và menuBarFont
```

App **không khai báo font tuỳ chỉnh nào** — kiểm ba hướng, cả ba rỗng: không file `.ttf/.otf/.ttc`; `ATSApplicationFontsPath`/`UIAppFonts` → 0; `NSFont(name:` / `Font.custom` → 0. ⇒ **không cần nhúng font, không có vấn đề giấy phép font, không có rơi-về-font-hệ-thống giữa câu.** Bài học #1 của xưởng **đã gỡ cho app này**. (Đo trên **một máy**, Darwin 25.5.0 — "đủ trên máy này" không bao giờ nghĩa là "đủ trên mọi máy".)

### 4.6 Ngày giờ — đã sẵn sàng, miễn phí

`I18N.instance.locale` được truyền vào `DateFormatter` ở 5 chỗ (`MenuBuilder:317,671` · `DayTimelineView:197` · `MBEvent+MeetingBar:14` · `StatusBarItemController:528`). Thêm `case vietnamese = "vi"` là `Locale(identifier:"vi")` **tự động chảy vào** tất cả.

### 4.7 Accessibility — ba dòng, làm luôn khi dịch

| Thứ | Hiện trạng đo được | Làm gì |
|---|---|---|
| VoiceOver trên thanh menu | **không có nhãn nào** — cả tầng UI chỉ có **đúng 1** `accessibilityLabel` (`DayTimelineView.swift:192`). VoiceOver đọc thẳng `attributedTitle`; bố cục 2 dòng có `\n` ⇒ đọc thành hai mảnh rời | `setAccessibilityLabel("Cuộc họp kế tiếp: Giao ban, còn 5 phút")` — **tách khỏi chuỗi hiển thị** |
| Tương phản | dòng giờ dùng `NSColor.lightGray` (`:484`) — màu **cố định**, không theo sáng/tối | đổi sang `NSColor.secondaryLabelColor` — tự theo sáng/tối **và** theo Increase Contrast, miễn phí |
| Dynamic Type | macOS **không có** Dynamic Type toàn hệ thống như iOS — **nói thẳng là không áp dụng, đừng hứa**. Nhưng status bar hardcode 13/12/9pt, và 9pt là cỡ nhỏ nhất app | thêm một lý do nữa **không chọn Hướng 3** |

---

## 5. MƯỜI CHUỖI DỊCH THỬ — Duy đọc để cảm giọng

Chọn đúng 10 chuỗi mà **bản dịch dở lộ ra ngay**. Tất cả theo giọng **không xưng hô** (giọng A).

| # | key | EN | **VI** | Khó ở chỗ nào |
|---|---|---|---|---|
| 1 | `next_meeting_empty_message` | Woohoo! It's time to make cocoa | **Hôm nay hết họp.** | Thành ngữ. "Làm ca cao" vô nghĩa ở VN. Phòng Content đề xuất *"Rảnh rồi. Đi pha cà phê thôi."*; PM chọn bản ngắn vì tính từ **Lặng** — xem `batDong` #5 |
| 2 | `general_meeting` | Meeting | **Họp** | Chuỗi **duy nhất** của ta hiện trên thanh menu. "Cuộc họp" chiếm gấp đôi chỗ mà không thêm nghĩa |
| 3 | `status_bar_submenu_undismiss_meeting` | Remove dismissal | **Bỏ ẩn** | Cặp đảo ngược. `Bỏ qua ↔ Bỏ bỏ qua` không viết được ⇒ cả cụm đổi sang `ẩn ↔ bỏ ẩn` |
| 4 | `notification_all_dismissals_removed_message` | All dismissed meetings are back in action | **Mọi cuộc họp đã ẩn đều hiện lại.** | "back in action" dịch sát ("trở lại hoạt động") thành ngôn ngữ doanh nghiệp. Bỏ phần vui, giữ phần đúng |
| 5 | `shared_send_notification_no_alert_style_tip` | Note: Notifications are set to Banners… switch to Alerts in your macOS notification settings. | **Lưu ý: thông báo đang ở kiểu Biểu ngữ nên chỉ hiện thoáng qua rồi tắt. Muốn nó ở lại tới khi bấm bỏ qua, đổi sang Cảnh báo trong cài đặt thông báo của macOS.** | Dài nhất file (183 ký tự). `Cảnh báo` **đã kiểm**; `Biểu ngữ` **CHƯA** (§2.5). Sai hai từ này là chỉ người dùng đi tìm một mục **không tồn tại** |
| 6 | `preferences_appearance_events_value_only_with_link` | show only those with meeting links | **chỉ hiện cái có link họp** | `event` và `meeting` đụng nhau trong một dòng picker ngắn — phép thử sống của §2.3 |
| 7 | `status_bar_event_status_now` | now (%@ left) | **còn %@** | Placeholder trong chuỗi cực ngắn, sát thanh menu. "bây giờ (còn %@)" đúng nhưng thừa |
| 8 | `status_bar_error_link_missed_title` | Ouch! Can't join the %@ | **Không vào được %@** | `%@` là **tên dịch vụ** ⇒ mạo từ "the" biến mất; "Ouch!" không có tương đương không-trẻ-con |
| 9 | `onboarding_success_title` | You're ready | **Xong rồi** | Phép thử register. "Bạn đã sẵn sàng" = văn dịch. "Xong rồi" = cách người Việt thật sự nói cuối một quy trình cài đặt |
| 10 | `message_event_script_execution_failed_text` | The script in %@ failed: %@ | **Script trong %@ lỗi: %@** | Phép thử placeholder (§4.1). Thứ tự **không** đảo ⇒ giữ `%@`. Nếu ai muốn nêu lỗi trước thì **cả hai** phải đổi sang `%1$@`/`%2$@` cùng lúc |

---

## 6. KIỂM BẰNG MÁY — T1, thêm vào `scripts/vibe-check.sh`

**Không kiểm `count(en) == count(vi)`** — sau khi CL-4 gỡ khối Patron, `en.lproj` còn 355 dòng nhưng chỉ ~339 khoá hữu dụng ⇒ phép kiểm đó **đỏ vĩnh viễn**, và một test đỏ giả sẽ bị học cách phớt lờ. Đó là cách giết một cổng kiểm.

```
   ĐÚNG:  keys(vi)  ⊇  keys(en)  \  keys(DANH-SÁCH-GỠ)
```

Danh sách gỡ phải là **một file đọc được** (`gates/02-design/STRINGS-OUT-OF-SCOPE.md`), không phải một con số trong trí nhớ. Kèm phép kiểm NFC ở §4.3.

---

## 7. CHƯA XÁC MINH ĐƯỢC

| # | Chưa biết | Vì sao | Gỡ bằng | Tốn |
|---|---|---|---|---|
| 1 | **5 đồng nghiệp có muốn tiếng Việt không** | **không ai hỏi họ; Duy là n=1.** Có thể họ đang dùng macOS tiếng Anh | một tin nhắn | 5 phút — **rẻ nhất, chưa ai làm** |
| 2 | **`Banners → "Biểu ngữ"`** | quét 33 loctable không có cặp `Banner`→vi. Đây là **suy đoán**, khác `Cảnh báo` đã kiểm | đổi macOS sang tiếng Việt, đọc nhãn thật | 5 phút, **trước khi dịch N2** |
| 3 | **Từ Apple ≠ từ người Việt thấy tự nhiên** | kiểm được *Apple ship chữ gì*, **không** kiểm được *người Việt thấy có tự nhiên không* | 5 đồng nghiệp đọc §5 | 15 phút |
| 4 | **Tỉ lệ co/giãn thật** | hai phép đo **không khớp nhau** (§4.4) và cả hai dùng chuỗi do chính người đo viết | đo lại sau khi xong nhóm đầu tiên | — |
| 5 | **Layout có vỡ không** | đếm được 28 chỗ `.frame` cứng nhưng **chưa dựng `vi.lproj` đầy đủ rồi nhìn** | build + chụp | trong lát dịch |
| 6 | **Dấu có bị cắt trên màn hình không** | §4.4 là phép đo **hình học**; tràn khung không chắc chắn nghĩa là bị cắt — AppKit vẫn có thể vẽ ra ngoài nếu view cha không clip | tên họp `Đã Ế Ộ Ữ` + chụp màn hình | 15 phút |
| 7 | **Bộ gõ của Duy phát NFC hay NFD** | chưa test trên máy Duy | lệnh §4.3 | 1 phút |
| 8 | **`%1$@` chạy đúng qua `I18N`** | đường đi hợp lệ khi đọc code, nhưng **23 ngôn ngữ chưa dùng lần nào** ⇒ không có tiền lệ trong chính dự án | test bằng mắt | 10 phút |
| 9 | **Regex filter có normalize NFC không** | chưa đọc `UtilsRegex` và đường lọc sự kiện | đọc code + 1 test với tên NFD | ~20 phút |
| 10 | **macOS có tự chọn `vi` khi hệ thống đặt tiếng Việt** | chứng minh được `preferredLocalizations` trả `[vi]`, nhưng đó là **gọi API thủ công**, chưa chạy app thật trên máy đặt ngôn ngữ Việt | đổi ngôn ngữ hệ thống + chạy | 5 phút |
| 11 | **Ước 10–12 giờ người** | suy từ số chuỗi và độ khó, **không** từ lần dịch nào đã bấm giờ | bấm giờ nhóm đầu rồi ngoại suy | — |
| 12 | **Mức nghiêm trọng của `uniqueMetadataValues`** | chưa dựng được va chạm thật từ tên lịch/tài khoản của Duy | xem tên thật | 2 phút |
| 13 | **Con số ~14/1/16 ở §3.1** | đếm `grep -n` + đối chiếu tay với `LEGAL-REVIEW`; **chưa mở từng call-site** để xác nhận cả 16 chuỗi patron chết theo khi gỡ UI | đọc `GeneralTab.swift` + `PatronageService.swift` | ~20 phút |
| 14 | **`preferences_general_meeting_bar_description` có đúng là hộp About không** | suy từ tên khoá và nội dung, **chưa** đọc nơi nó render. Nếu không phải bề mặt mô tả nguồn gốc thì miễn trừ §6 không áp dụng và rổ "GIỮ TÊN" rỗng | đọc `GeneralTab.swift` | 5 phút |

**Phương pháp của toàn bộ file này:** đọc tĩnh trên nhánh `feat/presence-gate`, `grep`, đọc `.loctable` của macOS, một lần `xcodebuild` thật (có gỡ thư mục thăm dò sau khi đo, `git status` đã sạch trở lại), và các script Swift độc lập đo font/chiều rộng/chiều cao — **không chạy app, không chụp màn hình nào.** Theo `docs/lessons.md`, *"không tìm thấy" ở đây luôn nghĩa là "phương pháp này không tìm thấy"*. **Same vendor, same priors — no external verifier ran.**