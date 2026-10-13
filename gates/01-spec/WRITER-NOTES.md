# WRITER — presence-gate (S1)

> Thời gian đọc: **~6 phút**. Cái cần Duy quyết **in đậm**, 4 câu, hỏi từng câu một.
> Phương pháp: đo tại chỗ trên máy Duy + WebSearch. Tự kiểm phía tác giả —
> **same vendor, same priors — no external verifier ran.**

---

## 0. CHẶN TRƯỚC KHI ĐỌC TIẾP: nhiệm vụ giao cho tôi dựa trên một tiền đề sai

Đề bài nói *"macOS lấy chuỗi từ `NSAccessibilityUsageDescription`"*. Tôi đo, và nó không đúng.

| Phép đo | Lệnh | Kết quả |
|---|---|---|
| `tccd` biết những khoá `*UsageDescription` nào? | `strings -a /System/Library/PrivateFrameworks/TCC.framework/Support/tccd \| grep -E "UsageDescription$"` | **40 khoá. `NSAccessibilityUsageDescription` KHÔNG có mặt.** `NSAppleEventsUsageDescription` thì có |
| Accessibility có đi qua đường prompt không? | cùng lệnh, grep `accessibility` | chuỗi nguyên văn trong binary: `Service kTCCServiceAccessibility does not allow prompting; returning preflight_unknown` |
| Apple có tài liệu khoá này không? | fetch `developer.apple.com/.../nsaccessibilityusagedescription` | **HTTP 404** |

```
   ĐO ĐƯỢC   tccd — tiến trình DUY NHẤT đọc các khoá usage-description — không biết khoá này.
             kTCCServiceAccessibility được đánh dấu "does not allow prompting".

   SUY RA    hộp thoại Accessibility không chở được chữ của ta. Nó là chuỗi cố định
             của hệ thống, chỉ thay TÊN APP vào.  ← là SUY LUẬN, chưa phải phép đo
```

**Hai hệ quả, và cả hai đều đổi việc của phòng Writer:**

1. **Microcopy phải chuyển chỗ.** Nó không sống ở `Info.plist` được. Nó phải là **một cửa sổ của
   chính app**, hiện **trước** khi gọi `AXIsProcessTrustedWithOptions`. Sau hộp thoại hệ thống thì
   đã muộn — macOS chỉ đẩy người dùng sang System Settings rồi biến mất.
2. **TÊN APP TRỞ THÀNH MICROCOPY.** Trong hộp thoại đó, tên là chuỗi chữ duy nhất ta viết được.
   Một cái tên thơ mà không nói chức năng là **chi phí thật**, không phải chuyện thẩm mỹ.

Vẫn nên đặt `NSAccessibilityUsageDescription` trong Info.plist — tốn 2 dòng, và nếu một bản macOS
sau có đọc thì ta không mất gì. Nhưng **không được xây kế hoạch lên nó.**

---

## 1. TÊN — 6 ứng viên. Đây là quyết định GU, tôi chỉ đưa ứng viên (Quy tắc 6)

### Ràng buộc đã biết, trước khi xem bảng

| Ràng buộc | Nguồn |
|---|---|
| Không được dùng `MeetingBar` | Apache-2.0 §6 |
| **Cả `PRODUCT_BUNDLE_IDENTIFIER` cũng phải đổi** — hiện là `leits.MeetingBar`, mang **tên tác giả gốc** | đọc `MeetingBar.xcodeproj/project.pbxproj:472,502` |
| App không có icon Dock (`LSUIElement = true`) ⇒ tên **chỉ** xuất hiện ở: menu xổ xuống · System Settings → Privacy → Accessibility · System Settings → Login Items · **hộp thoại xin quyền** | đọc `MeetingBar/Info.plist` |
| App hiện có 24 bản dịch, **không có tiếng Việt** | `find . -name '*.lproj'` |

### Phép thử quyết định: đọc tên trong câu của hệ thống

Vì §0, cái duy nhất đồng nghiệp đọc được lúc bấm Cho phép / Từ chối là tên trong câu này.

| Tên | Nghĩa | Đọc trong câu *"«X» muốn điều khiển máy tính này"* | Vì sao hợp | Vì sao có thể dở | Trùng? |
|---|---|---|---|---|---|
| **Có Mặt** ⭐ | "present" — tiếng điểm danh | tự nhiên, chủ ngữ rõ, nghe như một tính năng lịch | đúng **khái niệm** của sản phẩm; 2 âm tiết; đồng nghiệp Việt hiểu ngay mà không cần giải thích | người không đọc tiếng Việt thấy vô nghĩa. Dạng bỏ dấu `co mat` **trùng âm với "có mắt"** — liên tưởng xấu cho một công cụ dò hiện diện | không thấy |
| **Vào Rồi** | "đã vào rồi" | nghe như **một người** nhắc, không phải một dịch vụ — rất phản-SaaS | đây đúng là câu app nói. Khẩu ngữ, ấm, không doạ ai | quá khẩu ngữ cho một dòng trong System Settings; nếu sau này phát rộng hơn 5 người thì thiếu trang trọng | không thấy |
| **Họp Chưa** | chính là câu hỏi app đặt ra | **đọc lên thấy kỳ** — một câu hỏi làm chủ ngữ | tên = chức năng, khỏi giải thích | hỏng đúng ở chỗ quan trọng nhất (§0). Tôi đưa vào để loại có lý do, không để chọn | không thấy |
| **Lặng** | sự im lặng | êm, nhưng **nói về cảm giác, không nói app làm gì** | đúng lời hứa ở ONE-PAGER §2; 1 âm tiết; đúng register menubar (Velja · Lunar · Magnet trên máy Duy đều ngắn) | sau §0, đây là lựa chọn đắt nhất: ở đúng chỗ cần giải thích thì nó im | không thấy |
| **Doorman** | người gác cửa — biết bạn đã vào trong chưa | tự nhiên, tiếng Anh, hợp app 24 ngôn ngữ | ẩn dụ đúng y chang cơ chế | **TRÙNG — tôi khuyên LOẠI.** ≥2 app macOS đã tên này: một menubar app (Product Hunt, 2019) và một password utility `com.mrFridge.Doorman` (2016) | **CÓ** |
| **Lull** | khoảng lặng giữa hai đợt ồn | gọn, hợp register | 1 âm tiết, nghĩa đúng, không SaaS | không thấy app macOS trùng, nhưng **≥4 app iPhone** trên App Store tên Lull / Lull Glow / lullogram ⇒ tên đã đông. Với đồng nghiệp Việt nó không gợi gì | iOS, không phải macOS |

### Lint bẩy bỏ dấu — đã chạy, cả NFC lẫn NFD

```
'Có Mặt'    NFC=6cp  NFD=9cp   strip='co mat'    crude_hit=[]
'Vào Rồi'   NFC=7cp  NFD=10cp  strip='vao roi'   crude_hit=[]
'Họp Chưa'  NFC=8cp  NFD=10cp  strip='hop chua'  crude_hit=[]
'Lặng'      NFC=4cp  NFD=6cp   strip='lang'      crude_hit=[]
```

Không ứng viên nào trúng denylist thô tục. **Nhưng `co mat` → "có mắt" là một va chạm NGHĨA, không
phải va chạm tục** — denylist không bắt được loại này, chỉ người bắt được. Duy xử.

### Quy tắc kỹ thuật bắt buộc nếu chọn tên có dấu

`../../../docs/lessons.md`: *"`Đêm Đông` là 8 code point ở NFC, 10 ở NFD."* Duy **đưa file .app cho đồng
nghiệp** (Quyết định A) — tức là zip rồi gửi, đúng chỗ NFC/NFD cắn.

```
   PRODUCT_NAME, tên file .app, bundle id   →  ASCII THUẦN      CoMat.app · com.duypham.comat
   CFBundleDisplayName                      →  có dấu, NFC      Có Mặt
```

**Khuyến nghị: `Có Mặt`.** Lý do, theo thứ tự: (1) sau §0 tên phải nói chức năng, và "có mặt" đúng
là khái niệm của sản phẩm; (2) người đọc nó là 5 đồng nghiệp Việt ở Ringkas, không phải thị trường;
(3) không trùng. Á quân: **Vào Rồi**, nếu Duy muốn app nghe như một người chứ không như một tính năng.

---

## 2. MICROCOPY xin quyền — 3 phương án cho **cửa sổ của chính app**

Không phải cho `Info.plist` (§0). Cửa sổ này hiện **trước** hộp thoại hệ thống, và nó phải làm hai
việc trong hai câu: gỡ nghi ngờ, và báo trước rằng macOS sẽ đẩy sang System Settings.

| | Góc | Chuỗi (≤2 câu) |
|---|---|---|
| **PA1** ⭐ | **Không gian âm** — nói nó KHÔNG làm gì | *"«Tên» chỉ cần nhìn thấy tên cửa sổ đang mở của Zoom và Teams — không đọc nội dung, không chụp màn hình, không gửi gì ra khỏi máy này. macOS sẽ mở System Settings để bạn gạt công tắc; sau lần này app không hỏi lại."* |
| **PA2** | Lợi ích trước, quyền sau | *"Để «Tên» khỏi mở thêm một tab khi bạn đã ngồi trong cuộc họp rồi, macOS cần bạn bật Accessibility cho nó. Đây là quyền duy nhất app xin, và chỉ xin một lần."* |
| **PA3** | Hạ áp lực — từ chối rẻ | *"Bấm Để sau cũng được — «Tên» vẫn làm đúng việc với Google Meet. Quyền này chỉ thêm Zoom và Teams."* |

**Khuyến nghị PA1, và đừng tiêu một câu cho PA3 — nhét nó vào NHÃN NÚT:**

```
   [ Mở System Settings ]        [ Để sau — chỉ dùng Google Meet ]
```

Nghi ngờ mà ta phải gỡ là *"app lịch xin quyền điều khiển máy = keylogger"*. Thứ gỡ được nó là
**danh sách những việc app sẽ không làm**, không phải lời hứa về việc nó sẽ làm. PA2 bán lợi ích
cho một người đang nghi — sai thời điểm. PA3 đúng về tâm lý nhưng nhãn nút chở được nó miễn phí.

**⚠️ Không đưa con số 97% vào chuỗi phát cho đồng nghiệp.** 71/73 là lịch **của Duy**. Lịch đồng
nghiệp chưa ai đo. Một con số đúng với một người, in ra cho năm người, là một con số bịa.

**Ngôn ngữ:** app hiện không có `vi.lproj`. Màn hình này chỉ hiện **một lần, cho 5 người Việt** —
tôi khuyên viết thẳng tiếng Việt và chấp nhận lệch ngôn ngữ ở đúng một màn hình. Dựng cả
`vi.lproj` cho 24 chuỗi còn lại là việc không ai yêu cầu.

---

## 3. App nói gì khi nó IM LẶNG

### Đặt lại vấn đề: im lặng không chỉ làm Duy mất tin, nó **xoá mất kênh báo lỗi duy nhất**

Khi cổng kết luận sai, hậu quả không phải một tab thừa — mà là **một cuộc họp bị lỡ, không có gì
trên màn hình**. Dấu vết không phải tiện nghi; nó là chỗ duy nhất một false-positive lộ ra.

Và ONE-PAGER §4 **đã** yêu cầu nó rồi, chỉ là chưa nói ra: *"Duy dùng thật trong 2 tuần và đếm bằng
tay số lần tab thừa xuất hiện."* Đếm bằng tay thì phải có chỗ mà đếm.

### Ba phương án, rẻ dần theo mức ồn

| | Cách | Người dùng thấy khi nào | Giá |
|---|---|---|---|
| **a** ⭐ | **Một dòng phụ trong menu xổ xuống đã có**, mờ, dưới tên sự kiện: *"14:00 — bỏ qua, bạn đã ở trong phòng"* | **chỉ khi tự bấm vào icon menubar** | ~0. Dùng bề mặt đã có, không thêm cửa sổ, không thêm quyền |
| **b** | `os_log` một subsystem riêng; đọc bằng Console.app hoặc `log show` | chỉ khi tự đi tìm | ~0 ở S3. Nhưng là **lệnh**, mà Duy nói *"tôi kh cần làm gì hết"* |
| **c** | File append-only `~/Library/Logs/<Tên>/bo-qua.log` | chỉ khi tự mở file | thấp, nhưng thêm một thứ phải dọn |

**Khuyến nghị: (a) làm chính + (b) làm nền.** (a) cho Duy, (b) cho lúc phải sửa bug — khi (a) không
hiện gì thì (b) phân biệt được *"cổng chạy và kết luận không trùng"* với *"cổng không chạy"*.

### Nó có vi phạm Quyết định B không — trả lời thẳng

```
   Quyết định B     "im hẳn, KHÔNG NOTIFY"
   Phương án (a)    không phải notification. Không banner, không âm thanh, không badge.
                    Nó không bao giờ TỰ hiện ra — người dùng phải chủ động mở menu.

   ⇒ KHÔNG vi phạm Quyết định B.
```

**Nhưng nó có chạm vào ONE-PAGER §2** — *"mọi thứ hiện ra màn hình đều là một thất bại của thiết
kế"*. Tôi cho rằng §2 vẫn đứng, vì dòng này **không hiện ra**, nó chỉ **có ở đó khi đi tìm**. Đó là
cách diễn giải của tôi, không phải của Duy. Đây là câu hỏi 2 ở dưới.

---

## 4. TỪ VỰNG — hợp đồng từ S1 tới S6

**Tên heading và tên khái niệm là hợp đồng. Đổi sau S3 là làm hỏng cả xưởng.**

| Khái niệm | **Chốt dùng** | Không dùng | Vì sao |
|---|---|---|---|
| tên dự án · repo · nhánh · thư mục `gates/` | `presence-gate` | — | đã nằm trong nhánh git, đường dẫn artifact và 11 dòng log. Đổi là viết lại lịch sử. **Giữ.** Đây là tên KỸ THUẬT, không bao giờ người dùng thấy |
| tên app phát cho đồng nghiệp | **Duy quyết (§1)** | `MeetingBar` | Apache-2.0 §6 |
| bundle identifier | `com.duypham.<ascii>` | `leits.MeetingBar` | mang tên tác giả gốc |
| nguồn bằng chứng từ lịch sử trình duyệt | **Nguồn Trình Duyệt** | ~~Tầng 1~~ | xem dưới |
| nguồn bằng chứng từ cây AX của app native | **Nguồn Cửa Sổ** | ~~Tầng 2~~ | xem dưới |
| thứ Nguồn Trình Duyệt tìm thấy | **dấu vết vào phòng** | "đã join", "trạng thái" | nó là **dấu vết trong N phút qua**, không phải trạng thái lúc này. Nói sai chỗ này là quay lại đúng lỗi Đ5 |
| kết luận của cổng | **trùng phòng** / **không trùng** | "detect", "present", "hiện diện" | Quyết định B đòi khớp **danh tính**. Từ "hiện diện" là đúng cái bẫy Đ5 đã bắt được |
| hành vi khi trùng | **bỏ qua im lặng** | "chặn", "block", "suppress" | "chặn" gợi app đang ngăn người dùng — nó không ngăn ai, nó không làm gì cả |
| mã `xxx-xxxx-xxx` / meeting ID | **mã phòng** | "room code", "meeting ID" | một từ cho mọi nền tảng |
| một lần bỏ qua, ghi lại | **mục bỏ qua** | "log entry" | |

**Cấm trong mọi chuỗi người dùng đọc:** *theo dõi · giám sát · phát hiện · quét · thu thập*.
Dùng: *nhìn thấy · biết · nhận ra*. App này đã xin một quyền nghe như spyware; không được dùng thêm
từ vựng của spyware.

### "Tầng 1 / Tầng 2" là tên dở, và đổi bây giờ rẻ hơn đổi sau S3

| | |
|---|---|
| **Hỏng ở đâu** | "Tầng" ngụ ý **thứ bậc và chồng lên nhau**. Thực tế hai thứ này **độc lập**, phục vụ hai loại nền tảng khác nhau, không cái nào đứng trên cái nào |
| **Hậu quả cụ thể** | "Tầng 2" đọc như *"tầng cao hơn, tầng nâng cao, tầng phải làm cho xong"*. Số đo nói ngược: nó mua về **2/73 cuộc họp**, và **không kiểm thử được** (Zoom 0 cuộc, Teams/Webex chưa cài). Một cái tên sẽ lặng lẽ kéo công sức của S3 về đúng chỗ ít giá trị nhất |
| **Tên thay** | **Nguồn Trình Duyệt** · **Nguồn Cửa Sổ** — gọi theo **cơ chế**, nên tự giải thích, và không hàm ý cái nào hơn cái nào |
| **Giá đổi hôm nay** | 1 dòng có ngày trong `PIPELINE.md` + sửa 3 artifact. ~10 phút. Theo Quy tắc 14: **thêm dòng mới, không sửa tại chỗ** các dòng log cũ |
| **Giá đổi sau S3** | tên biến, tên file, tên commit, `SLICE-LOG.md`. Không ai làm nữa ⇒ xưởng sống chung với một cái tên nói sai |

Giữ `(cũ: Tầng 1 / Tầng 2)` trong ngoặc ở bảng từ vựng qua hết S2, để artifact cũ còn đọc được.

---

## 5. Một dòng attribution Apache-2.0 §4(b) — phần CHỮ, không phải phần pháp lý

Pháp lý thuộc phòng Legal. Tôi chỉ đưa chuỗi, vì nó là copy người dùng đọc, nằm trong cửa sổ About:

> Dựa trên MeetingBar · Copyright © Andrii Leitsius và các contributor của MeetingBar ·
> Apache License 2.0 · Bản này đã được sửa đổi. Danh sách file đã sửa: `MODIFICATIONS.md`.

Đã kiểm trên đĩa: header source ghi `Copyright © 2020 Andrii Leitsius. All rights reserved.`
(`MeetingBar/UI/StatusBar/StatusBarItemController.swift:5-6`); 44 file có dòng `Created by`, và
**có contributor khác** (`0bmxa`, `.all-contributorsrc`) ⇒ nên viết *"và các contributor"*, không
chỉ một tên. Repo **không có file NOTICE** (`ls NOTICE*` → không có).

---

## 6. CHƯA XÁC MINH ĐƯỢC

| # | Chưa biết | Vì sao chưa | Gỡ bằng | Tốn |
|---|---|---|---|---|
| 1 | **Chuỗi chính xác macOS hiển thị** trong hộp thoại Accessibility | grep `/System/Library/PrivateFrameworks/` không ra — chuỗi nằm trong dyld shared cache / `.loctable`, không phải file rời | **Tôi cố ý KHÔNG trích dẫn câu đó.** Chụp màn hình lúc build thử | S3 |
| 2 | `NSAccessibilityUsageDescription` có **tiến trình nào khác** đọc không | Tôi chứng minh được `tccd` không biết nó. Tôi **không** chứng minh được không ai khác đọc | Build thử: đặt chuỗi dễ nhận, gọi `AXIsProcessTrustedWithOptions`, xem dialog | ~20 phút, S3 |
| 3 | Trùng tên ngoài tầm với | Phương pháp chỉ có: `ls /Applications` + WebSearch. Không tra Mac App Store theo cách máy đọc được, không tra USPTO, không tra Homebrew cask | — | — |
| 4 | Tên tiếng Việt nghe thế nào khi **đọc thành tiếng** | Chưa ai ngoài tôi đọc. Và gu là của Duy (Quy tắc 6) | Duy đọc to 3 ứng viên | 1 phút |
| 5 | `os_log` mức `.info` có bị prune khỏi store không | chưa đo | nếu chọn PA (b) ở §3: dùng `.notice`, rồi `log show --last 7d` kiểm bằng mắt ở S4 | S4 |
| 6 | Tiêu đề cửa sổ Zoom **khi đang họp** có mang meeting ID không | kế thừa từ S0 — Duy có 0 cuộc Zoom/30 ngày | cuộc Zoom thật | S2 |

**Theo `../../../docs/lessons.md`: "không tìm thấy" ở #3 nghĩa là *phương pháp này không tìm thấy*, không
bao giờ là *không tồn tại*.** Với bản phát cho 5 người không bán, rủi ro trùng tên là rủi ro bối
rối, không phải rủi ro pháp lý — nhưng đó là đánh giá của tôi, và Legal mới chốt được.

---

## 7. BỐN CÂU CHO DUY — hỏi từng câu một, theo đúng thứ tự này

Thứ tự có lý do, nói ra để Duy bác được: **Q1** không phụ thuộc gì và có hạn chót cứng (trước S3).
**Q2** là quyết định sản phẩm, độc lập với tên. **Q3** là gu, và **Q4 phải đi sau Q3** vì chuỗi
microcopy có tên app nằm trong đó — hỏi ngược là bắt Duy duyệt một câu còn chỗ trống.

Chi tiết từng câu nằm ở mục `phaiQuyet` của báo cáo này.
