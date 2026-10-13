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
