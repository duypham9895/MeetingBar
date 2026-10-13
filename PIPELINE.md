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
| S2 | Design | pending | `gates/02-design/` | |
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
