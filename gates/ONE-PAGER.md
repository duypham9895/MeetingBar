---
owner: Duy (Edward Pham)
freshness: 2026-10-13 (sửa §4 sau S1; sửa §2 sau S2)
status: draft — CHƯA được Duy duyệt
---

# ONE-PAGER — presence-gate

> PM soạn. **Duy duyệt và sở hữu.** Mọi phòng đọc file này trước khi bắt đầu stage của mình.

## 1. Sản phẩm này là gì, cho ai

Một bản MeetingBar đã sửa, cho **Duy và vài đồng nghiệp ở Ringkas**. Nó làm đúng một việc
MeetingBar không làm: **trước khi tự mở link họp, nó kiểm xem máy này đã ở trong cuộc họp đó
chưa. Nếu rồi thì im hẳn.**

Không phải sản phẩm công khai. Không lên App Store. Không bán.

## 2. Cảm giác muốn tạo ra

**Không có cảm giác nào.** Thành công của tính năng này là **người dùng không nhận ra nó tồn
tại** — cái tab thứ hai đơn giản là không còn xuất hiện nữa. Mọi thứ hiện ra màn hình đều là
một thất bại của thiết kế.

## 3. Ba thứ KHÔNG làm

1. **Không lên Mac App Store** — sandbox cấm Accessibility API, mà đó là con đường duy nhất
   chạy được trên Zoom và Teams. Chọn App Store là tự cắt mất tính năng chính.
2. **Không xin quyền Screen Recording** — có đường ít xâm phạm hơn, và một app lịch xin quyền
   quay màn hình trông như spyware. Kể cả khi nó làm detect dễ hơn.
3. **Không gửi PR upstream** — maintainer đã đóng issue #664 với lý do "intended behavior".
   Đây là fork, không phải đóng góp.

## 4. Thành công đo bằng gì

`N/A — because` đây là công cụ cá nhân cho ≤5 người, không có instrumentation và cố ý không có
(Quyết định A, 2026-10-13). Phép đo duy nhất là **Duy dùng thật trong 2 tuần và đếm bằng tay số
lần tab thừa xuất hiện**. Nếu sau này phát cho >5 người, quay lại viết `TRACKING-PLAN.md` thật.

## Tên sản phẩm — CHƯA QUYẾT, và là việc của Duy

Apache-2.0 §6 cấm dùng tên của tác giả gốc cho bản phái sinh được phân phối. Repo fork giữ tên
`MeetingBar` là bình thường, nhưng **file .app phát cho đồng nghiệp phải mang tên khác**.
Đây là quyết định gu — không agent nào chọn thay.

---

## §4 — BẢN SỬA 2026-10-13, sau S1

> Quy tắc 14: không sửa tại chỗ. Mục này đè lên §4 ở trên; bản cũ giữ nguyên để còn đọc được
> lý do cũ. `vibe-check` mục [2] đã chặn đúng — spec đổi mà tuyên bố chưa đổi theo.

§4 ở trên viết *"không có instrumentation… phép đo duy nhất là Duy đếm bằng tay"*. **Sai, và
sai theo hướng bỏ phí.** S1 phát hiện sản phẩm này có **ground truth sẵn**: lịch sử trình duyệt
và Google Calendar cùng ghi lại 30 ngày quá khứ, nên cổng **chạy ngược được** và đếm chính xác
số lần nó sẽ sai — **trước khi viết dòng Swift nào.**

**Thành công đo bằng ba cổng, đã chạy thật trên 71 cuộc họp / 30 ngày** (`W=900s`, `LEAD=180s`,
script `probe/backtest-presence-gate.py`):

| Cổng | Là gì | Ngưỡng | Kết quả hôm nay |
|---|---|---|---|
| **G1** | số lần **im nhầm** ⇒ lỡ họp | **0, không thương lượng** | **0** ✅ |
| **G2** | % lượt bắn-trùng bị chặn | > 80% | **94%** (17/18) ✅ |
| **G3** | quyền mới người dùng phải cấp cho Tầng 1 | **0** | **0** ✅ (có nhóm đối chứng — `01-spec/TCC-CLEAN-MEASURE.md`) |

Chi tiết: `gates/01-spec/SUCCESS-CRITERIA.md`. `TRACKING-PLAN.md` vẫn là quyết định hoãn có
lý do — không analytics, không mạng; xem file đó.

**Vì sao G1 không thương lượng:** hai loại lỗi không đối xứng. Mở thừa một tab = đúng bằng
hiện trạng hôm nay, giá bằng không. Im nhầm = **lỡ họp**, không hồi phục, và phát hiện ra lúc
đã muộn.

---

## §2 — BẢN SỬA 2026-10-13, sau yêu cầu redesign UI/UX

> Quy tắc 14: không sửa tại chỗ. Mục này đè lên §2 ở trên; bản cũ giữ nguyên để còn đọc
> được lý do cũ. §2 cũ đã bị đọc sai một lần, và cái giá là `gates/02-design/N-A.md` —
> một file kết luận *"sản phẩm không có bề mặt hình ảnh"* cho một app có 24 file UI,
> 18.127 dòng Swift và 355 chuỗi hiển thị.

§2 cũ viết *"mọi thứ hiện ra màn hình đều là một thất bại của thiết kế"*. Câu đó **đúng**,
nhưng nó nói về **cổng presence**, không nói về **app chứa cổng**. Trộn hai thứ làm một là
lý do S2 bị đánh N/A.

| Đối tượng | Lời hứa |
|---|---|
| **Cổng presence** (một tính năng) | **Vô hình.** Thành công là người dùng không nhận ra nó tồn tại — cái tab thứ hai đơn giản không còn xuất hiện. Cổng tự mở một cửa sổ, một banner hay một âm thanh đều là thất bại thiết kế. **Quyết định B không đổi.** |
| **App chứa nó** (thứ Duy mở mỗi ngày) | **Thuộc về người dùng Việt.** Nó nói tiếng Việt, mang tên của chính nó, và không bắt ai đọc tiếng Anh để biết cuộc họp tiếp theo lúc mấy giờ. Nó **lặng** — không tự đòi chú ý — nhưng lặng không có nghĩa là không được chạm vào. |

**"Vô hình" là ràng buộc của MỘT TÍNH NĂNG, không phải giấy phép để app xấu, để app nói
ngôn ngữ của người khác, hay để stage thiết kế bị bỏ qua.**

*Ngắn có chủ đích: mọi câu thêm vào đây là một câu nữa có thể bị trích sai ở stage sau.*