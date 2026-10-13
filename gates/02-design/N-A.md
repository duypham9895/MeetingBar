---
stage: 02-design
date: 2026-10-13
status: N/A — because sản phẩm không có bề mặt hình ảnh
---

# S2 Design — `N/A — because`

ONE-PAGER §2, nguyên văn: *"Thành công của tính năng này là người dùng không nhận ra nó tồn
tại… Mọi thứ hiện ra màn hình đều là một thất bại của thiết kế."*

Một stage thiết kế cho một tính năng **không vẽ gì ra màn hình** là một nghi lễ rỗng. Đánh dấu
thay vì giả vờ chạy. Toàn bộ bề mặt nhìn thấy được của presence-gate gồm đúng ba thứ, và cả ba
đã có chủ ở stage khác:

| Bề mặt | Ai đã làm | Ở đâu |
|---|---|---|
| Microcopy hộp thoại quyền Accessibility (Tầng 2) | Writer, ở S1 | `../01-spec/WRITER-NOTES.md` |
| Từ vựng dùng thống nhất S1→S6 | Writer, ở S1 | `../01-spec/WRITER-NOTES.md` |
| Cửa sổ "đã vào" `W` | **không có UI** — Defaults key `presenceGateWindowSeconds` | `MeetingBar/Extensions/DefaultsKeys.swift` |

**Quyết định GU duy nhất còn treo là TÊN SẢN PHẨM** (Apache-2.0 §6 cấm dùng "MeetingBar" cho
bản phân phối). Writer đã đưa ứng viên ở S1. **Không agent nào chọn thay Duy** (Quy tắc 6).
Nó không chặn S3 — chỉ chặn việc đưa file cho đồng nghiệp.

**Khi nào mở lại S2:** nếu Tầng 2 cần một màn hình xin quyền riêng, hoặc nếu sau khi dùng thật
Duy muốn thấy một chỉ báo "cổng vừa chặn một lần".
