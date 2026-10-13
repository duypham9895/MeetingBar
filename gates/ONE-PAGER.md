---
owner: Duy (Edward Pham)
freshness: 2026-10-13
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
