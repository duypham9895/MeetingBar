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
