---
stage: 01-spec
owner: PM (gộp bốn phòng)
freshness: 2026-10-13
status: draft — CHƯA được Duy duyệt
reviewer: same vendor, same priors — no external verifier ran
---

# ACCEPTANCE — presence-gate

> **Đây là tài liệu THAM CHIẾU.** Duy không cần đọc hết. Mở ra lúc nghiệm thu từng lát.
> Mỗi dòng: **một tiêu chí · một cách kiểm cụ thể · kiểm bằng MÁY hay bằng MẮT**.
> Không dòng nào được viết "hoạt động đúng".

**Luật đọc bảng:**

```
   MÁY   chạy được lệnh, so với một giá trị. Không ai diễn giải.
   MẮT   phải NHÌN THẤY. "Xong" nghĩa là đã nhìn thấy số/màn hình —
         không bao giờ suy ra từ việc đọc code (Quy tắc 8).
```

**Một tiêu chí không đạt ⇒ lát đó chưa xong.** Không có "đạt một phần".

---

## §0 — Lát 0 · Gỡ sandbox, đo lại TCC sạch, chốt tên

| # | Tiêu chí | Cách kiểm | Loại |
|---|---|---|---|
| 0.1 | Entitlement sandbox đã gỡ | `grep -c 'app-sandbox' MeetingBar/MeetingBar.entitlements` ⇒ **0** | MÁY |
| 0.2 | Build ra `.app` chạy được sau khi gỡ | `xcodebuild -scheme <tên> build` ⇒ exit 0; mở app từ Finder, icon menu bar xuất hiện | MÁY + MẮT |
| 0.3 | **Phép đo TCC trên tiến trình SẠCH** (Legal CL-1) | `.app` chưa ký, chạy **từ Finder** (KHÔNG từ terminal — terminal kế thừa FDA của `node`/iTerm). App thử mở `~/Library/Application Support/Vivaldi/Default/History` và ghi kết quả ra một file | MẮT |
| 0.4 | Kết quả phép đo được ghi thành artifact | `gates/01-spec/TCC-CLEAN-MEASURE.md` tồn tại, có ngày, nói rõ: **đọc được / không đọc được**, **có dialog / không dialog**, và **kèm ảnh chụp màn hình** (hoặc dòng "không dialog nào hiện") | MẮT |
| 0.5 | **ĐIỀU KIỆN DỪNG** — nếu 0.3 cho "không đọc được" | một dòng CÓ NGÀY trong `PRD.md` ghi DỪNG + đã leo lên Duy. **Lát 1 không được bắt đầu.** `git log --oneline` có commit đó | MẮT |
| 0.6 | Tên sản phẩm đã chốt (Q1) | một dòng CÓ NGÀY trong `PRD.md` ghi tên + bundle id Duy chọn | MẮT |
| 0.7 | Tên mới không chứa chuỗi cấm | `plutil -extract CFBundleDisplayName raw <App>.app/Contents/Info.plist \| grep -ci meetingbar` ⇒ **0** | MÁY |
| 0.8 | Bundle id không mang namespace người khác | `plutil -extract CFBundleIdentifier raw <App>.app/Contents/Info.plist \| grep -ci '^leits' ` ⇒ **0** | MÁY |
| 0.9 | URL scheme đã đổi (tránh đụng nếu máy đã cài MeetingBar thật) | `plutil -p <App>.app/Contents/Info.plist \| grep -i 'meetingbar'` trong khối `CFBundleURLSchemes` ⇒ không có | MÁY |
| 0.10 | Tên có dấu không làm vỡ zip (NFC/NFD) | `PRODUCT_NAME`, tên file `.app`, bundle id là **ASCII thuần**; dấu chỉ ở `CFBundleDisplayName`. `ls <App>.app \| LC_ALL=C grep -c '[^ -~]'` ⇒ **0** | MÁY |

## §1 — Lát 1 · Cổng GIẢ + thoát hiểm + nghĩa vụ Apache

| # | Tiêu chí | Cách kiểm | Loại |
|---|---|---|---|
| 1.1 | **Cổng được hỏi trên CẢ HAI đường bắn** (đây là rủi ro lớn nhất của lát này) | unit test gọi `fireDueActions(...)` và `fire(plan:...)` riêng rẽ; cả hai lần assert bộ đếm `gateConsulted` tăng đúng 1 | MÁY |
| 1.2 | Cổng nằm TRƯỚC `EventActionPolicy.evaluate` | `grep -n 'presenceGate\|EventActionPolicy.evaluate' MeetingBar/Notifications/NotificationActionRunner.swift` ⇒ số dòng của cổng **nhỏ hơn** số dòng của `evaluate` | MÁY |
| 1.3 | Stub `.present` ⇒ không mở tab | tạo event Meet cách 4 phút; tới giờ bắn: **không tab nào mở**, không notification nào hiện | MẮT |
| 1.4 | Stub `.unknown` ⇒ mở tab như bản gốc | lật stub, lặp lại 1.3: **tab mở** | MẮT |
| 1.5 | **Không vòng lặp retry** | để stub chặn liên tục 5 phút trên một event; đếm dòng nhật ký cho event đó ⇒ **≤ 3** (một dòng cho mỗi chuyển trạng thái, không phải mỗi tick) | MẮT |
| 1.6 | Chặn KHÔNG biến thành chặn vĩnh viễn | trong lúc stub đang chặn, lật sang `.unknown` giữa cửa sổ bắn ⇒ **tab mở ngay tick sau** | MẮT |
| 1.7 | Công tắc thoát hiểm ở vị trí cố định | mục **đầu tiên** menu xổ xuống là `⏸ Tắt cổng im lặng (1 giờ)`. Bấm icon → bấm mục, bấm đồng hồ: **≤ 3 giây** | MẮT |
| 1.8 | Công tắc có tác dụng thật | sau khi bấm, lặp lại 1.3 với stub `.present` ⇒ **tab mở** | MẮT |
| 1.9 | **Thất bại là MỞ** — không nhánh nào im vì lỗi | `grep -n 'catch\|try?' <file cổng>` — mọi nhánh catch dẫn tới `.unknown`; thêm một unit test ném lỗi giả ⇒ verdict `.unknown`, tab mở | MÁY |
| 1.10 | `LICENSE` nằm TRONG bundle (§4(a)) | `ls <App>.app/Contents/Resources/LICENSE` ⇒ tồn tại | MÁY |
| 1.11 | Mọi file đã sửa mang header §4(b) | script: `git diff master --name-only -- '*.swift'` và với mỗi file, `head -14 <file> \| grep -c 'was modified on'` ⇒ **1**. Tập hợp hai bên **khớp hoàn toàn** | MÁY |
| 1.12 | Mỗi header có dòng `Change:` nói đúng cái đã sửa | đọc từng header; **không chấp nhận** "various improvements" hay dòng trống | MẮT |
| 1.13 | §4(c) — copyright gốc còn nguyên | `plutil -extract NSHumanReadableCopyright raw <App>.app/Contents/Info.plist \| grep -c 'Andrii Leitsius'` ⇒ **1** | MÁY |
| 1.14 | §4(c) — 44 header copyright không bị xoá | `grep -rlc 'Copyright © .* Andrii Leitsius' MeetingBar --include='*.swift' \| wc -l` ⇒ **≥ 44** | MÁY |
| 1.15 | `CHANGES-FROM-UPSTREAM.md` tồn tại và khớp diff | `git diff master --name-only` ⊆ danh sách trong file | MÁY |
| 1.16 | Không gửi gì ra mạng — số chỗ gọi `URLSession` không đổi | `grep -rl 'URLSession' MeetingBar --include='*.swift' \| wc -l` ⇒ **2** (bằng baseline, cả hai là Calendar sync) | MÁY |
| 1.17 | Không thêm dependency bên thứ ba | `git diff master -- Package.swift Package.resolved` ⇒ **rỗng** | MÁY |
| 1.18 | Nhật ký tồn tại và đọc được | file nhật ký có ≥1 dòng sau khi chạy 1.3. **File không tồn tại ⇒ instrumentation hỏng, KHÔNG phải "không có gì xảy ra"** | MẮT |
| 1.19 | Nhật ký ghi cả `pass`, không chỉ `silence` | sau 1.4, nhật ký có dòng `decision=pass` ⇒ phân biệt được "cổng chạy và để qua" với "cổng không chạy" | MẮT |
| 1.20 | Nhật ký ghi **thời gian probe**, không chỉ verdict | mỗi dòng có trường `probe_ms` là số | MẮT |

## §2 — Lát 2 · `BrowserHistoryProbe` thật (chỉ Vivaldi)

| # | Tiêu chí | Cách kiểm | Loại |
|---|---|---|---|
| 2.1 | Vào phòng tay ⇒ cổng im | mở một phòng Meet, đợi 1 phút, tạo event cùng mã phòng cách 4 phút ⇒ **không tab nào mở** | MẮT |
| 2.2 | Phòng chưa từng vào ⇒ tab mở | event với một mã phòng bịa chưa có trong lịch sử ⇒ **tab mở** | MẮT |
| 2.3 | Bằng chứng trong nhật ký khớp DB thật | lấy `evidence_ts` từ nhật ký; chạy tay `SELECT v.visit_time FROM visits v JOIN urls u ON u.id=v.url WHERE u.url LIKE '%<mã>%' ORDER BY v.visit_time DESC LIMIT 1` ⇒ lệch **≤ 1 giây** | MÁY + MẮT |
| 2.4 | **JOIN `visits`, không dùng `urls.last_visit_time`** | fixture DB: một phòng có **3** lượt vào hôm nay ⇒ truy vấn của probe trả **3** dòng (không phải 1). Và `grep -c 'last_visit_time' <probe>` ⇒ **0** | MÁY |
| 2.5 | **Redirect KHÔNG tính là có mặt** | fixture: chèn `https://meet.google.com/accounts/SetOSID?authuser=0&continue=...abc-defg-hij...` ⇒ verdict `.unknown` cho phòng `abc-defg-hij` | MÁY |
| 2.6 | `/home`, `/new`, `/reauth` không tính là phòng | fixture với ba URL đó ⇒ verdict `.unknown` | MÁY |
| 2.7 | **Phòng định kỳ: lượt vào tuần trước KHÔNG làm im hôm nay** | fixture: lượt vào cùng mã phòng cách đây 8 ngày, event hôm nay ⇒ verdict `.unknown`, tab mở | MÁY |
| 2.8 | **Probe không bao giờ trả `.absent`** | `grep -c '\.absent' <BrowserHistoryProbe>` ⇒ **0** | MÁY |
| 2.9 | P-1 — không `SELECT *`, không `urls.title` | `grep -cE 'SELECT \*\|urls\.title\|u\.title' <probe>` ⇒ **0** | MÁY |
| 2.10 | P-2 — có `LIMIT 1` | `grep -c 'LIMIT 1' <probe>` ⇒ **≥ 1** | MÁY |
| 2.11 | P-3 — không copy file History | `grep -cE 'copyItem\|FileManager.*copy\|NSTemporaryDirectory' <probe>` ⇒ **0**; và `grep -c 'immutable=1' <probe>` ⇒ **≥ 1** | MÁY |
| 2.12 | P-4 — không giữ handle sống | `grep -c 'sqlite3_close' <probe>` ⇒ **≥ 1**, và mọi đường thoát đều đi qua nó (đọc bằng mắt) | MÁY + MẮT |
| 2.13 | **P-5 — không mã phòng nào vào `os.Logger`** | `grep -cE 'Logger\|os_log' <probe>` ⇒ **0**. Và `log show --last 1h --predicate 'subsystem CONTAINS "<bundleid>"' \| grep -cE '[a-z]{3}-[a-z]{4}-[a-z]{3}'` ⇒ **0** | MÁY |
| 2.14 | **P-6 — không gì từ lịch sử vào `DiagnosticsReport`** | `grep -cEi 'presence\|history\|roomCode\|visit' MeetingBar/Utilities/Diagnostics/DiagnosticsReport.swift` ⇒ **0** | MÁY |
| 2.15 | P-7 — không quét nền, không định kỳ | `grep -cE 'Timer\|DispatchSourceTimer\|repeats: true' <probe>` ⇒ **0** | MÁY |
| 2.16 | P-8 — không đọc Safari | `grep -ci 'safari' <probe>` ⇒ **0** | MÁY |
| 2.17 | **Đo độ trễ Chromium ghi xuống đĩa** (§A9 #6) | vào một phòng mới, poll DB mỗi giây, đếm tới khi dòng xuất hiện. Ghi số giây vào `gates/01-spec/` | MẮT |
| 2.18 | **Đo thời gian probe thật** (§A9 #5) | sau 2 ngày dùng thường, `max(probe_ms)` trong nhật ký ⇒ ghi con số ra. Vượt 150ms thường xuyên ⇒ **báo cáo, không im lặng chỉnh ngưỡng** | MẮT |
| 2.19 | DB khoá / ghi mạnh ⇒ hỏng về phía an toàn | mở 30 tab trong Vivaldi rồi đánh giá ngay ⇒ verdict `.present` hoặc `.unknown`, **không crash**, và nếu `.unknown` thì **tab mở** | MẮT |
| 2.20 | Thiếu file History ⇒ bỏ qua im lặng, không crash | đổi tên file History tạm thời ⇒ app vẫn chạy, verdict `.unknown`, tab mở | MẮT |
| 2.21 | **`unreadable` ≠ `notFound`** (Legal CL-2) | hai fixture: (a) file không đọc được, (b) file đọc được nhưng không có lượt nào ⇒ hai `UnknownReason` **khác nhau** trong nhật ký | MÁY |
| 2.22 | Nhánh `unreadable` **nhìn thấy được**, đúng một lần | dựng ca (a); người dùng thấy một dấu hiệu trong menu bar. Lặp lại lần hai ⇒ **không báo lại** | MẮT |
| 2.23 | Mục `Mở ngay` hoạt động | sau khi cổng vừa bỏ qua, menu hiện `⏸ Vừa bỏ qua: <tên cuộc> — Mở ngay`; bấm ⇒ link mở. Tổng **2 cú bấm** | MẮT |
| 2.24 | W đọc từ Defaults, không hard-code | `defaults write <bundleid> presenceGateWindowSeconds -int 60`, khởi động lại, kiểm nhật ký `window_s=60` | MÁY |

## §3 — Lát 3 · Chrome + Brave

| # | Tiêu chí | Cách kiểm | Loại |
|---|---|---|---|
| 3.1 | Mở phòng trong **Brave** ⇒ cổng im | lặp lại 2.1 nhưng mở phòng bằng Brave | MẮT |
| 3.2 | Mở phòng trong **Chrome** ⇒ cổng im | lặp lại 2.1 bằng Chrome | MẮT |
| 3.3 | Quét profile động, không hard-code | tạo `Google/Chrome/Profile 3/History` từ fixture ⇒ probe đọc nó **không cần sửa code**; nhật ký ghi `browser` trỏ đúng profile | MÁY |
| 3.4 | Thư mục trình duyệt không tồn tại ⇒ bỏ qua im lặng | đổi tên thư mục Brave ⇒ app chạy bình thường, không crash, không dialog | MẮT |
| 3.5 | Ngân sách vẫn giữ với 5 file | `max(probe_ms)` sau 2 ngày ⇒ ghi ra. So với 2.18 | MẮT |

## §4 — Lát 4 · PHÉP ĐO (không phải code) · chặn Lát 5

| # | Tiêu chí | Cách kiểm | Loại |
|---|---|---|---|
| 4.1 | Có một cuộc Zoom thật đang chạy | Duy tự mở phòng Zoom cá nhân và vào bằng **app native** | MẮT |
| 4.2 | Dump AX được lưu lại | `gates/01-spec/ZOOM-AX-DUMP.md` tồn tại, có ngày | MẮT |
| 4.3 | **Trả lời đúng MỘT câu: tiêu đề cửa sổ lúc đang họp CÓ mang meeting ID không** | file 4.2 ghi tiêu đề **nguyên văn**, và một dòng `CÓ` hoặc `KHÔNG` | MẮT |
| 4.4 | **ĐIỀU KIỆN DỪNG** — nếu 4.3 là `KHÔNG` | một dòng CÓ NGÀY trong `PRD.md`: Nguồn Cửa Sổ không thoả nổi Quyết định B, đã leo lên Duy. **Lát 5 không được bắt đầu.** Tuyệt đối **không** tự hạ chuẩn xuống "chỉ hiện diện" | MẮT |
| 4.5 | **ToS về đọc cây AX đã được soi** (`LEGAL-SCREEN` §2, điều kiện còn mở) | `gates/01-spec/` có một file ghi kết quả soi ToS Zoom, có ngày, nói rõ đã đọc bản nào. **"Không tìm thấy" phải ghi là "phương pháp này không tìm thấy"** | MẮT |

## §5 — Lát 5 · `AccessibilityProbe`

| # | Tiêu chí | Cách kiểm | Loại |
|---|---|---|---|
| 5.1 | Cửa sổ microcopy hiện **TRƯỚC** `AXIsProcessTrustedWithOptions` | ảnh chụp theo thứ tự: cửa sổ của app → (bấm) → System Settings. `grep -n 'AXIsProcessTrustedWithOptions' <file>` nằm **sau** lời gọi hiện cửa sổ | MẮT + MÁY |
| 5.2 | Chuỗi microcopy **không chứa con số 97%** hay bất kỳ số nào đo từ lịch của riêng Duy | `grep -cE '97%\|71/73\|[0-9]+%' <file chuỗi>` ⇒ **0** | MÁY |
| 5.3 | Nút "Để sau" tồn tại và có tác dụng | bấm "Để sau" ⇒ app chạy tiếp, Nguồn Trình Duyệt hoạt động, **không dialog nào nữa** | MẮT |
| 5.4 | Xin quyền đúng **một lần** | khởi động lại app ⇒ **không hỏi lại** | MẮT |
| 5.5 | Trong cuộc Zoom ⇒ cổng im | vào cuộc Zoom thật, tạo event cùng meeting ID cách 4 phút ⇒ **không tab nào mở** | MẮT |
| 5.6 | **Zoom chỉ biết "đang trong MỘT cuộc" ⇒ cổng KHÔNG im** | vào cuộc Zoom A, tạo event cho cuộc Zoom **B** ⇒ **tab MỞ**. Đây là phép thử trực tiếp cho Quyết định B | MẮT |
| 5.7 | Rút quyền ⇒ lùi êm, không dialog | tắt Accessibility trong System Settings ⇒ Nguồn Trình Duyệt vẫn chạy (lặp 2.1 thành công), **không dialog nào hiện** | MẮT |
| 5.8 | `window_probe` có trong nhật ký, có trần | sau 2 ngày: nhật ký có dòng `presence_gate.window_probe`, và **≤ 1 dòng mỗi sự kiện mỗi lần bắn** | MẮT |
| 5.9 | Teams và Webex **ghi nhãn là chưa kiểm**, không giả vờ | `PRD.md` §A9 #8 còn nguyên; không dòng nào trong code hay doc tuyên bố đã kiểm hai dịch vụ này | MẮT |
| 5.10 | Không có dấu vết chép screenpipe | `probe/AXBrowser.swift:24` comment đã sửa để trỏ vào **phép đo đã thực hiện** ở 4.2, không trỏ vào screenpipe | MÁY |

## §6 — Lát 6 · Hai nguồn độc lập thật

| # | Tiêu chí | Cách kiểm | Loại |
|---|---|---|---|
| 6.1 | Xoá `AccessibilityProbe.swift` khỏi target ⇒ build xanh | `xcodebuild build` ⇒ exit 0 | MÁY |
| 6.2 | Nguồn Trình Duyệt chạy **không đổi một dòng nào** | `git diff` sau khi xoá ⇒ chỉ đụng target membership, **không đụng** `BrowserHistoryProbe.swift` hay `PresenceGate.swift` | MÁY |
| 6.3 | Toàn bộ §2 vẫn đạt | chạy lại 2.1, 2.2, 2.3 | MẮT |
| 6.4 | Khôi phục xong, build lại xanh | `xcodebuild build` ⇒ exit 0 | MÁY |

## §G — CỔNG PHÁT FILE · Legal CL-4/5/6 · **không .app nào rời máy Duy trước cổng này**

| # | Tiêu chí | Cách kiểm | Loại |
|---|---|---|---|
| G.1 | **CL-4 — patronage đã GỠ HẲN** | `grep -rc 'PatronageService\|patronage' MeetingBar --include='*.swift' \| grep -v ':0'` ⇒ **rỗng**. Và file `PatronageService.swift` không còn trong target | MÁY |
| G.2 | **CL-4 — mailto của tác giả gốc đã GỠ** | `grep -rc 'leits.dev@gmail.com' MeetingBar` ⇒ **0** | MÁY |
| G.3 | Chuỗi quảng bá tên cũ đã gỡ | `grep -rc 'supported MeetingBar' MeetingBar/*.lproj` ⇒ **0** | MÁY |
| G.4 | **CL-5 — toàn bộ bảng đổi tên đã làm**, trừ mục phải GIỮ | chạy lại 0.7 · 0.8 · 0.9 · 1.10 · 1.11 · 1.13 · 1.14 | MÁY |
| G.5 | Không chuỗi hiển thị nào còn tên cũ | `grep -rc 'MeetingBar' MeetingBar/en.lproj/Localizable.strings` ⇒ **0** | MÁY |
| G.6 | **App chưa ký có MỞ ĐƯỢC trên máy khác không** (§A9 #1 — chưa ai đo) | copy `.app` sang một máy Mac khác, mở từ Finder. **Ghi lại nguyên văn Gatekeeper nói gì** và cần bao nhiêu bước để mở được | MẮT |
| G.7 | **CL-6 — câu thông báo đã gửi TRƯỚC khi đưa file** | ảnh chụp tin nhắn, có dấu thời gian **trước** lúc gửi file | MẮT |
| G.8 | Câu thông báo có đủ ba thứ bắt buộc | đọc: (1) nó đọc file gì · (2) nó **có khả năng** đọc hết · (3) tắt được | MẮT |
| G.9 | **Duy duyệt RIÊNG, ghi thành chữ, có ngày** | một dòng trong `gates/` ghi Duy đồng ý phát file cho từng người, có ngày. **Review ≠ approve** — không báo cáo review nào thay được dòng này | MẮT |

## §D — CỔNG DỮ LIỆU · phòng Data chặn S4 nếu không đạt

| # | Tiêu chí | Cách kiểm | Loại |
|---|---|---|---|
| D.1 | **G1 — mọi sự kiện bị im trong replay đã được Duy DÁN NHÃN TAY**, số lần im-nhầm = **0** | hôm nay chỉ có 1 sự kiện: `09-14 16:30 · iat-dpyb-uvb · "Product Team Daily Checkpoint"`. Duy trả lời: hôm đó anh có thật sự ở trong cuộc lúc 16:27 không? Ghi câu trả lời CÓ NGÀY vào `gates/01-spec/`. **Chưa dán nhãn ⇒ mẫu là 0/0, G1 là CHƯA ĐO, không phải ĐẠT** | MẮT |
| D.2 | G2 — W đã chốt và nằm dưới trần | W ≤ 360 phút (¼ của khoảng tái dùng mã phòng nhỏ nhất = 1440 phút). Ghi W Duy chọn + **lý do** vào `PRD.md`, có ngày — *sáu tuần sau không ai dựng lại được là do tính toán hay do thuận tay* | MẮT |
| D.3 | **G3 — 14 ngày dùng thật, số lần im-nhầm = 0** | mở nhật ký, đếm: với mỗi dòng `presence_gate.missed` của Duy, có dòng `decision=silence` nào cho cùng sự kiện không? ⇒ **0** | MẮT |
| D.4 | File nhật ký thật sự tồn tại sau 2 ngày | **≥ 4 dòng.** File không tồn tại ⇒ **instrumentation hỏng**, không phải "không có gì xảy ra" | MẮT |
| D.5 | Dựng được kịch bản im lặng bằng tay | mở link phòng 6 phút trước giờ họp, để tab đó, chờ ⇒ nhật ký có **≥1 dòng** `decision=silence` với `evidence_age_s` nằm trong `[180, W]` | MẮT |
| D.6 | `ONE-PAGER.md` §4 đã được Duy gỡ mâu thuẫn | §4 hiện ghi *"không có instrumentation và cố ý không có"*. Phải có một dòng **MỚI, CÓ NGÀY, thêm bên dưới** (không sửa tại chỗ) — Quy tắc 14. **Duy sở hữu file này** | MẮT |
| D.7 | `ONE-PAGER.md` không cũ hơn `PRD.md` | `../../../scripts/vibe-check.sh` mục freshness ⇒ xanh. **Cũ hơn là lỗi CHẶN, không phải cảnh báo** | MÁY |
| D.8 | `../../../scripts/vibe-check.sh` xanh toàn bộ | chạy script ⇒ exit 0 | MÁY |

## §Q — CỔNG QUYẾT ĐỊNH · S2 không mở được nếu thiếu

| # | Tiêu chí | Cách kiểm | Loại |
|---|---|---|---|
| Q.1 | **Cả 6 câu ở `DECISIONS-PENDING` đã có trả lời của Duy**, mỗi câu một dòng CÓ NGÀY trong `gates/01-spec/` | đọc. Một quyết định chỉ sống trong chat là một quyết định **sẽ bị làm lại** (Quy tắc 14) | MẮT |
| Q.2 | **Ba bất đồng B-1, B-2, B-3 đã được Duy gỡ**, không phải bị ép đồng thuận | mỗi bất đồng có một dòng quyết định CÓ NGÀY. **Không được có dòng nào ghi "hai phòng đã thống nhất"** nếu Duy chưa trả lời | MẮT |
| Q.3 | Con số **1–3 cuộc/30 ngày** đã được đặt trước Duy và có trả lời | một dòng CÓ NGÀY. Đây là điều kiện chặn S2 của phòng Data | MẮT |
| Q.4 | `UNDERSTOOD.md` của S2 tồn tại trước khi S2 bắt đầu | trích dẫn nguyên văn từ `ONE-PAGER` **khớp**; phần kể lại **không khớp**. `../../../scripts/vibe-check.sh` mục `[2]` và `[3]` | MÁY |

---

## Chưa xác minh được — về chính bộ tiêu chí này

| # | |
|---|---|
| 1 | **Ngưỡng 150ms ở 2.18 là ĐỀ XUẤT, chưa đo.** Nó có thể sai hẳn — nhất là vì lead time **mặc định** là 5 giây (cửa sổ 20 giây), không phải 180 giây như máy Duy. Nếu probe thường xuyên vượt, cổng luôn trả `unknown` và tính năng **chết âm thầm**. Vì vậy 2.18 bắt buộc **ghi con số ra**, không phải đánh dấu đạt/không đạt |
| 2 | **D.1 chỉ có n=1.** 0 lỗi trên 1 mẫu không chứng minh gì — rule-of-three cho cận trên 95% là ~3/n = 300%. Cái bảo vệ Duy khỏi im-nhầm là **cơ học** (W hẹp + nhật ký + bốn lớp thoát hiểm), không phải thống kê. Đừng đọc D.1 ĐẠT là "an toàn" |
| 3 | **D.3 chỉ xác minh được trên máy Duy.** Nhật ký của đồng nghiệp nằm trên máy họ và **cố ý không gom lại được**. Với ≤4 người còn lại, G3 là một khoảng trống đã biết, không phải một cổng đã đạt |
| 4 | **G.6 chưa ai đo.** Không phòng nào nêu việc một app chưa ký, không sandbox, đưa tay qua zip sẽ gặp Gatekeeper thế nào. Nó có thể chặn toàn bộ Quyết định A và tiêu chí này là lần đầu nó được nhìn tới |
| 5 | **2.19 (ghi mạnh) và 2.17 (độ trễ ghi đĩa) là hai phép đo CHƯA AI LÀM**, không phải hai phép kiểm lại. Nếu một trong hai ra kết quả xấu, nó đổi §B4 chứ không chỉ đổi một ô đạt/không đạt |
| 6 | **5.6 là phép thử trực tiếp cho Quyết định B và nó có thể không chạy được**, vì nó cần **hai** cuộc Zoom khác nhau mà Duy có 0 cuộc Zoom/30 ngày. Nếu không dựng được, ghi là **chưa kiểm**, đừng bỏ dòng này đi |
| 7 | Toàn bộ tiêu chí ở §5 giả định Lát 4 cho đèn xanh. Nếu 4.3 ra `KHÔNG` thì **cả §5 trở thành vô nghĩa**, không phải "tạm hoãn" |

---

*Bộ tiêu chí này do PM soạn khi gộp bốn báo cáo phòng ban. Chưa qua reviewer.*
**Same vendor, same priors — no external verifier ran.**
**Review ≠ approve.** Đạt hết tiêu chí không có nghĩa là được phát file — G.9 là một chữ ký riêng của Duy, và không báo cáo nào thay được nó.
