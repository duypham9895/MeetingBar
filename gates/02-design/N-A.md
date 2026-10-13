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

---

# MỞ LẠI — 2026-10-13, phạm vi đã đổi

> Quy tắc 14: không xoá phần trên. Bản `N/A` ở trên **đúng với phạm vi lúc đó** và sai với
> phạm vi bây giờ. Giữ nó để còn đọc được lý do cũ.

Duy, nguyên văn:
> *"sau khi done hết tất cả, hãy cùng involve team PM + Design + Content redesign lại toàn bộ
> UIUX và app này phải có ngôn ngữ của tiếng Việt, hãy build up lại UI của app này"*

**Vì sao `N/A` không còn đúng:** nó lập luận rằng *presence-gate* không có bề mặt hình ảnh.
Điều đó vẫn đúng. Nhưng phạm vi vừa mở rộng từ **một tính năng vô hình** sang **toàn bộ app**,
và toàn bộ app thì có rất nhiều bề mặt:

| Đo thật, 2026-10-13 | |
|---|---|
| Chuỗi cần dịch | **355** |
| Ngôn ngữ đang có | 23 — **không có `vi`** |
| File UI | **24** (Preferences · Onboarding · StatusBar) |

**Mâu thuẫn phải gỡ, không được lờ:** `../ONE-PAGER.md` §2 đang ghi *"Mọi thứ hiện ra màn hình
đều là một thất bại của thiết kế."* Câu đó viết cho **cổng presence**; yêu cầu mới nói về
**toàn bộ app**. Hai thứ không nhất thiết chọi nhau, nhưng ONE-PAGER hiện **không phân biệt**
chúng, nên nó đang nói một điều sai về sản phẩm. Quy tắc 11 coi đây là **lỗi chặn**.
Phòng PM đang soạn câu thay thế; **Duy sở hữu và duyệt**.

S2 chạy lại theo Quy tắc 13: Duy duyệt `DESIGN-BRIEF.md` ở **ĐẦU** stage — đó là **quyết định
gu**, không agent nào thay được.
