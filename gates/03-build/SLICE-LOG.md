---
stage: 03-build
date: 2026-10-13
status: in-progress
---

# SLICE-LOG — chỉ thêm, không sửa

## Lát 1 — Tầng 1, cổng presence bằng lịch sử trình duyệt ✅

**Ngày:** 2026-10-13 · **Trạng thái:** code xong, build xanh, hành vi đã kiểm trên dữ liệu thật

### File thêm mới

| File | Việc |
|---|---|
| `MeetingBar/Presence/RoomIdentity.swift` | rút danh tính phòng từ URL. Regex **CHẶT** có chủ đích |
| `MeetingBar/Presence/BrowserHistoryStore.swift` | đọc lịch sử Chromium. Chép DB ra tmp rồi đọc read-only; mọi lỗi → mảng rỗng |
| `MeetingBar/Presence/PresenceGate.swift` | logic **ba giá trị** `present`/`absent`/`unknown` + quy tắc hợp nhất |

### File đã sửa (Apache-2.0 §4(b) — notice đã ghi ở đầu file)

| File | Sửa gì |
|---|---|
| `MeetingBar/Notifications/NotificationActionRunner.swift` | chèn cổng vào `fireAction`, chỉ cho `.autoJoin` |
| `MeetingBar/Extensions/DefaultsKeys.swift` | thêm `presenceGateWindowSeconds` = 900 |

### Điểm chèn — S0 chỉ SAI, T3 bắt được

```
fireDueActions:37 ──► shouldConsiderActionEvent:42 ──► fireAction      (polling)
fire(plan:):65 ─────────────────────────────────────► fireAction      (HẸN GIỜ — bỏ qua cổng)
                                                         ▲
NotificationScheduler.swift:212 ────────────────────────┘   ca thường gặp nhất
```

S0 chỉ định chèn ở `shouldConsiderActionEvent:162`. **Đường hẹn giờ không gọi hàm đó**, nên
cổng sẽ bị đi vòng đúng lúc cần nhất. Điểm đúng là `fireAction` — phễu duy nhất cả hai đổ về.

Và khi im lặng thì **vẫn ghi `processed`**: return sớm mà không ghi làm `evaluate` chạy lại với
cùng `lastModifiedDate` ở mỗi tick, biến cổng thành vòng lặp đánh giá vô tận.

### Đã kiểm — NHÌN THẤY SỐ, không suy từ đọc code

```
xcodebuild -scheme MeetingBar -destination platform=macOS      ** BUILD SUCCEEDED **

parser                     10/10 ĐẠT
  khớp đúng   abc-defg-hij · abc-defg-hij?authuser=0 · zoom /j/81234567890
  từ chối ĐÚNG /home · /new · /accounts/SetOSID · /_meet/abc-defg-hij
               calendar.google.com "Join with Google Meet" · zoom /j/1234 · teams

đọc lịch sử thật           96 lượt / 30 ngày   (Vivaldi 90 · Brave 6)
                           ← KHỚP CHÍNH XÁC con số 96 mà backtest Python đo độc lập.
                             Hai cài đặt khác nhau, cùng một số.

hành vi cổng               W=60s   → mở  ✓      W=900s → mở  ✓
                           W=40 ngày → IM  ✓     phòng không tồn tại → mở ✓
                           /home (bẫy) → mở ✓
```

### Chưa làm ở lát này

- Nhật ký cục bộ ghi **hash** mã phòng (bất đồng [2], PM đã chốt theo Legal) — **Lát 2**
- Gỡ patronage / mailto / chuỗi "MeetingBar" (Legal CHẶN §2.2) — **Lát 3**
- Gỡ `com.apple.security.app-sandbox` khỏi entitlements. **Build hiện tại VẪN SANDBOX**, nên
  cổng sẽ không đọc được lịch sử khi chạy thật trong app — **Lát 2, cổng chặn**
- Tầng 2 — chờ phép đo cuộc Zoom **đặt lịch** (`../01-spec/ZOOM-AX-DUMP.md`)

---

## Lát 2 — gỡ sandbox + nhật ký cục bộ ✅

**Ngày:** 2026-10-13 · **Trạng thái:** build xanh, **đã chạy app thật và nhìn thấy số**

### Gỡ sandbox — cổng chặn của lát này

`MeetingBar/MeetingBar.entitlements`: xoá `com.apple.security.app-sandbox` và
`com.apple.security.files.user-selected.read-write` (cái sau chỉ có nghĩa trong sandbox).
Còn lại ba key: `usernotifications.time-sensitive`, `network.client`,
`personal-information.calendars`.

**Xác minh trên SẢN PHẨM ĐÃ XÂY, không trên file nguồn:**
`codesign -d --entitlements - MeetingBar.app` ⇒ **0 lần xuất hiện `app-sandbox`**.

### Nhật ký cục bộ — `~/Library/Logs/presence-gate.log`

`MeetingBar/Presence/PresenceLog.swift`. Không mạng, không analytics. Mã phòng ghi dưới dạng
`sha256(key)[0:8]` theo quyết định của Legal ở bất đồng [2].

**Và một thứ không ai yêu cầu nhưng là tuyến phòng thủ quan trọng nhất: `selfCheck()` lúc khởi
động.** Chế độ hỏng tệ nhất của cả tính năng là cổng **không đọc được gì** (sandbox bật lại,
macOS siết TCC, người dùng đổi trình duyệt) nên **luôn** kết luận "chưa vào" và không bao giờ
im — hỏng mà không ai biết, vì *"không im"* trông y hệt *"chưa tới lúc im"*.

### Đã kiểm — chạy APP THẬT, không phải test harness

```
$ MeetingBar.app/Contents/MacOS/MeetingBar      (build không sandbox)

2026-10-13 21:32:12  selfcheck  26 lượt/7 ngày  ·  Brave/Default=6 Vivaldi/Default=20
2026-10-13 21:35:37  selfcheck  27 lượt/7 ngày  ·  Brave/Default=6 Vivaldi/Default=21
                                 ▲
       lần hai chạy sau khi gieo một lượt test — con số nhúc nhích đúng 1.
       Không phải "code chạy được", mà là "nó đang NHÌN THẤY thế giới thật".
```

---

## Lát 3 — gỡ thứ Legal CHẶN §2.2 ✅ (một phần)

| Việc | Trạng thái |
|---|---|
| `patronageService.start()` — nút ủng hộ tiền trỏ vào sản phẩm App Store của Andrii Leitsius | **TẮT.** Comment chứ không xoá, để merge upstream còn thấy |
| `Constants.emailMe` → `mailto:leits.dev@gmail.com` — đồng nghiệp gặp lỗi gửi mail cho người lạ | **ĐỔI** sang issue tracker của fork |
| Chuỗi hiển thị chứa `"MeetingBar"` (vi phạm Apache-2.0 §6) | **CHƯA — chặn trên quyết định của Duy** |

**Vì sao phần §6 chưa xong:** chuỗi thương hiệu nằm rải trong `Localizable.strings` của **mọi
ngôn ngữ** (de, he, ja, nl, zh-Hans, …). Đổi chúng cần **một cái tên**, mà tên là quyết định gu
của Duy (Quy tắc 6). Ứng viên đã có ở `../01-spec/WRITER-NOTES.md`.

Không chặn code. **Chặn việc đưa file cho đồng nghiệp.**

---

## Lát 4 — unit test cho module Presence ✅

`MeetingBarTests/PresenceGateTests.swift` — **8/8 xanh.**

```
RoomIdentityTests
  ✓ testMeetRoomCodesAreRecognised        abc-defg-hij · ?authuser=0 · #fragment
  ✓ testTrapsFromRealHistoryAreRejected   /home · /new · /reauth · /accounts/SetOSID
                                          · /_meet/ · popup "Join with Google Meet"
  ✓ testZoomConferenceNumbers             /j/81234567890 ✓ · /j/1234 ✗ · /my/duypham ✗
  ✓ testOtherServicesAreNotClaimed

PresenceGateMergeTests
  ✓ testSilenceNeedsAtLeastOnePresentAndNoAbsent
  ✓ testDisagreementFailsOpen             present + absent ⇒ MỞ, cả hai thứ tự
  ✓ testNoEvidenceOpens                   rỗng · toàn unknown · absent một mình
  ✓ testUnparseableLinkOpens              /home ⇒ MỞ, không im "cho chắc"
```

**`testTrapsFromRealHistoryAreRejected` là test đáng giá nhất ở đây.** Mỗi dòng trong nó là
một false positive **đã quan sát được trong lịch sử thật của Duy**, không phải một ca giả
định. `meet.google.com/home` xuất hiện nhiều lần mỗi ngày; một lần khớp nhầm nó là cổng im
cho **mọi** cuộc Meet trong ngày hôm đó. Test này tồn tại để giữ regex chặt khi có người
tương lai thấy nó "khó đọc" và muốn nới ra.

---

## Lát 5 — xác minh DÂY NỐI, và một bài test thất bại đáng ghi lại ✅

### Thử E2E bằng cuộc họp thật — THẤT BẠI, vì lý do môi trường

Kế hoạch: gieo một mã phòng vào lịch sử Vivaldi, tạo sự kiện lịch có đúng link đó, để
auto-join bắn, xem nhật ký có `IM` không.

Đã làm: gieo `qaz-wsxe-dcv` lúc 21:34:02 ✓ · tạo sự kiện 21:45 ✓ · tắt MeetingBar của Duy ✓ ·
chạy build test ✓ · chờ qua giờ bắn 21:42 ✓.

**Kết quả: nhật ký chỉ có `selfcheck`, không có dòng `autoJoin` nào. Auto-join chưa hề bắn.**

**Nguyên nhân, đã truy ra:** `defaults read leits.MeetingBar eventStoreProvider` trả
`"MacOS Calendar App"` — **MeetingBar đọc lịch qua EventKit, không qua Google Calendar API.**
Một sự kiện tạo bằng Google API phải chờ Lịch macOS đồng bộ xuống, mất hàng chục phút.
Đọc menubar của build test qua AX: tiêu đề **rỗng** ⇒ nó thật sự không thấy sự kiện.
Và `selectedCalendarIDs` chỉ có **một** lịch, nên còn một biến nữa chưa loại trừ.

**Đây không phải lỗi của cổng.** Nhưng nó là một sự thật về môi trường test mà S4 phải biết
trước, nếu không S4 sẽ mất đúng số thời gian tôi vừa mất.

Môi trường đã dọn: sự kiện đã xoá · build test đã tắt · **MeetingBar của Duy đã bật lại**.

### Đổi cách: tiêm cổng, kiểm dây nối bằng 3 mili giây

Cổng từ chỗ dựng-tại-chỗ chuyển thành **thuộc tính tiêm vào** `NotificationActionRunner`.
Không phải vì cần linh hoạt — mà vì dựng tại chỗ thì dây nối **chỉ kiểm được bằng một thứ
không tất định**. Tiêm vào thì kiểm được tất định.

```
PresenceGateWiringTests                                                   3/3 ✓
  ✓ testGateSuppressesAutoJoin            cổng IM ⇒ sink KHÔNG được gọi.
                                          Không có tab thứ hai. Đây là câu hỏi gốc.
  ✓ testGateLetsAutoJoinThroughWhenAbsent cổng MỞ ⇒ y hệt MeetingBar gốc
  ✓ testSuppressionStillRecordsProcessed  hai tick liên tiếp, vẫn im, processed ĐÃ ghi
                                          ⇒ không có vòng lặp đánh giá mỗi tick
```

### Toàn bộ suite — không hồi quy

```
Executed 313 tests, with 0 failures (0 unexpected) in 26.693 seconds
```

`NotificationActionRunner` là file tôi sửa, và nó có hơn 800 dòng test của upstream. 313/313
xanh nghĩa là cổng không làm hỏng hành vi nào đang có.

### Còn lại — nói thẳng là CHƯA xác minh

**Dây nối đã chứng minh tất định. Chuỗi đầy-đủ-từ-lịch-thật thì CHƯA.** Khoảng trống chính
xác là: *EventKit giao sự kiện → MeetingBar lập lịch Task → Task gọi `fire(plan:)`*. Đó là
code upstream tôi không sửa, nhưng "không sửa" không phải "đã kiểm".

**Cách đóng khoảng trống này ở S4, đã biết đường:** tạo sự kiện **thẳng trong Lịch macOS**
(đúng lịch `B880C2DB-8566-4D0F-A6DB-5F2AAD8219A5` mà MeetingBar đang theo dõi), không qua
Google API. Hoặc đổi `eventStoreProvider` sang Google trong lúc test.

---

## Lát 6 — E2E ĐẠT, và một lỗi chặn mà S0/S1 đều bỏ sót ✅

**Ngày:** 2026-10-13 đêm · **Trạng thái:** chuỗi đầy đủ đã chạy trong app thật

### Bằng chứng

```
23:00:58   auto-join hẹn giờ bắn (T-180s của sự kiện 23:03:58)
23:01:01   autoJoin  IM  event=8d4b4370  đã vào meet:pge-live-xyz — history:Vivaldi/Default

lượt vào phòng trong lịch sử: CHỈ MỘT (22:57:06, lượt gieo)
                              ⇒ KHÔNG có tab thứ hai
```

Chuỗi đầy đủ, không mô phỏng chỗ nào: **EventKit → NotificationPlanner → Scheduler Task →
`fire(plan:)` → `fireAction` → PresenceGate → im lặng.**

### 🚩 Lỗi chặn tìm ra trên đường: GỠ SANDBOX LÀM MẤT TOÀN BỘ CẤU HÌNH

Ba vòng E2E đầu đều thất bại và **không để lại dấu vết nào** — app chạy, menubar hiện sự kiện,
nhưng auto-join không bao giờ bắn. Chỉ tìm ra khi in giá trị settings **lúc chạy**:

```
app đọc được:   autoJoin enabled=false  offset=5s      ← đúng bằng giá trị fallback
đĩa đang ghi:   automaticEventJoin=true  time=180
```

Nguyên nhân: **hai kho UserDefaults khác nhau.**

| | `~/Library/Preferences/` | `~/Library/Containers/leits.MeetingBar/…` |
|---|---|---|
| ai đọc | bản fork (**không sandbox**) | bản gốc (**có sandbox**) |
| `automaticEventJoin` | **không có** | `true` |
| `eventStoreProvider` | *(trạng thái test)* | `MacOS Calendar App` |

**Quyết định A (gỡ sandbox) đổi chỗ UserDefaults, và không ai đo điều đó ở S0 hay S1.**
Hậu quả với người dùng thật: cài bản fork lên là thấy một app trắng tinh — onboarding chạy
lại, lịch đã chọn biến mất, bookmark mất, và `automaticEventJoin` rơi về `false`.

**Tức là chính tính năng mà cả dự án này tồn tại để sửa thì không chạy — và không báo gì.**

### Sửa: `MeetingBar/Settings/SandboxContainerMigration.swift`

Chạy **một lần, sớm nhất** trong `applicationDidFinishLaunching`, trước mọi phép đọc settings.
Đọc plist trong container, mang sang những khoá kho mới **chưa có** (không bao giờ ghi đè —
nếu người dùng đã chỉnh trong bản fork thì lựa chọn mới thắng).

Đo thật: **`migrate mang 38/40 khoá từ container sandbox sang`**, và ngay sau đó
`autoJoin enabled=true offset=180s`.

### Đèn chẩn đoán — giữ lại, không gỡ

Thêm hai dòng log vào đường đi (`plan …` ở Scheduler, `fire …` ở `fireAction`). Chúng là lý
do duy nhất tìm ra lỗi trên, và chế độ hỏng của tính năng này **im lặng theo cả hai nghĩa**:
nó hỏng mà không kêu, và *"không im"* trông y hệt *"chưa tới lúc im"*.

### Một chi tiết về thời điểm, S4 phải biết

`NotificationPlanner.appendIfDue` chỉ lập kế hoạch khi `fireDate > now`. Sự kiện tạo ra mà
giờ bắn **đã qua** thì không có Task nào — nó rơi sang đường quét bù `fireDueActions`, vốn
chỉ chạy ở một số thời điểm. Ba vòng test đầu của tôi thất bại một phần vì lý do này. Muốn
test đường hẹn giờ thì **app phải đang chạy TRƯỚC khi sự kiện được tạo**.
