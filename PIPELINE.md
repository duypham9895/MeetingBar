---
slug: presence-gate
pointer: 00-discovery
created: 2026-10-13
upstream: leits/MeetingBar @ fdd799b (master, 2026-10-13)
---

# PIPELINE — presence-gate

Fork của MeetingBar (Apache-2.0). Thêm **một** hệ thống con: biết người dùng đã ở trong
cuộc họp sắp tới chưa, và im lặng nếu đã ở trong đó.

**Đây là trạng thái DUY NHẤT của app này.**

| # | Stage | Trạng thái | Artifact | Duyệt ngày |
|---|---|---|---|---|
| S0 | Discovery | pass (chờ /vibe:approve) | `gates/00-discovery/PRODUCT-BRIEF.md` · `LEGAL-SCREEN.md` | |
| S1 | PRD | in-progress | `gates/01-spec/PRD.md` · `ACCEPTANCE.md` · `SUCCESS-CRITERIA.md` · `TRACKING-PLAN.md` · `LEGAL-REVIEW.md` | |
| S2 | Design | in-progress (mở lại) | `gates/02-design/` | |
| S3 | Build | pending | `gates/03-build/SLICE-LOG.md` + commit `feat:` + `licences.json` | |
| S4 | QA | pending | `gates/04-qa/VERIFICATION.md` · `REVIEW.md` · `EVENT-VERIFICATION.md` | |
| S5 | Launch | pending | `gates/05-launch/LAUNCH-READINESS.md` · `POSITIONING.md` · đường gỡ | |
| S6 | Iterate | pending | `gates/06-iterate/TRIAGE.md` · `READOUT.md` | |

Bảng định tuyến: `../docs/stages.md`.

## Log — chỉ thêm, không bao giờ sửa hay xoá

| Ngày | Sự kiện | Lý do |
|---|---|---|
| 2026-10-13 | Fork `leits/MeetingBar` → `duypham9895/MeetingBar`, nhánh `feat/presence-gate` từ `master` | Duy chỉ định. Chọn `master` chứ không `v5`: `v5` cũ 4 tháng và tụt 153 commit |
| 2026-10-13 | **Quyết định A** — phân phối: **(b) vài đồng nghiệp, Duy tự đưa file** | Bỏ App Store ⇒ bỏ sandbox ⇒ Accessibility API dùng được. Đây là thứ duy nhất mở khoá Zoom + Teams |
| 2026-10-13 | **Quyết định B** — chính sách false-positive: **detect thấy đang ở trong ĐÚNG cuộc họp sắp nhắc ⇒ im hẳn**, không notify | Duy chỉ định. Lưu ý hệ quả ở PRODUCT-BRIEF §Hệ quả của Quyết định B |
| 2026-10-13 | Gửi PR upstream bị LOẠI khỏi bảng phương án | Maintainer đã đóng issue #664 với lý do "intended behavior" |
| 2026-10-13 | **Quyết định C** — không setup, app tự detect, Duy không chạy lệnh nào | Duy chỉ định. Hệ quả: AppleScript/Automation bị loại (4 trình duyệt = 4 dialog); kiến trúc chốt AX-only. Sàn còn lại: 1 toggle Accessibility, 1 lần |
| 2026-10-13 | Đo tại chỗ: Zoom CÓ phơi AXWindow; menu `Meeting` KHÔNG có lúc idle; AX đọc được AXURL của Chrome/Brave/Vivaldi | Dứt điểm tranh cãi screenpipe↔ZoomStat bằng phép đo, không bằng trọng tài (Quy tắc 12). screenpipe sai ở cả hai điểm |
| 2026-10-13 | **ĐÍNH CHÍNH KIẾN TRÚC** — bỏ "AX-only", chuyển sang Tầng 1 lịch-sử-trình-duyệt (zero quyền) + Tầng 2 AX opt-in | Đo lịch thật: Meet 71 · Zoom **0** · Teams 1 · Webex 1 trong 30 ngày. Nhánh Zoom mà 5/6 mũi dồn công vào không tồn tại trong thực tế của Duy |
| 2026-10-13 | **Quyết định D** — làm CẢ HAI tầng. Duy bác khuyến nghị "Tầng 1 một mình" của PM | Quyết định của Duy. PM tự chốt hai hệ quả: D-1 Tầng 2 bật mặc định + xin quyền 1 lần lúc cài, từ chối thì lùi êm về Tầng 1; D-2 Tầng 1 là lát cắt dọc đầu ở S3 |
| 2026-10-13 | **S0 Discovery HOÀN TẤT** — PRODUCT-BRIEF + LEGAL-SCREEN + go/no-go đã ghi. Con trỏ vẫn ở `00-discovery` | Claude không tự đẩy con trỏ được (Quy tắc 1) |
| 2026-10-13 | **Quyết định E** — chạy S1 ngay, `noelroom` nhường đường. Duy nguyên văn: *"làm ngay bây h, skip noelroom"* | PM khuyến nghị ngược lại (noelroom có hạn chót cứng 25/12, presence-gate không có) và **bị bác**. Đã ghi đối ứng vào `noelroom/PIPELINE.md` commit `597f503` — một waiver chỉ sống ở một repo là waiver không ai biết |
| 2026-10-13 | S1 mở. `gates/01-spec/UNDERSTOOD.md` viết TRƯỚC khi stage bắt đầu, 3/3 trích dẫn khớp nguyên văn | Quy tắc 11 |
| 2026-10-13 | **Bất đồng [1] W đóng bằng SỐ: W = 900s.** Backtest 71 cuộc/30 ngày: 300s→78%, 600s→89%, **900s→94%**, 1800s→100% nhưng **vỡ G1** (1 lần im nhầm) | Không bỏ phiếu giữa ba phòng — đo. 900s là điểm cuối cùng còn giữ G1=0. Script giữ ở `probe/backtest-presence-gate.py` |
| 2026-10-13 | **Bất đồng [2] nhật ký: PM quyết theo LEGAL — ghi HASH** `sha256(roomCode)[0:8]`, không ghi mã phòng nguyên văn | Lập luận quyết định của Legal mà Data chưa tính: link Meet là **bearer credential**, và theo Quyết định A log sẽ chạy trên máy ĐỒNG NGHIỆP, chứa link họp của công ty họ — không phải của Duy. Cái log đó bị `sysdiagnose` / Time Machine gom đi là đường rời máy mà "không gửi ra mạng" không chặn được |
| 2026-10-13 | **Bất đồng [3] thứ tự Tầng 2: CHƯA GIẢI — leo lên Duy** | Hai phòng đề nghị hoãn, PM đề nghị làm kèm cổng cứng. Câu spec chưa rõ: Quyết định D ràng buộc PHẠM VI hay ràng buộc cả THỨ TỰ? Không ép đồng thuận (Quy tắc 12) |
| 2026-10-13 | **Đo Zoom khi ĐANG HỌP** (Claude tự dựng phòng solo, không mời ai, ~20s rồi đóng): tiêu đề = `"Duy Pham's Zoom Meeting"`, **KHÔNG có meeting ID ở bất kỳ đâu trong cây AX**. `CptHost` không xuất hiện kể cả khi họp | Tầng 2 chứng minh được HIỆN DIỆN, chưa chứng minh được DANH TÍNH ⇒ chưa thoả Quyết định B. Không tự hạ chuẩn. Nhưng tôi đo ca PMI (không chủ đề); ca đáng đo là cuộc ĐẶT LỊCH, vốn mang chủ đề làm tiêu đề — nhánh đó còn sống, chưa đo |
| 2026-10-13 | **Bất đồng [3] PM tự quyết thay vì chặn**: giữ nguyên phạm vi (Quyết định D), làm **Tầng 1 trước**, Tầng 2 chờ phép đo cuộc-Zoom-đặt-lịch | Duy: *"tiếp tục công việc, tại sao lại dừng"*. Quyết định D ràng buộc phạm vi, không ràng buộc thứ tự — nên xếp Tầng 2 sau không phải bác Duy |
| 2026-10-13 | **MỞ LẠI S2.** Duy: *"redesign lại toàn bộ UIUX và app này phải có ngôn ngữ của tiếng Việt"* | Bản `N/A` cũ đúng với phạm vi "một tính năng vô hình", sai với phạm vi "toàn bộ app". Đo: 355 chuỗi · 23 ngôn ngữ không có `vi` · 24 file UI. Kéo theo một mâu thuẫn ONE-PAGER §2 phải gỡ |
| 2026-10-14 | **Gỡ MeetingBar bản App Store (4.11.6, team KGH289N6T8), cài bản fork vào `/Applications`.** Bản cũ KHÔNG xoá — đã dời thành `/Applications/MeetingBar-AppStore-cu.app` và sao lưu đầy đủ ở `~/Documents/MeetingBar-backup-2026-10-14/` | Duy: *"gỡ meetingbar hiện tại và cài bản meetingbar đã được customize"*. App Store cài bằng `root:wheel` nên không xoá được khi không có mật khẩu; nhưng ĐỔI TÊN trong cùng thư mục thì được — `rename()` chỉ đòi quyền ghi trên chính bundle khi phải sửa `..`, tức khi chuyển sang thư mục cha khác |
| 2026-10-14 | **Quyết định F — đổi bundle ID: `leits.MeetingBar` → `com.duypham.meeting-menubar`** (test: `.tests`). `DEVELOPMENT_TEAM` → `8JK69YTTHU` | BẮT BUỘC, không phải lựa chọn: App ID `leits.MeetingBar` thuộc team của leits, không ai khác xin được provisioning profile. Lập luận "giữ ID để giữ quyền TCC" đã bị bác bằng sự thật: TCC khoá theo **cặp** bundle-id + chữ ký, mà chữ ký đổi từ `Apple Mac OS Application Signing` sang `Apple Development` dù có giữ ID hay không ⇒ quyền mất trong cả hai đường. Giữ ID không được lợi gì, chỉ còn giữ tên leits trong định danh (Apache §6) |
| 2026-10-14 | `SandboxContainerMigration.containerPlistURL` đổi từ `Bundle.main.bundleIdentifier` sang hằng `legacyBundleID = "leits.MeetingBar"`. Thêm test canh hai chiều | Hệ quả trực tiếp của Quyết định F, và suýt là lần thứ hai của cùng một lỗi: hỏi "tôi là ai" để tìm "cấu hình của người tiền nhiệm nằm đâu". Hai câu đó chỉ trùng nhau tình cờ khi fork chưa đổi danh tính. Container nguồn là **sự kiện lịch sử**, nên hằng số cứng ĐÚNG HƠN giá trị dẫn xuất. Đã chứng thực trên máy thật: `migrate mang 39/41 khoá`, `autoJoin enabled=false` → `true` |
| 2026-10-14 | **Bỏ entitlement `com.apple.developer.usernotifications.time-sensitive`** cho bản cài tại chỗ, qua file riêng `MeetingBar/MeetingBar-local.entitlements` (khác bản gốc đúng MỘT khoá) | Mọi entitlement họ `com.apple.developer.*` đòi provisioning profile, mà Xcode trên máy này chưa đăng nhập Apple ID ⇒ giữ nó thì **không ra được app nào**, không phải mất một tính năng. **Cái mất, nói thẳng:** thông báo không xuyên qua Focus/DND nữa. **Cái không mất:** tự mở link họp không đi qua thông báo nên chạy nguyên vẹn. Lấy lại: đăng nhập Apple ID trong Xcode rồi build bằng entitlements gốc, không sửa dòng code nào |
| 2026-10-14 | **Lỗi upstream #8 — `MeetingOpener.emailAttendees` force-unwrap `NSSharingService(named:)`.** Đã vá bằng `guard let` + log | Trả nil khi máy không có ứng dụng nhận `composeEmail` ⇒ bấm một mục menu là **giết cả app thanh menu**. Nhưng phát hiện lớn hơn là thứ nó che: crash giết tiến trình test giữa chừng, nên suite báo `Executed 314 tests, 0 failures` trong khi **191 test chưa từng chạy**. Sau khi vá: `505 tests, 0 failures`. Cả dự án đã chạy trên 62% tín hiệu test mà tưởng là 100% |
| 2026-10-14 | **Lỗi upstream #9 — ngõ cụt quyền Lịch.** `openCalendarPermissionsAction` nay HỎI quyền khi `.notDetermined`, chỉ mở System Settings khi `.denied`/`.restricted` | Không mảnh nào sai một mình; ba hành vi đúng ghép lại thành trạng thái không lối ra: ① `onboardingCompleted=true` nên onboarding không chạy lại ② chỗ DUY NHẤT gọi `signIn()` là luồng chọn provider, mà onboarding mới gọi ③ TCC reset khi chữ ký đổi. Kết quả: app xin người dùng vào System Settings bật quyền, nhưng macOS **chỉ liệt kê app đã từng hỏi** — ở đó không có dòng nào để bật. Gặp thật khi cài bản fork này |
| 2026-10-14 | **Icon mới: chữ V trong khung lịch** — thay cả icon thanh menu (3 SVG) lẫn icon Dock (11 PNG). Sinh bằng `scripts/make-icons.swift`, gọi qua `make icons` | Duy: *"redesign lại icon và cũng như icon trên menubar để biết đây là bản customize của tôi"*. Mark **không chọn bằng gu mà bằng phép đo ở 16px** — kích thước thật trên thanh menu: bỏ lưới ô ngày thì khung bo góc đọc ra "máy ảnh"; giữ lưới rồi thêm huy hiệu thì nhoè thành vệt; tô đặc ô giữa thì không phân biệt nổi với bản gốc. Thanh menu máy đích vốn đã có một ô-vuông-tick và một ô-ngày-số nên hai hướng hiển nhiên đó cũng bị loại vì trùng hàng xóm. **Màu nhấn Dock (đang là vàng) vẫn là gu — chờ Duy** |
| 2026-10-14 | `legal/licences.json` ra đời. `vibe-check`: **PASS, 0 lỗi chặn, 0 cảnh báo** | Quy tắc 4 — sổ giấy phép commit cùng commit với asset. Ghi rõ hai bề mặt tách rời: giấy phép MÃ NGUỒN (Apache-2.0) và NHÃN HIỆU bên thứ ba (60 logo trong `vendor-icons/` mà Apache-2.0 của leits không cấp quyền được, vì leits cũng không sở hữu). Mục `chua_xac_minh` nêu đích danh: chưa rà từng logo, mở khoá trước bất kỳ phân phối công khai nào |
| 2026-10-14 | **Màu nhấn icon Dock: VÀNG** (`#FAC229`). Duy chốt: *"oke vàng"* | Khớp bản đã build nên không phải dựng lại. Đây là phần GU duy nhất của việc đổi icon — hình thì chọn bằng phép đo ở 16px, màu thì không đo được. Phạm vi hẹp hơn vẻ ngoài: màu chỉ chạm icon Dock và màn hình Giới thiệu; icon thanh menu là template nên macOS luôn nhuộm đen/trắng theo nền và không nhận màu. Đổi lại: sửa hằng `accent` trong `Scripts/make-icons.swift` |
