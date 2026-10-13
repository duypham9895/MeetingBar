---
owner: Duy (Edward Pham) — duyệt và sở hữu
soạn: Phòng PM (gộp PM + Design + Content), 2026-10-13
freshness: 2026-10-13
blocked_by: ONE-PAGER §2 (đoạn thay đã soạn, trường `onePagerS2`)
status: CHỜ DUY DUYỆT — đây là cổng ĐẦU S2 (Quy tắc 13)
tham_chiếu: gates/02-design/VI-LOCALIZATION.md · gates/02-design/DESIGN-REFERENCE.md
---

# DESIGN-BRIEF — S2

> **Thời gian đọc: ~4 phút.** Cần Duy quyết **đúng một việc trong file này**: chọn 1 trong 3 hướng ở §3.
> Các câu hỏi khác đi riêng, **mỗi tin nhắn một câu** (Quy tắc 9).
> Tự kiểm phía tác giả — **same vendor, same priors — no external verifier ran.**

## TL;DR

Yêu cầu *"redesign toàn bộ UI/UX + tiếng Việt"* không thể hiểu là vẽ lại 18.127 dòng Swift trong 5 cuối tuần. Hiểu được và làm được là: **app nói tiếng Việt, mang tên của chính nó, và bỏ những thứ thuộc về upstream.** Hạ tầng tiếng Việt **rẻ hơn tưởng** (1 thư mục + 1 file + 2 dòng Swift — đã build thử, thành công); chi phí thật nằm ở **~339 chuỗi dịch** và ở **menu thanh trạng thái, 1.284 dòng AppKit viết tay**. Ba hướng ở §3 gói sẵn cả *dáng* lẫn *phạm vi* để Duy chỉ phải quyết **một lần**.

## §0. Một lỗi CHẶN phải gỡ trước

`ONE-PAGER §2` đang viết *"mọi thứ hiện ra màn hình đều là một thất bại của thiết kế"*. Câu đó đúng với **cổng presence**, sai với **app chứa nó** — và chính cách đọc đó đã đẻ ra `gates/02-design/N-A.md` kết luận *"sản phẩm không có bề mặt hình ảnh"* cho một app có 24 file UI. Không phòng nào viết được `UNDERSTOOD.md` khi còn trích câu đó. **Đoạn §2 thay thế đã soạn sẵn, Duy duyệt rồi dán** (câu hỏi 1).

## §1. Ba tính từ

| Tính từ | Nghĩa **kiểm được** | Phản ví dụ đang có trong code |
|---|---|---|
| **Lặng** | Không bao giờ *tự* đòi chú ý: không badge, không chấm đỏ, không animation nền | `FullscreenNotification.swift` — bề mặt duy nhất tự chiếm cả màn hình |
| **Chắc** | Liếc một cái là biết, không phải đọc hai lần | giới hạn tiêu đề mặc định **55 ký tự** ≈ 433pt — đó là một đoạn văn, không phải một nhãn |
| **Quen** | Đọc như macOS, và như tiếng Việt nói ở văn phòng Ringkas | `"Woohoo! It's time to make cocoa"` — dịch thẳng là hỏng cả ba |

**Gỡ hoà khi "Quen" tự mâu thuẫn** (đã đo: Finder tiếng Việt dùng đúng chữ `Tùy chọn`): **macOS thắng ở tên bề mặt hệ thống** (tab, menu, nút chuẩn — `Tùy chọn`, `Thoát`, `Cảnh báo`); **văn phòng Ringkas thắng ở câu do app tự nói** (trạng thái rỗng, onboarding, lỗi). Cái bị cấm ở §2 là **kiểu đặt câu dịch 1-1** (`General Settings → Tùy chọn chung`), không phải bản thân từ `Tùy chọn`.

## §2. Ba thứ KHÔNG được giống

| Không giống | Dấu hiệu lỡ rồi | Vì sao |
|---|---|---|
| **Phần mềm dịch máy** | câu dịch 1-1, bị động, Hán-Việt cứng, `bạn` lặp hai lần một câu | App cho **5 người Việt cùng công ty**, không phải bản địa hoá thị trường. Viết thẳng, đừng dịch |
| **Dashboard / SaaS** | thẻ bo góc, huy hiệu đếm, gradient, emoji trong trạng thái rỗng | Không có ai để gây ấn tượng. Thêm một thẻ là thêm một thứ phải nhìn |
| **Spyware** | icon con mắt, chấm đỏ kiểu đang-ghi, chữ "đang theo dõi" | App **xin quyền Accessibility**. `WRITER-NOTES §4` đã cấm bộ từ vựng đó; cấm chữ mà không cấm hình là vô nghĩa |

## §3. BA HƯỚNG — Duy chọn MỘT (đây là quyết định GU)

Mỗi hướng gói **cả dáng thanh menu lẫn phạm vi công việc**, cố ý — để không phải hỏi Duy hai bảng cho một stage.

| | **1 — LẶNG** ⭐ | **2 — GỌN** | **3 — ĐẦY** |
|---|---|---|---|
| **Thanh menu** | icon + **chỉ thời gian**: `􀉉 5 ph`. Rộng cố định ~55–70pt, không phụ thuộc tên họp | icon + tên cắt + giờ, hạ giới hạn **55 → 22 ký tự** (433pt → 173pt) | giữ **hai dòng** 12pt/9pt, bắt buộc sửa `lineHeightMultiple 0.7 → ≥0.88` và bỏ `baselineOffset: -3` |
| **Menu xổ xuống** | chỗ duy nhất có tên họp, **không cắt**; giữ timeline, bỏ thẻ tóm tắt | như 1 | như 1 |
| **Phạm vi** | dịch **~339 chuỗi** · **cắt** Changelog (113 dòng Anh cứng) + khối Patron · **giữ** tab Advanced bằng tiếng Anh · đổi tên app + bundle id | dịch ~339 chuỗi · đổi tên · **không cắt gì** | như 1 **+ sắp lại kiến trúc Preferences** (gộp/bỏ tab chết) |
| **Được gì** | bài toán chiều rộng tiếng Việt **biến mất**; tên họp không lộ khi share màn hình; app hết mang dấu vết của người khác | thay đổi nhỏ nhất, rủi ro thấp nhất | nhiều thông tin nhất; app "khác" rõ nhất |
| **Mất gì** | liếc chỉ biết *còn bao lâu*, không biết *cuộc nào* | 22 ký tự thường **không đủ**: `"Họp giao ban hằng tuần"` vừa đúng 22 | 9pt là cỡ chữ nhỏ nhất app, cứng; và phải trả giá đo được ở §4 |
| **Ước** | ~2,5–3 cuối tuần | ~2–2,5 cuối tuần | ~4+ cuối tuần — **nhiều khả năng trượt 15/11** |

**Khuyến nghị: Hướng 1.** Ba lý do, theo thứ tự: (1) nó **xoá** bài toán chiều rộng thay vì quản lý nó mãi; (2) phần lớn là **đổi giá trị mặc định đã có** (`eventTitleFormat = .none`) và **xoá**, không phải viết mới; (3) *"build up lại UI"* nên xảy ra **trong menu xổ xuống, nơi có chỗ**, không phải trong dải 22pt nơi macOS sẽ âm thầm ẩn bớt icon khi hết chỗ. **Loại thẳng Hướng 3**, không hoãn: nó đụng `MenuBuilder.swift` — đúng file cổng presence vừa chèn vào ở S3.

## §4. Bốn ràng buộc đã ĐO (không phải giả định)

| Ràng buộc | Kết quả |
|---|---|
| **Font có đủ dấu tiếng Việt không** | **CÓ — thiếu 0/105 code point** (`CTFontCopyCharacterSet` trên `systemFont 13/12` + `menuBarFont`). App **không nhúng font nào** (`grep NSFont(name:\|Font.custom` → 0). ⇒ không có vấn đề giấy phép font, không có rơi-font giữa câu. **Bài học #1 của xưởng đã gỡ cho app này** |
| **Thêm `vi.lproj` là đủ chưa** | **Chưa.** `AppLanguage` là enum Swift cứng 17 case trong khi đĩa có 23 `.lproj`. Phải sửa **đúng 3 chỗ**. **Tiền lệ đang hỏng thật: `case ukrainian = "ua"` nhưng thư mục là `uk.lproj`** ⇒ chọn tiếng Ukraina thì app im lặng quay về ngôn ngữ hệ thống. Gõ sai `vn` thay `vi` là hỏng y hệt, **không báo gì** |
| **Tiếng Việt có dài hơn không** | **Không nhất quán — xem `batDong` #1.** Đo chiều rộng: +47% / −5% / −18%. Chiều rộng là hệ quả của **cách dịch**, không phải của ngôn ngữ ⇒ công cụ là **ngân sách ký tự trong `.strings`** (sidebar ≤12 · nút ≤16 · hàng Preferences ≤28 · lên thanh menu ≤22), không phải sửa layout |
| **Dấu có vượt khung dòng không** | **Có, về hình học:** mực của `Ế` cao **11,43pt**, `Ệ` cao **13,82pt**, trong khung dòng **10,50pt** (`lineHeightMultiple = 0.7`). **Chỉ Hướng 3 chạm bug này.** Mắt có thấy cắt hay không thì phải chụp màn hình |

## §5. Việc KHÔNG AGENT NÀO LÀM THAY ĐƯỢC (Quy tắc 6)

| # | Việc | Chặn gì |
|---|---|---|
| 1 | **Duyệt đoạn ONE-PAGER §2 thay thế** | cả S2 — không phòng nào viết được `UNDERSTOOD.md` |
| 2 | **Chọn 1 trong 3 hướng §3** | ngân sách ký tự ⇒ 99 chuỗi nhóm thanh trạng thái |
| 3 | **Chốt giọng văn** (không xưng hô / xưng "bạn") | cả ~339 chuỗi |
| 4 | **Chốt tên app** (treo từ S1) | ~14 chuỗi + bundle id + file .app phát cho đồng nghiệp |
| 5 | **Đọc to ~20 chuỗi mẫu** | nghiệm thu tính từ **Quen** — không máy nào biết câu nào nghe như máy dịch |
| 6 | **Soát bẫy bỏ dấu trên chuỗi UI** | denylist bắt từ tục; va chạm **nghĩa** (`co mat` → "có mắt") chỉ người bắt được |
| 7 | **Nhìn thanh menu với tiêu đề `Đã Ế Ộ Ữ`** | nghiệm thu S4 — Quy tắc 8: *"xong nghĩa là đã nhìn thấy số"* |
| 8 | **Chấp nhận rủi ro tồn dư** (fork vĩnh viễn, 22 ngôn ngữ lệch, UI trộn lúc dịch dở) | ghi quyết định vào `gates/` |

## §6. CHƯA XÁC MINH ĐƯỢC

| Chưa biết | Gỡ bằng | Tốn |
|---|---|---|
| **5 đồng nghiệp có muốn tiếng Việt không — Duy là n=1, chưa ai hỏi** | một tin nhắn cho 5 người | 5 phút — **rẻ nhất, chưa ai làm** |
| **Tốc độ của Duy trên SwiftUI** — không artifact nào ghi giờ ⇒ mọi ước ở §3 là phán đoán | bấm giờ lát đầu rồi hiệu chỉnh | nửa buổi |
| **Dấu có bị cắt thật trên màn hình không** (§4) | build + chụp màn hình | 15 phút |
| **Layout có vỡ khi chữ giãn không** — 28 chỗ `.frame(width:)` cứng | dựng `vi.lproj` đầy đủ rồi nhìn | trong lát dịch |
| **Giá merge upstream sau khi cắt/sắp lại** | chưa có phương pháp đo rẻ | — |

---

*Bản `DESIGN-BRIEF.md` 21,8 KB mà phòng Design nộp **không bị xoá** — đổi tên thành `gates/02-design/DESIGN-REFERENCE.md` (THAM CHIẾU, không ai review). File này là bản QUYẾT ĐỊNH thay nó. Quy tắc 5: trộn hai loại vào một file là bắt Duy đọc 800 dòng để tìm 20 dòng cần quyết.*