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
| S0 | Discovery | in-progress | `gates/00-discovery/PRODUCT-BRIEF.md` · `LEGAL-SCREEN.md` | |
| S1 | PRD | pending | `gates/01-spec/PRD.md` · `ACCEPTANCE.md` · `SUCCESS-CRITERIA.md` · `TRACKING-PLAN.md` · `LEGAL-REVIEW.md` | |
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
