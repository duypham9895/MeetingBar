---
stage: 02-design
date: 2026-10-13
status: CHƯA LẬP — chờ Duy chốt phạm vi "Lát V1"
---

# STRINGS-OUT-OF-SCOPE

`VI-LOCALIZATION.md` trỏ tới file này cho danh sách những chuỗi **cố ý không dịch ở Lát V1**.

**Chưa lập.** Phòng PM đề xuất Lát V1 = **105 chuỗi** (29,6% của 355) phủ gần 100% thứ Duy
gặp hằng ngày, và hoãn hai nhóm: **Meeting Links + Browser config (49 chuỗi)** và
**Advanced (32 chuỗi)**. Danh sách chính xác chỉ chốt được sau khi Duy đồng ý con số 105 —
nếu anh muốn dịch cả 355 thì file này rỗng vĩnh viễn, và đó cũng là một kết quả hợp lệ.

**Mở khoá bằng:** Duy chốt phạm vi Lát V1 trong `DESIGN-BRIEF.md`.

⚠ **Một thứ nằm ngoài tầm với của mọi quyết định dịch:** `UI/Views/Changelog/Changelog.swift`
có **113 dòng tiếng Anh hardcode**, không đi qua `.loco()`. Thêm `vi.lproj` **không** chạm
được tới nó. Phòng PM đề xuất **cắt hẳn màn hình đó** — nó là lịch sử phát hành của upstream,
không phải của app này.
