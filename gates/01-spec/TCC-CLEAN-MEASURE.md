---
stage: 01-spec
date: 2026-10-13
status: pass — có nhóm đối chứng
---

# TCC-CLEAN-MEASURE — Tầng 1 có cần quyền không

## Vì sao file này tồn tại

Phép đo đầu tiên (*"`sqlite3` đọc lịch sử Vivaldi, không prompt nào"*) chạy từ iTerm2.
**iTerm2 có Full Disk Access** — đọc được `~/Library/Application Support/com.apple.TCC/TCC.db`
(471 dòng) và `~/Library/Safari/History.db` (14.541 mục). Mọi kết luận rút từ đó **vô hiệu**.
T3 và phòng Legal bắt được độc lập với nhau.

## Đo lại đúng cách

App bundle `vn.duy.tccprobe`, ký ad-hoc, `LSUIElement`, chạy bằng `open` ⇒ mang **danh tính
TCC của chính nó**, không thừa kế của terminal. macOS 26.5.1 (25F80), 2026-10-13.

| Đường dẫn | Kết quả | Vai trò |
|---|---|---|
| `~/Library/Application Support/Vivaldi/Default/History` | **ĐỌC ĐƯỢC** | Tầng 1 cần |
| `~/Library/Application Support/Google/Chrome/Default/History` | **ĐỌC ĐƯỢC** | Tầng 1 cần |
| `~/Library/Application Support/BraveSoftware/Brave-Browser/Default/History` | **ĐỌC ĐƯỢC** | Tầng 1 cần |
| `~/Library/Safari/History.db` | **BỊ CHẶN** NSError 513 | **đối chứng** |
| `~/Library/Application Support/com.apple.TCC/TCC.db` | **BỊ CHẶN** NSError 513 | **đối chứng** |

**Hai đối chứng bị chặn là thứ làm phép đo có giá trị.** Không có chúng thì ba dòng "đọc được"
chỉ là quyền thừa kế đội lốt phát hiện.

## Kết luận

**Tầng 1 là zero-permission.** Và Safari **phải bỏ**: nó đòi Full Disk Access (một toggle tay
⇒ vi phạm Quyết định C) để đổi lấy **0 lượt Meet** trong 102.522 lượt duyệt web.

## Chưa xác minh được

- Hành vi trên máy **đồng nghiệp** có thể khác nếu họ bật FileVault + MDM với cấu hình TCC riêng.
- macOS 27 chưa ra; Apple đã siết thư mục `~/Library/Application Support` nhiều lần.
  **Phải đo lại mỗi bản macOS lớn** — thêm vào checklist S6.
