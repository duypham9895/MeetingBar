---
stage: 01-spec
owner: PM (gộp bốn phòng: PM · Data · Legal · Writer)
freshness: 2026-10-13
status: draft — CHƯA được Duy duyệt
reviewer: same vendor, same priors — no external verifier ran
---

# PRD — presence-gate

> **§A QUYẾT ĐỊNH — Duy đọc, ~7 phút.** §B là THAM CHIẾU cho S3, Duy không cần mở.
> Sáu câu hỏi cho Duy nằm ở `DECISIONS-PENDING` (hỏi từng câu một, không gộp).
> Ba bất đồng giữa các phòng **không được ép đồng thuận** — ghi nguyên ở §A5.

---

## TL;DR — sáu dòng

| | |
|---|---|
| **Ba sự thật S0 đã bị bác bằng đo lại tại chỗ** | app đang chạy **trong App Sandbox** (⇒ không đọc nổi lịch sử trình duyệt) · điểm chèn S0 chỉ định **bị đi vòng** ở đúng ca thường gặp · phép đo "0 quyền · 0 dialog" **không hợp lệ** (tiến trình đo có Full Disk Access) |
| **Lợi ích thật của cổng, đã backtest** | **1–3 cuộc / 30 ngày**, không phải 97%. 97% là tỉ lệ cuộc họp dùng Meet, không phải tỉ lệ cổng bắt được |
| **Đau thật nằm ở chỗ khác** | bắn trùng trong vòng 60 giây (PM đo 15/59 sự kiện có ≥2 lượt vào) — cổng bắt được chỗ này với mọi W ≥ 300s |
| **Nguồn Cửa Sổ (cũ: Tầng 2) hiện KHÔNG có đường thoả Quyết định B** | nút Leave chỉ chứng minh "đang ở trong MỘT cuộc", B đòi "đúng CUỘC NÀY". Mắt xích là meeting ID trong tiêu đề cửa sổ Zoom — **chưa ai đo** |
| **Legal CHẶN 3 thứ vào S3 và 3 thứ vào lúc phát file** | phạm vi đã đổi theo: thêm **Lát 0** và một **Cổng Phát File** riêng |
| **Trạng thái** | **không duyệt được cho tới khi 6 câu ở `DECISIONS-PENDING` có trả lời.** Duy duyệt, không phòng nào duyệt |

---

# §A — QUYẾT ĐỊNH

## A1. Ba đính chính bắt buộc với khối "SỰ THẬT ĐÃ ĐO" của S0

Khối đó mang nhãn *"không nghiên cứu lại, không nghi ngờ"*. Ba dòng trong đó **sai**, và để nguyên là bảo mọi phòng sau đừng kiểm thứ đã biết là sai. PM tự chạy lệnh kiểm lại cả ba hôm nay.

| # | S0 ghi | Sự thật đo được | Hệ quả |
|---|---|---|---|
| **Đ-1** | *(không nhắc tới sandbox)* | `MeetingBar/MeetingBar.entitlements` có `com.apple.security.app-sandbox = true`, gắn ở `project.pbxproj:453` và `:483`. **App sandbox không đọc được `~/Library/Application Support/Vivaldi/` bằng bất kỳ cách nào** — chặn ở tầng container của kernel, không phải TCC | Quyết định A (bỏ sandbox) đã cho phép gỡ, nhưng **chưa lát nào lên lịch việc gỡ**. ⇒ vào **Lát 0** |
| **Đ-2** | chèn cổng ở `NotificationActionRunner.swift:162` `shouldConsiderActionEvent` | Có **hai** đường tới `fireAction:74`. Đường 1: `fireDueActions:37` → có qua 162. Đường 2: `fire:65` (gọi từ `NotificationScheduler.swift:212`, Task ngủ tới giờ bắn) → **gọi thẳng `fireAction`, KHÔNG qua 162**. Đường 2 chính là đường auto-join T-180s | chèn ở 162 ⇒ **cổng bị đi vòng trong đúng ca phổ biến nhất**, và sẽ "chạy đúng" trong test vì test hay đi đường 1. Điểm chèn đúng ở §B2 |
| **Đ-3** | *"Lịch sử Vivaldi … **KHÔNG prompt TCC nào**"* · *"Tầng 1 — 0 quyền · 0 dialog"* | **Phép đo không hợp lệ.** Hai phòng độc lập tìm ra cùng một nguyên nhân: Legal đọc được `/Library/.../com.apple.TCC/TCC.db` và thấy `node` có `kTCCServiceSystemPolicyAllFiles auth_value=2`; T3 đọc được `~/Library/Safari/History.db` và truy cây tiến trình về `iTermServer`. **Tiến trình đo đã có Full Disk Access** | viết lại thành: *"nhiều khả năng 0 quyền trên macOS 26, theo Apple Developer Forums #847030 — nguồn bên thứ ba, không phải phép đo của ta. Apple DTS xác nhận macOS 27 chặn, và **chặn IM LẶNG**."* ⇒ **Lát 0 phải đo lại trên tiến trình sạch** (Legal CL-1) |

**Đ-1 là thứ nặng nhất và nó không nằm trong 9 hàng "chưa xác minh được" của bất kỳ phòng nào.** Nếu không gỡ sandbox thì Nguồn Trình Duyệt không chạy, và ba con số lịch sử (127 / 94 / 65) đều vô nghĩa.

## A2. Lợi ích thật — nói thẳng trước khi Duy duyệt một tháng công việc

Hai phòng backtest độc lập, hai phương pháp khác nhau, **kết luận trùng nhau**:

| Phòng | Phương pháp | Kết quả |
|---|---|---|
| Data | replay 71 cuộc Meet, lead=180s, W=5/15/30 phút | **1 cuộc bị im / 30 ngày** — cùng một con số cho cả ba W |
| PM | nối lịch với lịch sử, 59 cuộc khớp được | lượt vào **sớm nhất** của mỗi cuộc: p25=169s · median=171s · p75=176s. **Duy mở phòng sớm thật chỉ 3/59 lần** |

Khoảng tứ phân vị **7 giây** trên 59 cuộc không phải hành vi con người — đó là **auto-join của chính MeetingBar** (`automaticEventJoinTime=180`). Tức là: *"Duy vào phòng sớm nên đừng nhắc"* **không phải nguồn đau**.

```
   97%  =  tỉ lệ cuộc họp của Duy dùng Google Meet  (71/73 cuộc CÓ GIỜ)
           ── một thuộc tính của LỊCH, không phải một phép đo về CỔNG

   1–3 cuộc / 30 ngày  =  cái cổng thật sự gỡ được
```

**Mọi chỗ trong artifact của các phòng dùng 97% như "tỉ lệ cổng bắt được" đều bị đính chính bằng dòng này.** (Đây là câu trả lời cho T2 của phòng Data gửi Legal, câu 1.)

**Nguồn đau còn lại, và nó có thật:** bắn trùng. Khoá chống-bắn-trùng của MeetingBar là cặp `(event.id, lastModifiedDate)` (`EventActionPolicy.swift:79-82`) ⇒ organizer sửa event một chữ là khoá reset và nó bắn lại. PM đo: **15/59 cuộc có ≥2 lượt vào cùng phòng**, **10/23 cặp liên tiếp cách nhau <60 giây**. Data đo hẹp hơn (chỉ trong cửa sổ bắn): **6/71**. Hai con số không mâu thuẫn — hai cửa sổ khác nhau. Cả hai đều bị cổng bắt với **mọi W ≥ 300s**.

**Cái cổng này đáng làm vì nó gỡ bắn trùng, không vì nó gỡ "Duy vào sớm".** Nếu Duy đọc tới đây và thấy 1–3 cuộc/tháng không đáng một tháng công, đó là một kết luận hợp lệ và PM không giấu nó đi.

## A3. Luật của cổng — tất định, một dòng

```
   IM LẶNG  ⇔  có ÍT NHẤT MỘT nguồn nói "đã vào"  VÀ  KHÔNG nguồn nào nói "chưa vào"
   mọi trường hợp còn lại  ⇒  MỞ (hành xử y hệt MeetingBar gốc)
```

Mỗi nguồn trả **ba** giá trị, không bao giờ hai: `present` · `absent` · `unknown`. Phần lớn lỗi thiết kế ở đây đến từ việc nhét *"tôi không có thẩm quyền"* chung ô với *"tôi khẳng định là chưa"*.

| Tình huống | Nguồn Trình Duyệt | Nguồn Cửa Sổ | Kết |
|---|---|---|---|
| Meet mở trong Vivaldi | `present` | `unknown` (không phải app native) | **im** |
| Không thấy lượt vào nào | `unknown` | `unknown` | **mở** |
| Zoom trong app native, khớp meeting ID | `unknown` | `present` | **im** |
| Zoom mở trong trình duyệt, app native không trong cuộc | `present` | `absent` | **mở** — bất đồng thật ⇒ thua về phía an toàn |
| Quyền Accessibility bị từ chối | theo nguồn kia | `unknown` **vĩnh viễn** | theo nguồn kia · âm thầm (Quyết định D-1) |
| Probe lỗi / quá 150ms / DB khoá | `unknown` | `unknown` | **mở** |
| **Không ĐỌC ĐƯỢC file lịch sử** (macOS 27, FDA bị rút) | `unknown` | — | **mở · + báo cho người dùng MỘT lần, NHÌN THẤY ĐƯỢC** |

Ba ràng buộc cứng, không thương lượng:

1. **Nguồn Trình Duyệt KHÔNG BAO GIỜ được trả `absent`.** Lịch sử chứng minh được *có vào*, không chứng minh được *không vào*: một tab mở từ 2 tiếng trước trông giống hệt một tab đã đóng.
2. **Thất bại là MỞ.** Mọi exception, timeout, DB khoá, regex trượt ⇒ `unknown` ⇒ mở. **Không có nhánh code nào im lặng vì lỗi.** (Ràng buộc này do bất đối xứng FP/FN đặt ra, không phải do ai chọn: mở thừa = một cái tab, thấy ngay, đóng trong 1 giây; im nhầm = lỡ họp, không ai thấy, không đảo ngược được.)
3. **`khôngĐọcĐược` ≠ `khôngTìmThấy`** (Legal CL-2). macOS 27 chặn thao tác này và chặn **im lặng** — Apple DTS xác nhận. Nếu hai thứ đó trả cùng một giá trị thì ngày tính năng chết, nó trông y hệt ngày nó chạy đúng. Nhánh `khôngĐọcĐược` **phải nhìn thấy được**, đúng một lần.

## A4. Phạm vi — đã đổi theo ba cổng chặn của Legal

**LÀM**

- Một guard duy nhất ở `fireAction:74`, gác **`.autoJoin` và `.fullscreen`**.
- Khớp **danh tính** cuộc họp (mã phòng) **và** thời điểm, không phải hiện diện chung chung.
- Đọc `urls.url` + `visits.visit_time` từ Chromium-family. Hết.

**KHÔNG LÀM**

| Không làm gì | Vì sao |
|---|---|
| Không gác `.scriptOnStart` | script là chỉ thị tường minh của người dùng; nuốt nó trong im lặng là thứ không ai chẩn đoán được |
| Không đọc Safari | đòi Full Disk Access ⇒ vi phạm thẳng Quyết định C. Và đo được: **0 lượt Meet / 30 ngày** trên 102.522 lượt duyệt web |
| Không đọc nội dung trang, `urls.title`, cookie, form | tiêu đề trang *là* nội dung (*"Quarterly layoffs — Google Docs"*). Mã phòng thì không |
| Không gửi gì ra mạng | giữ nguyên đúng **2** chỗ gọi `URLSession` của bản gốc, cả hai là Google Calendar sync |
| Không thêm dependency bên thứ ba | SQLite3 và ApplicationServices có sẵn trong hệ |
| Không sửa `EventActionPolicy` | giữ nguyên semantics dedup, kể cả cái tật reset theo `lastModifiedDate` |
| **Không copy file History ra tmp** | copy = tạo **bản sao thứ hai của toàn bộ lịch sử duyệt web** trên đĩa. Dùng `mode=ro&immutable=1`. Đánh đổi: có thể đọc lỡ dở ⇒ `unknown` ⇒ mở — hỏng về phía an toàn |

**BA THỨ MỚI, do Legal chặn (CL-1…CL-6). Phạm vi đổi, không phải ghi chú rồi đi tiếp:**

- **Lát 0** — gỡ sandbox + đo lại TCC trên tiến trình sạch + chọn tên. Không viết dòng code tính năng nào trước khi Lát 0 xong.
- **Cổng Phát File** — một cổng riêng sau Lát 5, gồm CL-4 (gỡ patronage + mailto), CL-5 (đổi tên theo bảng, **giữ** `NSHumanReadableCopyright`, `LICENSE` nằm **trong** bundle), CL-6 (gửi câu thông báo trước khi đưa file). **Không file .app nào rời máy Duy trước khi cổng này xong** — điều kiện này phải nằm trong artifact, không nằm trong ý định.
- **Soi ToS trước Lát 5** — `LEGAL-SCREEN.md` §2 ghi ToS của Zoom/Microsoft/Google về việc đọc cây AX là *"phải soi trước S3"* và điều kiện đó **vẫn đang mở**. Lát 4 và Lát 5 lên lịch đúng hành vi đó.

## A5. ⚠️ BA BẤT ĐỒNG — không ép đồng thuận, không gọi trọng tài

Theo Quy tắc 12: hai phiên cùng gốc bất đồng là **tín hiệu spec chưa rõ**, không phải tỉ số. Ghi cả hai lập luận, leo thẳng lên Duy.

### B-1 · Cửa sổ "đã vào" W: 300 hay 600 hay 900 giây

| | |
|---|---|
| **PM nói 600s** | W=600 bắt trọn toàn bộ phần đau đo được (10/10 cặp bắn-trùng <60s). Nâng lên 7.200s chỉ mua thêm 2 lần im-đúng/30 ngày, đổi bằng nhân 12 lần cửa sổ lỡ họp. Trần cứng đo được: lần vào phòng gần nhất *trước đó* không thuộc cuộc này là **1,95 giờ** |
| **Data nói 900s** | G2 đặt trần W ≤ ¼ khoảng tái dùng mã phòng nhỏ nhất (1440 phút ⇒ ≤360 phút); 15 phút nằm sâu dưới trần |
| **Chính Data tự bác mình ở T2** | bảng của Data: W=5p → 1 sự kiện · W=15p → **1** · W=30p → 1. **W=900 không mua thêm một cuộc nào so với W=300.** Và §3 của Data đặt luật FP=0 tuyệt đối / FN miễn phí ⇒ theo đúng luật đó, W phải là **giá trị nhỏ nhất còn giữ nguyên sản lượng**, tức 300 |
| **Câu spec chưa ai trả lời** | **"Đã vào" nghĩa là một TAB CÒN MỞ, hay một LẦN MỞ TAB?** Lịch sử trình duyệt chỉ ghi lần mở. Không câu nào trong S0 hay ONE-PAGER định nghĩa điều này, và W là hệ quả trực tiếp của nó. Nếu nghĩa là "tab còn mở" thì lịch sử trình duyệt là **sai công cụ** và W bao nhiêu cũng không cứu được |

### B-2 · Log: mã phòng ghi NGUYÊN hay HASH

| | |
|---|---|
| **Data nói ghi nguyên** | hash không thêm quyền riêng tư nào — **chính lịch sử Vivaldi trên cùng ổ đĩa đó đã có mã phòng ở dạng rõ**. Hash chỉ làm việc debug bất khả thi. Cái bảo vệ ở đây là *file không bao giờ rời máy*, không phải mã hoá |
| **Legal nói hash** | link Meet là **bearer credential** — ai cầm link đều có đường vào. Và log chạy trên **máy đồng nghiệp**, chứa link họp của **công ty họ**, không phải của Duy. `~/Library/Logs/` bị gom nguyên vào `sysdiagnose`, Time Machine và bundle crash-report — tức nó rời máy theo những đường không ai cố ý |
| **Chỗ hai phòng nói lệch nhau mà chưa ai thấy** | Data đã chọn `~/Library/Application Support/<App>/` **chính vì** chưa kiểm được `sysdiagnose` có quét `~/Library/Logs` không. PM thì viết `~/Library/Logs/` ở A6. Ba đường dẫn, ba phòng |
| **Câu spec chưa ai trả lời** | **Log này là dữ liệu của AI khi app chạy trên máy đồng nghiệp, và nó có được phép rời máy đó không?** S0 chỉ nói "không gửi gì ra mạng". Nó không nói gì về việc một file nằm yên trên đĩa bị công cụ của hệ điều hành gom đi |

### B-3 · Thứ tự Nguồn Cửa Sổ (cũ: Tầng 2) — làm ngay hay làm sau

Quyết định D (*"làm cả hai tầng"*) **không mở lại**. Bất đồng là về **thứ tự**, và ba phòng không nói cùng một thứ:

| | |
|---|---|
| **PM nói làm, có cổng** | Lát 4 (đo tiêu đề cửa sổ Zoom, 15 phút) là điều kiện tiên quyết cứng của Lát 5. Đo ra "không có meeting ID" ⇒ **DỪNG, leo lên Duy**, tuyệt đối không tự hạ chuẩn xuống "chỉ hiện diện" |
| **Data nói hoãn-có-điều-kiện** | Nguồn Cửa Sổ mua về **0 cuộc trên dữ liệu 30 ngày**: Zoom cài nhưng 0 cuộc; Teams và Webex (2 cuộc duy nhất) **không cài**. Đổi lại nó đòi một toggle Accessibility và bảo trì vĩnh viễn |
| **Legal nói thu hẹp rồi hoãn** | bỏ Teams và Webex (xoá luôn câu hỏi ToS của Microsoft), còn lại chỉ Zoom; hoãn tới sau khi Nguồn Trình Duyệt chạy thật một tuần — lúc đó mới có dữ liệu Zoom thật để đo |
| **Writer bồi thêm một tầng nữa** | Nguồn Cửa Sổ hiện **chỉ sản xuất được "hiện diện"**, mà chính bảng từ vựng cấm từ đó. Nút Leave chứng minh *"đang trong MỘT cuộc"*; Quyết định B đòi *"đúng CUỘC NÀY"*. ⇒ cho tới khi Lát 4 đo xong, nhánh này mua về **0**, không phải 2/73 |
| **Câu spec chưa ai trả lời** | **Quyết định D ràng buộc PHẠM VI CUỐI CÙNG, hay ràng buộc cả THỨ TỰ và THỜI ĐIỂM?** Nếu chỉ phạm vi thì ba phòng không bác D, họ chỉ xếp lại lịch. Nếu cả thứ tự thì PM đúng và hai phòng kia đang bác một quyết định đã chốt |

## A6. Trả lời các câu T2 mà phòng sở hữu CHƯA trả lời

Im lặng = chưa xong. Chỗ nào bằng chứng ép ra một câu trả lời thì PM trả lời ở đây; chỗ nào là phán đoán của phòng sở hữu thì ghi rõ **chưa trả lời được**.

| T2 hỏi gì | Trạng thái |
|---|---|
| **Legal → PM:** `evidence` trong log là URL nguyên văn hay hash? | **CHƯA TRẢ LỜI ĐƯỢC** — đây là bất đồng B-2, leo lên Duy |
| **Legal → PM:** B5 không có lát nào sinh nghĩa vụ Apache §4(a)(b)(c) và §6 | **ĐÃ TRẢ LỜI, phạm vi đã đổi.** §4(b) header + `LICENSE` trong bundle vào **Lát 1** (lát đầu tiên đẻ ra một .app chạy được = một .app có thể bị đưa cho ai đó). §6 đổi tên vào **Lát 0**, vì đường dẫn log và nhãn menu bar đều mang tên. Cổng Phát File là nơi kiểm lại toàn bộ |
| **PM → Data:** G1 đang chấm ĐẠT bằng phép đo không sinh ra được con số đó | **ĐÃ TRẢ LỜI — bằng chứng ép ra câu trả lời.** Replay không phân biệt được im-đúng với im-nhầm: lịch sử chỉ biết *một tab đã mở*, không biết *Duy có trong phòng*. ⇒ **G1 đổi từ ĐẠT thành CHƯA ĐO ĐƯỢC**, mẫu là **0/0** chứ không phải 0/1, và rule-of-three không áp dụng được. G1 chỉ đạt sau khi Duy dán nhãn tay sự kiện `09-14 16:30 · iat-dpyb-uvb` (2 phút, §A7) |
| **PM → Data:** W=900 không mua thêm gì so với W=300 | **CHƯA TRẢ LỜI ĐƯỢC** — bất đồng B-1 |
| **Data → Legal:** 97% là tỉ lệ loại link, không phải tỉ lệ cổng bắt được | **ĐÃ TRẢ LỜI** ở §A2. Hai backtest độc lập hội tụ ở 1–3 cuộc/30 ngày. Mọi chỗ dùng 97% như yield của cổng bị đính chính |
| **Data → Legal:** cho phép một bộ đếm cục bộ KHÔNG định danh? | **CHƯA TRẢ LỜI ĐƯỢC** — cùng cụm với B-2 |
| **PM → Writer:** "tên app là microcopy" dựa trên một hộp thoại chưa ai đo | **ĐÃ TRẢ LỜI, và nó gỡ được cả hai phía.** Writer đúng rằng tiêu chí đó chưa có bằng chứng ⇒ **hạ xuống tiêu chí phụ**. Nhưng Writer đề nghị dời câu hỏi tên xuống sau phép thử 20 phút, còn Legal cần tên **trước Lát 1**. Cả hai thoả được, vì chi phí một chiều của tên chỉ phát sinh **lúc phát file**, mà Cổng Phát File nằm sau Lát 5: **chọn tên bây giờ, đổi miễn phí tới tận lúc phát**. Phép thử AX 20 phút chạy ở Lát 5 |
| **PM → Writer:** Nguồn Cửa Sổ chỉ đạt "hiện diện", không đạt "danh tính" | **ĐÃ TRẢ LỜI, và nó nâng mức nghiêm trọng.** PM, Legal và Writer nói cùng một điều. ⇒ nếu Nguồn Cửa Sổ chỉ biết "đang trong một cuộc" thì cổng **KHÔNG được im**, và nhánh này mua về **0 cuộc** cho tới khi Lát 4 đo xong. Mục chưa-xác-minh #6 nâng từ "kế thừa S0" lên **CHẶN Nguồn Cửa Sổ** |
| **Writer → cả xưởng:** đổi "Tầng 1/Tầng 2" thành "Nguồn Trình Duyệt/Nguồn Cửa Sổ" | **PM ÁP DỤNG, 2026-10-13.** Không phải quyết định gu nên không đẩy lên Duy. Lý do giữ nguyên lập luận của Writer: chữ "Tầng" ngụ ý thứ bậc, và "Tầng 2" đọc như *tầng phải làm cho xong* trong khi nó mua về 0–2 cuộc. Giữ `(cũ: Tầng 1 / Tầng 2)` trong ngoặc qua hết S2 |

## A7. Việc chỉ Duy làm được — không agent nào thay (Quy tắc 6)

| Việc | Vì sao không tự động được | Tốn |
|---|---|---|
| Trả lời 6 câu ở `DECISIONS-PENDING` | mức chịu rủi ro, gu, và thứ tự ưu tiên | ~20 phút, rải ra |
| **Dán nhãn tay 1 sự kiện duy nhất cổng sẽ im** — `09-14 16:30 · iat-dpyb-uvb · "Product Team Daily Checkpoint"`: hôm đó anh có thật sự đang ở trong cuộc lúc 16:27 không? | lịch sử chỉ biết *một tab đã mở*. **Đây là thứ duy nhất làm G1 đạt được** | 2 phút |
| Sửa `ONE-PAGER.md` §4 — hiện ghi *"không có instrumentation và cố ý không có"*, mâu thuẫn trực tiếp với log cục bộ | **Duy sở hữu ONE-PAGER** (Quy tắc 11). Thêm một dòng CÓ NGÀY, không sửa tại chỗ | 2 phút |
| Chọn **tên sản phẩm** | gu, và nó chặn Lát 0 | 2 phút |
| Dựng **một cuộc Zoom thử 15 phút** (Lát 4) | không có cuộc Zoom thật thì không đo được. Duy có 0 cuộc Zoom/30 ngày | 15 phút |
| Đọc log sau 14 ngày: *"có lần nào tôi lỡ họp mà không hiểu vì sao không?"* | chỉ Duy biết mình đã lỡ cuộc nào | 10 phút |
| Duyệt riêng, ghi thành chữ, việc **phát file** cho từng người | review ≠ approve. Không model nào làm việc này | — |

## A8. Lát cắt — đã sửa theo ba cổng chặn

| Lát | Nội dung | Chặn bởi | Kiểm bằng mắt |
|---|---|---|---|
| **0** | **Gỡ `com.apple.security.app-sandbox`** · đo lại TCC trên **tiến trình sạch** (build .app chưa ký, chạy **từ Finder**, không từ terminal — terminal kế thừa FDA) · chốt tên + bundle id | Q1 (tên) · Legal CL-1 | một trang ở `gates/01-spec/TCC-CLEAN-MEASURE.md`: đọc được History hay không, có dialog hay không, **kèm ảnh chụp**. Đọc không được ⇒ **DỪNG, leo lên Duy** — toàn bộ Nguồn Trình Duyệt phụ thuộc vào đây |
| **1** | **Cổng GIẢ luôn trả `.present`**, chèn ở `fireAction:74`. Công tắc menu bar · nhật ký · §4(b) header · `LICENSE` vào bundle. **Không SQLite, không AX** | Lát 0 · Q3 · Q4 | event Meet cách 4 phút ⇒ **không tab nào mở**. Lật stub sang `.unknown` ⇒ tab mở. Bấm công tắc ⇒ tab mở lại. **Và: cổng phải được hỏi trên CẢ HAI đường bắn** (§B2) |
| **2** | `BrowserHistoryProbe` thật, **chỉ Vivaldi**, W theo Q2. Mục `Mở ngay` | Q2 | mở phòng tay → tạo event → **im**. Phòng chưa từng vào → tab mở. Đối chiếu nhật ký với `visit_time` thật trong DB |
| **3** | Thêm Chrome (quét profile động) + Brave | — | mở phòng **trong Brave** → **im** |
| **4** | **Phép đo, không phải code.** Cuộc Zoom thật, dump AX, ghi tiêu đề cửa sổ lúc đang họp. **+ soi ToS AX** (`LEGAL-SCREEN` §2) | Q5 · 15 phút của Duy | một trang: tiêu đề có meeting ID hay không. **Không có ⇒ DỪNG, leo lên Duy.** Không tự hạ chuẩn xuống "chỉ hiện diện" |
| **5** | `AccessibilityProbe` + xin quyền một lần + lùi êm. Cửa sổ microcopy **trước** `AXIsProcessTrustedWithOptions` | Lát 4 cho đèn xanh | vào cuộc Zoom → **im**. Rút quyền → Nguồn Trình Duyệt vẫn chạy, **không dialog nào hiện** |
| **6** | Xoá `AccessibilityProbe.swift` khỏi target, build lại | — | build xanh, Lát 2 vẫn đạt. Rồi khôi phục |
| **PHÁT** | **Cổng Phát File** — CL-4 · CL-5 · CL-6 · **Duy duyệt riêng, ghi thành chữ** | tất cả | checklist ở `ACCEPTANCE.md` §G. **Không .app nào rời máy Duy trước cổng này** |

Lát 1 và Lát 2 đã cover toàn bộ phần đau đo được. Lát 3–6 là Quyết định D.

## A9. Chưa xác minh được — §A

| # | Chưa biết | Ảnh hưởng | Đo ở đâu |
|---|---|---|---|
| 1 | **Gỡ sandbox rồi thì app chưa ký có mở được trên máy đồng nghiệp không** (Gatekeeper / quarantine / notarization). **Không phòng nào nêu, PM nêu ở đây** | có thể chặn toàn bộ Quyết định A | Lát 0 + Cổng Phát File |
| 2 | **Tiêu đề cửa sổ Zoom lúc ĐANG họp có mang meeting ID không.** Idle là `"Zoom Workplace"` | **CHẶN toàn bộ Nguồn Cửa Sổ** — không có nó thì nhánh này không thoả nổi Quyết định B | Lát 4 |
| 3 | Trên macOS 27, Full Disk Access có cứu được Nguồn Trình Duyệt không. **Hai nguồn mâu thuẫn, một trong hai là Apple**: người hỏi nói *"resolves the issue completely"*, Apple DTS nói *"I'm not sure"* | hạn dùng của 97% nhánh | chỉ đo được khi lên macOS 27 |
| 4 | `kTCCServiceSystemPolicyAppData` có phủ `~/Library/Application Support/Vivaldi/` không | quyết định Nguồn Trình Duyệt có dialog hay không | Lát 0 |
| 5 | **Lead time MẶC ĐỊNH là `.atStart = 5 giây`**, không phải 180s. Cấu hình 180s là của riêng máy Duy. Với đồng nghiệp, cửa sổ bắn mặc định chỉ rộng **20 giây** `[T-5s, T+15s)` | ngân sách 150ms của probe tính trên 300s trông rộng rãi hơn thực tế **15 lần** | Lát 1, log thời gian probe |
| 6 | Độ trễ Chromium ghi `visits` xuống đĩa | bỏ sót ⇒ mở tab thừa. Hỏng về phía an toàn, nhưng ăn mất bao nhiêu của W thì chưa biết | Lát 2 |
| 7 | `immutable=1` lúc trình duyệt **đang ghi mạnh**. Hai phòng đã đo lúc tải nhẹ và ra đúng số; chưa ai đo lúc nặng | đọc ra rác ⇒ `unknown` ⇒ mở. An toàn, nhưng chưa đo | S4 |
| 8 | **Teams và Webex không cài.** Nguồn Cửa Sổ cho hai dịch vụ này hoàn toàn chưa kiểm và không kiểm được nếu không cài | 2/73 cuộc | không đo được. **Ghi nhãn, đừng giả vờ đã kiểm** |
| 9 | ToS hiện hành của Zoom về việc đọc cây AX. Chỉ mở được bản mirror + một nguồn thứ cấp. **Không tìm thấy điều khoản nào về accessibility** — nhưng "không tìm thấy" nghĩa là *phương pháp này không tìm thấy* | Lát 5 | trước Lát 5 |
| 10 | Chuỗi chính xác macOS hiển thị trong hộp thoại Accessibility. **Cố ý KHÔNG trích dẫn** vì chưa ai nhìn thấy | microcopy Lát 5 | ảnh chụp ở Lát 5 |
| 11 | Khi phát cho đồng nghiệp, log nằm trên máy họ và **cố ý không gom lại được**. Cổng ship G3 chỉ xác minh được trên máy Duy | G3 | — |

---
---

# §B — THAM CHIẾU (S3 đọc, Duy không cần)

## B1. Từ vựng — hợp đồng từ S1 tới S6

| Khái niệm | Dùng | Không dùng |
|---|---|---|
| tên dự án · repo · nhánh · `gates/` | `presence-gate` | — (tên KỸ THUẬT, người dùng không bao giờ thấy) |
| tên app phát cho đồng nghiệp | **Duy quyết (Q1)** | `MeetingBar` — Apache-2.0 §6 |
| bundle identifier | `dev.duypham.<ascii>` hoặc `com.duypham.<ascii>` | `leits.MeetingBar` — mang namespace của người khác |
| nguồn bằng chứng từ lịch sử trình duyệt | **Nguồn Trình Duyệt** *(cũ: Tầng 1)* | ~~Tầng 1~~ |
| nguồn bằng chứng từ cây AX app native | **Nguồn Cửa Sổ** *(cũ: Tầng 2)* | ~~Tầng 2~~ |
| thứ Nguồn Trình Duyệt tìm thấy | **dấu vết vào phòng** | "đã join", "trạng thái" — nó là dấu vết trong N phút qua, không phải trạng thái lúc này |
| kết luận của cổng | **trùng phòng / không trùng** | "detect", "present", "hiện diện" |
| hành vi khi trùng | **bỏ qua im lặng** | "chặn", "block" — app không ngăn ai, nó không làm gì cả |
| mã `xxx-xxxx-xxx` / meeting ID | **mã phòng** | "room code", "meeting ID" |

**Cấm trong mọi chuỗi người dùng đọc:** *theo dõi · giám sát · phát hiện · quét · thu thập*. Dùng: *nhìn thấy · biết · nhận ra*. App này đã xin một quyền nghe như spyware; không dùng thêm từ vựng của spyware.

## B2. Điểm chèn — đã đọc lại source tại chỗ hôm nay

```
   SAI (S0)      NotificationActionRunner.swift:162  shouldConsiderActionEvent
                 — chỉ được gọi từ fireDueActions:37 (đường polling).
                   fire:65 đi THẲNG vào fireAction và không qua nó.

   ĐÚNG          NotificationActionRunner.swift:74   fireAction(plan:event:action:settings:now:)
                 — phễu DUY NHẤT cả hai đường đều phải qua.
                 Đặt cổng ở NGAY DÒNG ĐẦU, TRƯỚC EventActionPolicy.evaluate (dòng 101).
```

**Vì sao phải trước `evaluate`, không phải ở sink — T3 tìm ra và PM xác nhận lại tại chỗ:**

`fireAction:109-113` — nếu `shouldFireSideEffect` là `true` mà `actionSink?.performNotificationAction(...)` trả về khác `true`, hàm **return sớm và KHÔNG gọi `recordStore.setProcessedRecords`**. Lần tick sau, `evaluate` chạy lại với cùng `lastModifiedDate`, `matched` vẫn nil, nên nó bắn lại — **lặp mỗi tick suốt cả cửa sổ**. Vậy cách cài tự nhiên nhất ("sink trả false khi đã ở trong phòng") đẻ ra một vòng lặp thử lại.

Hai chỗ đặt đúng: **chặn TRƯỚC khi gọi `evaluate`** (chọn cái này), hoặc để cổng trả `true` rồi mới bỏ qua tác dụng phụ.

**Hệ quả cố ý của việc chặn trước `evaluate`:** không có dấu dedup nào được ghi, nên cổng đánh giá lại ở **mỗi tick**, và nếu Duy rời phòng trước `T+15s` thì link vẫn mở. Chặn **không** biến thành chặn vĩnh viễn. Cái giá: nhật ký phải **chống trùng dòng** — ghi một dòng cho mỗi *chuyển trạng thái* `(event.id, decision)`, không phải mỗi tick.

**Ghi kèm, không tự sửa (Karpathy quy tắc 3):** đường `fire:65` cũng đang đi vòng qua cả ba guard sẵn có — `dismissedEventIDs`, `status == .canceled`, `participationStatus == .declined`. Đó là **lỗi của upstream**, không nằm trong phạm vi presence-gate. Nêu vì nó là bằng chứng độc lập rằng đường 2 là đường thật.

**Ràng buộc concurrency:** `fireAction` đang `@MainActor` đồng bộ; probe là I/O. Đường 2 đã nằm trong một `Task` nên `await` được; đường 1 thì chưa. S3 chọn một trong hai hình, **ghi lựa chọn vào `SLICE-LOG.md`**: (a) `fireAction` thành `async`, sửa cả hai call site; hoặc (b) một `PresenceCache` actor làm mới trước `reconcileActions` — **nhưng** đường 2 ngủ hàng phút nên snapshot sẽ cũ. PM nghiêng về (a): không có ô cache nào để mà cũ.

## B3. `EventActionPolicy` — hai cổng độc lập, đừng gộp

T3 chỉ ra S0 ghi khoảng dòng `70-92` như một khối. Đọc lại thì đó là **hai** thứ:

| Dòng | Là gì |
|---|---|
| 70-77 | **cổng thời gian.** `timeInterval = startDate - now`; `lowerBound = allowsRecentlyStarted ? -15.0 : 0.0`; `withinWindow = timeInterval > lowerBound && timeInterval <= actionTime` |
| 79-92 | **cổng idempotence.** tra `processed`, khoá theo `(id, lastModifiedDate)`, cập nhật danh sách |

Ba chi tiết S0 nói không đủ chính xác:

1. **Biên phải MỞ**: điều kiện là `timeInterval > -15.0` (lớn hơn **ngặt**), nên cửa sổ là `[T - actionTime, T + 15s)`, không phải hai biên đóng. Với một cổng chạy theo tick, biên đóng hay mở quyết định có hay không một lần bắn ở đúng mốc `T+15.000s`.
2. **Có một nhánh OR bị bỏ sót**: `guard withinWindow || allDayActive`. `allDayActive = event.isAllDay && startDate <= now && now < endDate` — **không có cửa sổ nào cả**, bắn được bất kỳ lúc nào trong suốt event all-day. Trong 30 ngày của Duy có **25/99 event all-day**. Chúng không có link nên `requiresMeetingLink=true` chặn tác dụng phụ của autoJoin — **nhưng `evaluate` vẫn trả Decision khác nil và vẫn ghi vào `processed`**. Với fullscreen thì `requiresMeetingLink=false`, nên nhánh này **mở thật**.
3. **Lead time mặc định là `.atStart = 5s`** (`Constants.swift:143-148`, bốn giá trị `{5, 60, 180, 300}`). 180s là cấu hình riêng của máy Duy. Trần cứng 300s là do enum chặn.

## B4. Nguồn Trình Duyệt — chi tiết thi công

### Mở file

| Cách | Kết quả |
|---|---|
| `file:…` trần | **LỖI `database is locked`** |
| `file:…?mode=ro` | **VẪN LỖI** — và T3 đo được là lỗi **ngay cả khi Vivaldi KHÔNG chạy**: còn `History-journal` 8,5 KB và `pragma journal_mode = delete`, nên SQLite phải lấy write-lock để roll back journal kể cả ở chế độ ro |
| `file:…?mode=ro&immutable=1` | **OK**, và ra đúng số dòng như bản copy |

⇒ **Mở `mode=ro&immutable=1`, mở lại mỗi lần đánh giá, không giữ handle sống.** Khoảng trắng trong đường dẫn phải percent-encode (`Application%20Support`). **Không copy file** (§A4). Phải xử lý được cả hai trạng thái journal (`delete` như hiện nay, và `WAL` nếu Vivaldi đổi).

Ghi thêm: Vivaldi đã thoát không sạch — còn `SingletonLock`/`SingletonCookie`/`SingletonSocket`. **Không bao giờ mở DB gốc ở chế độ ghi.**

### Đường dẫn (`~` = `/Users/edwardpham`, đã kiểm tồn tại)

```
   Library/Application Support/Vivaldi/Default/History
   Library/Application Support/Google/Chrome/{Default,Profile 1,Profile 2}/History
   Library/Application Support/BraveSoftware/Brave-Browser/Default/History
```

Quét bằng glob `Default` + `Profile *`, **đừng hard-code**. Thiếu file ⇒ bỏ qua im lặng, không phải lỗi.

Đo 30 ngày, lượt `meet.google.com`: Vivaldi **158** · Brave **9** · Chrome Default **4** · Chrome Profile 1/2 **0** · Safari **0**/102.522. Chỉ đọc Vivaldi sẽ bỏ sót **13/171 = 7,6%**.

### Truy vấn — thoả P-1, P-2

```sql
-- CHỈ một cột thời gian. KHÔNG urls.title. KHÔNG SELECT *.
SELECT v.visit_time
FROM visits v JOIN urls u ON u.id = v.url
WHERE v.visit_time > ?        -- cận dưới thời gian TRƯỚC, để dùng index
  AND u.url LIKE ?            -- '%' || <mã phòng> || '%'
ORDER BY v.visit_time DESC
LIMIT 1;
```

### Năm cái bẫy đã trả giá

1. **BẮT BUỘC JOIN `visits`.** `urls.last_visit_time` chỉ giữ lần cuối ⇒ gộp mất các lần lặp. Đo được: **32 so với 96**, chênh 3 lần.
2. **Epoch Chromium = micro-giây từ 1601-01-01.** `unix = visit_time/1000000 - 11644473600`. Trong SQLite, `strftime('%s',…)` trả **TEXT**; so INTEGER với TEXT luôn sai ⇒ phải `CAST(… AS INTEGER)`. Quên là ra 0 kết quả, **im lặng**.
3. **Khớp theo MÃ PHÒNG ở vị trí PATH**, không khớp URL đầy đủ, và **không khớp lỏng ở bất kỳ đâu trong chuỗi**. Đây là chỗ T3 làm lộ ra một lỗi thật (§B6): khớp lỏng nuốt cả `meet.google.com/accounts/SetOSID?...&continue=...<mã phòng>...` — những bước nhảy đăng nhập lại, **không phải người ngồi trong phòng**. Regex chặt: `^[a-z]{3}-[a-z]{4}-[a-z]{3}$` ở thành phần path đầu tiên. Match lỏng cũng nuốt `meet.google.com/home`, thứ xuất hiện 4 lần chỉ trong một ngày của Duy và sẽ làm cổng im cho **mọi** cuộc Meet hôm đó.
4. **Phòng định kỳ dùng LẠI cùng mã phòng.** Lịch có 22 mã distinct/30 ngày; một phòng xuất hiện ở **17 ngày khác nhau**. Một cổng kiểu *"đã thấy mã này trong lịch sử thì im"* sẽ im **vĩnh viễn** cho mọi buổi sau. ⇒ **bắt buộc so `visit_time` với cửa sổ của event, không chỉ so mã.**
5. **`MeetingProvider.swift:188` của MeetingBar có regex LỎNG hơn mã phòng thật** — cho phép tiền tố `_meet/` và đuôi là dãy chữ thường + gạch nối độ dài tuỳ ý, khớp luôn `/home`, `/new`, `/reauth`. ⇒ **hai bên phải chuẩn hoá qua CÙNG MỘT HÀM**, nếu không chúng bất đồng đúng ở các ca biên — mà các ca biên đó chính là 6 lượt tạo ra chênh lệch 90 với 96.

### Một hướng ĐÃ THỬ VÀ ĐÃ LOẠI

Cột `visits.transition` **không** phân biệt được "MeetingBar mở" với "Duy mở". Đo 82 lượt: **81 là `LINK | 0x30000000`**, 1 `RELOAD`. Đồng nhất, vô dụng. (Nó **có** dùng được để lọc redirect — xem bẫy 3.)

### KHÔNG dùng `visit_duration` làm bộ lọc ở runtime

Chromium chỉ ghi `visit_duration` khi người dùng **rời trang**. Tab cuộc họp **đang mở** ⇒ duration = 0. Một bộ lọc "dwell ≥ 60s" sẽ loại đúng các true positive và cổng **sẽ không bao giờ im**. Dùng `visit_duration` **chỉ trong backtest**. *(Giả định này chưa làm thí nghiệm — kiểm bằng một thử nghiệm 2 phút trước khi viết dòng code đầu tiên.)*

## B5. Ràng buộc riêng tư P-1…P-8 — Legal CL-3, vào spec thành thứ kiểm được

| # | Ràng buộc | Vì sao |
|---|---|---|
| P-1 | **Không bao giờ `SELECT *`. Không bao giờ lấy `urls.title`** | tiêu đề trang *là* nội dung |
| P-2 | Chỉ chiếu đúng cột cần, **`LIMIT 1`** | chỉ cần biết *có hay không* ⇒ danh sách URL không bao giờ được dựng ra trong bộ nhớ |
| P-3 | Mở read-only. **KHÔNG copy file ra tmp** | copy = bản sao thứ hai của toàn bộ lịch sử trên đĩa |
| P-4 | Đóng kết nối ngay trong lần đánh giá. Không giữ handle | |
| P-5 | **Không URL, không tiêu đề, không mã phòng nào đi vào `os.Logger`** — dù ở mức `.private` | `sysdiagnose` thu gom unified log archive. 7 category tại `MeetingBarLogger.swift:13-19` |
| P-6 | **Không thêm gì từ lịch sử duyệt vào `DiagnosticsReport`** | `Diagnostics/DiagnosticsReport.swift` tạo báo cáo **người dùng xuất ra và gửi đi**. Đây là đường rò cụ thể nhất tìm được |
| P-7 | Chỉ truy vấn trong cửa sổ quanh một sự kiện lịch. **Không quét nền, không định kỳ** | |
| P-8 | **Safari ngoài phạm vi, và phải ghi lý do** | đòi FDA. Đồng nghiệp dùng Safari ⇒ Nguồn Trình Duyệt **không chạy**, và phải rơi vào nhánh `khôngĐọcĐược` (nhìn thấy được), **không phải im lặng** |

⚠️ **P-5 và P-6 phải được viết lại kèm ngoại lệ tường minh nếu Duy cho phép log/bộ đếm ở Q3–Q4.** Nếu không, CL-3 cấm luôn thứ duy nhất chứng minh được sản phẩm chạy đúng. Đây là câu T2 của Data gửi Legal, hiện **chưa có trả lời**.

## B6. T3 TÁI LẬP — lệch ở đâu, và lệch đó nói gì

Theo Quy tắc 12: hai phiên cùng gốc lệch nhau là **tín hiệu spec chưa rõ**, không phải tỉ số.

| Điểm | T3 dựng được | Được đưa | Spec chưa rõ chỗ nào |
|---|---|---|---|
| URL phòng distinct | **94** (mã ở PATH) hoặc **65** (mã distinct) | 127 | T3 tái lập **chính xác 127** bằng cách đếm mã phòng ở **bất kỳ đâu** trong chuỗi URL. 33 dòng chênh là URL OAuth `SetOSID?...continue=...`. **Spec chưa nói "URL phòng" nghĩa là dòng `urls`, hay mã phòng, hay lượt vào phòng** — ba cách đếm cho 127 / 94 / 65 |
| Lượt truy cập 30 ngày | **90** | 96 | cùng gốc. 6 lượt chênh là bước nhảy redirect `SetOSID`/`reauth`. **Với presence gate, 90 là con số đúng**; 96 làm cổng tưởng người dùng đã vào phòng trong 6 trường hợp chỉ là màn hình đăng nhập. ⇒ đã thành ràng buộc ở §B4 bẫy 3 |
| Vai trò dòng 162 | bộ lọc trước, chỉ trên đường polling | điểm quyết định auto-join | **đã giải** — §B2, PM kiểm lại tại chỗ và xác nhận T3 |
| Khoảng dòng `EventActionPolicy` | 70-**77** (cổng thời gian) | 70-**92** | gộp hai cổng độc lập làm một ⇒ mất dấu rằng presence-gate phải chọn đứng trước hay sau cổng idempotence. **đã giải** — §B3 |
| Biên cửa sổ | `[T-actionTime, T+15s)` — biên phải **MỞ** | `[T-leadtime, T+15s]` | ký hiệu. **đã giải** |
| Nhánh `allDayActive` | tồn tại, **không có cửa sổ nào** | không nhắc | 25/99 event all-day. Với fullscreen nhánh này mở thật. **đã giải** — §B3 |
| Lead time mặc định | `.atStart = 5s` ⇒ cửa sổ 20 giây | chỉ nêu "tối đa 300s" | ngân sách probe trông rộng rãi hơn thực tế **15 lần** với cấu hình mặc định. ⇒ §A9 #5 |
| Đếm sự kiện Meet | 71 / 22 phòng | PM đếm 70 / 21 | PM lọc all-day và chỉ lấy `conferenceData.videoEntryPoint`. Không ảnh hưởng kết luận nào |

**Hai phát hiện mới của T3 đã nâng thành ràng buộc, không để lại dạng ghi chú:** sandbox (§A1 Đ-1) và vòng lặp retry (§B2).

**Một phát hiện mới làm MẠNH thêm con số:** 26 event "không link" **không phải** 26 cuộc họp không link — 25 là event all-day đánh dấu hành chính (`WFH`, `on leave`, `Off`), và 1 là `[Only Reminder] UAT session with ROSHN`. ⇒ mẫu số thật của "cuộc họp" là **74 event có giờ**, trong đó **73 có link**. Thị phần Meet là **71/73 = 97%**, không phải 71/99 = 72%. Con số 97% **đúng** — nhưng nó đo *tỉ lệ cuộc họp dùng Meet*, không đo *tỉ lệ cổng bắt được* (§A2).

**Một phát hiện mới ràng buộc Nguồn Cửa Sổ:** Teams và Webex mỗi bên đúng 1 event, **cả hai đều KHÔNG có `conferenceData`** — link chỉ nằm trong text. Ngược lại 70/71 event Meet có `conferenceData` đàng hoàng. ⇒ lấy link từ `conferenceData` thì mất cả Teams lẫn Webex; dò text thì chịu mọi rủi ro false positive. 2/73 = 2,7% nên **bỏ qua được, nhưng phải bỏ qua CÓ CHỦ Ý và ghi ra**, không phải bỏ sót.

## B7. Nghĩa vụ Apache-2.0 — chi tiết, Legal CL-4/5/6

| Khoản | Phát sinh? | Phải làm gì |
|---|---|---|
| §4(a) *"give any other recipients a copy of this License"* | **CÓ** | `LICENSE` phải nằm **trong bundle** (`Contents/Resources/LICENSE`). Đưa `Foo.app` trần là **vi phạm** |
| §4(b) *"prominent notices stating that You changed the files"* | **CÓ** | header mỗi file sửa, mẫu bên dưới |
| §4(c) *"retain all copyright… notices"* | **CÓ** | **GIỮ**, không xoá. Xem bẫy |
| §4(d) NOTICE | **KHÔNG** | đã kiểm: repo không có file `NOTICE` |
| §6 Trademarks | **CÓ** | bản phân phối không được mang tên `MeetingBar`. **Nhưng §6 CHO PHÉP** viết *"fork của MeetingBar, tác giả gốc Andrii Leitsius"* — đó là mô tả nguồn gốc |

```swift
//
//  NotificationActionRunner.swift
//  <TÊN-MỚI>
//
//  This file was modified on <YYYY-MM-DD> by Duy Pham.
//  Change: added a presence gate at the top of fireAction(plan:event:action:settings:now:).
//
//  Original work from MeetingBar, Copyright © 2020–2025 Andrii Leitsius
//  and the MeetingBar contributors, licensed under the Apache License, Version 2.0.
//
```

Hai chỗ phải tự điền mỗi lần: **ngày** và dòng **`Change:`** nói đúng cái đã sửa — không phải "various improvements". Thêm `CHANGES-FROM-UPSTREAM.md` ở gốc repo liệt kê mọi file đã sửa (không bắt buộc theo §4(b), nhưng đây là thứ giữ đúng được).

**⚠️ Bẫy §4(c) — đừng "dọn dẹp" cái phải giữ.** Phản xạ tự nhiên khi rebrand là tìm-thay toàn bộ và xoá copyright cũ. **Xoá là vi phạm; giữ thì không mất gì.**

- `MeetingBar/Info.plist` → `NSHumanReadableCopyright` = `Copyright © 2020 Andrii Leitsius. All rights reserved.` → **GIỮ NGUYÊN**, thêm dòng của Duy *bên cạnh*.
- 44/134 file `.swift` có dòng copyright → **GIỮ NGUYÊN**, kể cả ở file bị sửa.
- Dòng `All rights reserved.` **không** mâu thuẫn với Apache-2.0 — nó là chuỗi mẫu cũ của Xcode; `LICENSE` mới là thứ cấp phép.
- Riêng `NotificationActionRunner.swift` — chỗ cổng chèn vào — **không có dòng copyright nào**. §4(c) ở file này không có gì để giữ, **nhưng §4(b) vẫn bắt buộc.**
- Có contributor khác (`0bmxa`, `.all-contributorsrc`) ⇒ viết *"và các contributor"*, không chỉ một tên.

### Chỗ nào đang mang tên — đã grep

| Vị trí | Hiện tại | Đổi? |
|---|---|---|
| `project.pbxproj` → `PRODUCT_BUNDLE_IDENTIFIER` | `leits.MeetingBar` | **ĐỔI** — mang cả tên *và* namespace của người khác |
| `project.pbxproj` → `INFOPLIST_KEY_CFBundleDisplayName` | `MeetingBar` | **ĐỔI** |
| `project.pbxproj` → target name ⇒ `MeetingBar.app` | | **ĐỔI** |
| `Info.plist` → `CFBundleURLSchemes` | `meetingbar` | **ĐỔI** — còn **đụng scheme** nếu máy ai đó đã cài MeetingBar thật |
| `Info.plist` → `NSHumanReadableCopyright` | Andrii Leitsius | **GIỮ** (§4(c)) |
| 22 file `Localizable.strings`, `en.lproj` có **20** chỗ | `"Quit MeetingBar"`… | **ĐỔI** phần hiển thị |
| `App/PatronageService.swift:11-13` | `leits.MeetingBar.patronage.*` | **GỠ HẲN** |
| `Utilities/Constants.swift:35` | `mailto:leits.dev@gmail.com` | **GỠ HẲN** |
| `Utilities/MeetingBarLogger.swift:11` | fallback `"leits.MeetingBar"` | đổi, ưu tiên thấp |
| `en.lproj/Localizable.strings:230` | *"…leits.MeetingBar folder"* | đổi theo bundle id mới |

### 🚩 CL-4 — app còn đang xin tiền cho người khác

Đây không phải chuyện giấy phép, và nó nặng hơn chuyện giấy phép.

| Thứ | Hệ quả khi đưa file cho đồng nghiệp |
|---|---|
| `PatronageService.swift` + UI trong `GeneralTab.swift`, StoreKit product ID `leits.MeetingBar.patronage.*` | đồng nghiệp thấy nút ủng hộ tiền trỏ vào **sản phẩm App Store của tác giả gốc**. Ngoài App Store product ID này không resolve ⇒ hoặc UI hỏng, hoặc tệ hơn: một affordance thanh toán nằm dưới **tên sản phẩm mới của Duy** |
| `en.lproj:98` `"Thanks! You have supported MeetingBar for %d months 🎉"` | chuỗi quảng bá cho tên bị §6 cấm |
| `Constants.swift:35` `mailto:leits.dev@gmail.com` | đồng nghiệp gặp lỗi **gửi mail cho Andrii Leitsius**, không phải cho Duy |

**GỠ, không đổi tên.** Muốn giữ thiện chí: thay bằng một link tĩnh tới repo gốc — §6 cho phép.

### CL-6 — câu nói gửi kèm khi đưa file

Không phải vì luật bắt (U-5 chưa rà), mà vì **im lặng ở đây là thứ phá quan hệ, không phải thứ phá luật**. Chi phí: một tin nhắn.

> "App này mình fork từ MeetingBar, thay cho bản gốc trên máy bạn.
>
> Trước khi nó nhắc hoặc tự mở link họp, nó kiểm xem bạn đã vào cuộc họp đó chưa, để khỏi nhắc thừa. Cách nó kiểm: **đọc file lịch sử duyệt web của trình duyệt trên máy bạn**.
>
> Nói thẳng phần cần nói: file đó chứa **toàn bộ** lịch sử duyệt của bạn, nên về mặt kỹ thuật app **đọc được hết**. Cái nó thực sự làm là hỏi đúng một câu — *'N phút qua có mở đúng mã phòng này không'*. Nó không lấy tiêu đề trang, không ghi URL ra log, không gửi gì ra khỏi máy bạn. Mình gửi kèm mã nguồn, bạn xem được chỗ đó.
>
> Không thích thì nói mình tắt tầng này — app vẫn chạy bình thường như MeetingBar gốc."

Ba thứ bắt buộc phải có và **đừng bỏ**: (1) nó đọc file gì, (2) nó **có khả năng** đọc hết, (3) tắt được.

## B8. screenpipe — ranh giới

**Screenpipe Commercial License, "All rights reserved", §5 Prohibited Without a Commercial License. Không chép một dòng nào.**

| ✅ ĐƯỢC — sự kiện và ý tưởng không được bảo hộ | ⛔ KHÔNG — đây là biểu đạt |
|---|---|
| Biết **rằng** Zoom phơi `AXWindow` | chép **bảng tín hiệu per-platform**: cấu trúc, thứ tự, cách chọn |
| Biết **rằng** menu "Meeting" chỉ xuất hiện khi đang họp | chép tên định danh, tên hằng, bố cục struct/enum |
| Biết **rằng** `caphost` có lúc idle còn `CptHost` thì không | chép comment, dù có diễn đạt lại |
| Tên API của Apple (`kAXWindowsAttribute`…) | **dịch Rust → Swift theo từng dòng** — bản dịch là **tác phẩm phái sinh** |

Đã kiểm nhánh này: `probe/Probe.swift` và `probe/AXBrowser.swift` là mã gốc, chỉ dùng API Apple. **Không có dấu hiệu chép.** Một điểm vệ sinh: `probe/AXBrowser.swift:24` có comment `← khớp với mô tả của screenpipe về Zoom` — mã gốc nên không sao, nhưng comment đó là bằng chứng viết tay rằng screenpipe là nguồn **chọn tín hiệu**. Sửa cho trỏ vào **phép đo đã thực hiện**.

**Quy tắc từ đây tới hết S3:** mọi tín hiệu AX đưa vào sản phẩm phải biện minh được bằng **một phép đo ghi trong `gates/`**, không phải bằng screenpipe.

## B9. Nguồn Cửa Sổ — những gì đã đo, và cái chặn

| | |
|---|---|
| Đã đo, dùng được | Zoom 7.1.9 **có** phơi `AXWindow` (`AXWindows=1`, title `"Zoom Workplace"`, `AXStandardWindow`); menu bar lúc idle chỉ 5 menu và **không có menu `Meeting`** ⇒ sự xuất hiện của menu đó là tín hiệu dùng được. `caphost` có lúc idle, `CptHost` không. AX đọc được `AXWebArea → AXURL` đầy đủ trên Chrome/Brave/Vivaldi |
| **Chặn** | tiêu đề cửa sổ lúc ĐANG họp có mang meeting ID không — **chưa ai đo**. Không có nó thì nhánh này chỉ chứng minh *"đang ở trong MỘT cuộc"*, tức **không thoả nổi Quyết định B** |
| Mua về | Teams 1 + Webex 1 = 2/73 cuộc, **và cả hai app đều không cài**. Zoom: 0 cuộc/30 ngày. ⇒ **trên dữ liệu thật, 0** |
| Microcopy | **không** sống ở `Info.plist`. Writer đo: `tccd` biết 40 khoá `*UsageDescription` và `NSAccessibilityUsageDescription` **không nằm trong đó**; binary chứa chuỗi `Service kTCCServiceAccessibility does not allow prompting`; trang tài liệu Apple cho khoá này trả **404**. ⇒ microcopy phải là **một cửa sổ của chính app, hiện TRƯỚC khi gọi `AXIsProcessTrustedWithOptions`**. Vẫn đặt khoá đó trong `Info.plist` — tốn 2 dòng, không mất gì — **nhưng không xây kế hoạch lên nó** |
| Phép thử độc lập, S4 phải chạy thật | xoá `AccessibilityProbe.swift` khỏi target, build. **Nguồn Trình Duyệt phải chạy không đổi một dòng nào.** `PresenceGate` chỉ biết `[PresenceProbe]` |

## B10. Kiểu dữ liệu và ngân sách

```swift
enum PresenceVerdict {
    case present(evidence: Evidence)
    case absent(evidence: Evidence)
    case unknown(reason: UnknownReason)
}
enum UnknownReason { case noAuthority, notFound, unreadable, timedOut, failed(String) }
//                                      ^^^^^^^^  ^^^^^^^^^^
//                            notFound ≠ unreadable — Legal CL-2. unreadable PHẢI nhìn thấy được.

struct MeetingIdentity { let service: MeetingServices; let roomCode: String; let rawURL: URL }

protocol PresenceProbe {
    var id: String { get }
    func verdict(for: MeetingIdentity, now: Date) async -> PresenceVerdict
}
```

> ⚠️ Kiểu của `Evidence` **chưa chốt được** — nó là bất đồng B-2 (URL nguyên văn hay hash). S3 không được tự chọn.

| Thứ | Ngưỡng | Vượt thì sao |
|---|---|---|
| toàn bộ bộ probe | **150 ms** *(đề xuất, CHƯA ĐO — §A9 #5)* | mọi probe chưa trả lời ⇒ `unknown` ⇒ **mở** |
| một probe đơn | 100 ms | probe đó ⇒ `unknown` |
| main thread | **0 ms** I/O | probe chạy ngoài `@MainActor` |
| exception bất kỳ | — | `unknown` + một dòng log. **Không nhánh nào im lặng vì lỗi** |

**S4 bắt buộc log THỜI GIAN probe, không chỉ verdict.** Nếu ngân sách bị vượt thường xuyên thì cổng luôn trả `unknown` và tính năng **chết âm thầm**.

## B11. Cơ chế thoát hiểm

| # | Cơ chế | Vào lát |
|---|---|---|
| 1 | **Thất bại là MỞ** — §A3 | 1 |
| 2 | **Một cú bấm, vị trí cố định** — mục đầu tiên menu bar: `⏸ Tắt cổng im lặng (1 giờ)`. Bấm icon → bấm mục = ~3 giây. Không Preferences, không hotkey (hotkey = setup = vi phạm Quyết định C) | 1 |
| 3 | **Phục hồi tại chỗ** — khi cổng vừa bỏ qua, mục đó đổi thành `⏸ Vừa bỏ qua: <tên cuộc> — Mở ngay`. Lỡ họp thì **hai cú bấm là vào được** *(chờ Q3)* | 2 |
| 4 | **Nhật ký "vì sao tôi im"** *(nội dung chờ Q3+Q4)* | 1 |

Mục 4 cũng là thứ duy nhất cho S4 **nhìn thấy số** thay vì suy ra từ việc đọc code.

## B12. Hợp đồng event cho nhật ký — khung, chờ Q3/Q4 chốt nội dung

Định dạng JSONL, chỉ nối thêm, quyền `0600`. **Vị trí chưa chốt** — ba phòng đưa ba đường dẫn khác nhau; Data chọn `Application Support` vì chưa kiểm được `sysdiagnose` có quét `~/Library/Logs` không.

`presence_gate.decided` — bắn **mỗi lần cổng chạy, cho mọi sự kiện, kể cả khi quyết định là `pass`**. Ghi cả `pass` mới phân biệt được *"cổng chạy và để qua"* với *"cổng không chạy"*. Chống trùng: một dòng cho mỗi **chuyển trạng thái** `(event.id, decision)`, không phải mỗi tick (§B2).

Trường: `ts` · `event_id` · `event_start` · `room` *(dạng chờ Q4)* · `decision` · `source` · `evidence_ts` · `evidence_age_s` · `window_s` · `lead_s` · `browser` · `probe_ms` · `error`.
Nếu `error` khác null thì `decision` **bắt buộc** là `pass`.

`presence_gate.window_probe` — mỗi lần Nguồn Cửa Sổ dò AX. `ts` · `app` · `ax_granted` · `signal` · `ms`. **Trần: tối đa 1 dòng mỗi sự kiện mỗi lần bắn**, không ghi theo nhịp poll. Đây là nguồn duy nhất trả lời được *"Nguồn Cửa Sổ có bao giờ có ích không"* — câu quyết định việc có giữ quyền Accessibility hay không.

`presence_gate.missed` — Duy tự ghi bằng tay khi phát hiện lỡ một cuộc. **Không viết UI, không viết code**; một dòng `echo >>` là đủ. Đây là **nhãn ground-truth duy nhất ở runtime**: không có nó thì log chỉ nói cổng quyết định gì, không nói quyết định đó đúng hay sai.

**Tên event là hợp đồng.** Thêm trường mới: tự do. Đổi tên hoặc đổi ý nghĩa: **ghi một dòng CÓ NGÀY vào cuối file, không sửa tại chỗ.**

## B13. Cách các con số được tạo ra — để phiên sau tái lập, không phải để tin PM

| Nguồn | Cái gì |
|---|---|
| Google Calendar API, `2026-09-13` → `2026-10-14`, lịch `duy.pham@ringkas.co.id` (hai lịch còn lại là Holidays), `pageSize=250`, `nextPageToken=none` | 99 sự kiện · Meet 71 · Zoom 0 · Teams 1 · Webex 1 · không link 26 (trong đó **25 all-day hành chính + 1 reminder**) ⇒ **74 event có giờ, 73 có link** · 22 mã phòng distinct · 6 phòng dùng lại cho >1 sự kiện · khoảng cách nhỏ nhất giữa hai sự kiện cùng mã phòng **1440 phút** · 67 accepted · 4 needsAction · 0 declined |
| `Vivaldi/Default/History`, `visits JOIN urls`, 30 ngày | **90** lượt (mã ở PATH) hoặc **96** (khớp lỏng, gồm 6 redirect) · 158 lượt `meet.google.com` tổng · 22 phòng sau chuẩn hoá · một phòng ở 17 ngày khác nhau |
| Nối hai cái trên, cửa sổ `[start-3h, end+10m]` | 59/70 cuộc khớp · delta sớm nhất p25=169s median=171s p75=176s · **3** cuộc có lượt vào trước T-180s (230s · 1.912s · 7.005s) · 15/59 cuộc có ≥2 lượt · 10/23 cặp cách <60s |
| Replay, lead=180s | W=5p → **1** · W=15p → **1** · W=30p → **1** · W=60p → 2 · W=24h → 7 |
| Lượt vào ĐẦU TIÊN rơi ở đâu | `T-180s ± 5s`: **15** · `T-175s…T`: 40 · `T-5p…T-181s`: **1** · sau T: 4 · không ghé: 11 |
| Dwell của 96 lượt | =0s: 9 · <10s: 21 · 10–60s: 5 · 1–5p: 12 · ≥5p: 49 ⇒ **31% dưới 10 giây** |
| Lần vào gần nhất *trước* mỗi cuộc, cũ hơn 1 tiếng | min **1,95h** · 3,05h · 3,80h · rồi nhảy **23,55h** · median 48h |
| Mở SQLite | `mode=ro` ⇒ locked **kể cả khi Vivaldi không chạy** (hot journal 8,5 KB, `journal_mode=delete`); `mode=ro&immutable=1` ⇒ OK, trùng khớp bản copy |
| Lượt Meet 30 ngày theo trình duyệt | Vivaldi 158 · Brave 9 · Chrome Default 4 · Chrome Profile 1/2 0·0 · Safari **0**/102.522 |
| `Safari/History.db` (shell này có FDA) | 0 lượt Meet / 30 ngày |
| TCC | `/Library/.../TCC.db`: `/Users/edwardpham/.volta/.../node` có `kTCCServiceSystemPolicyAllFiles auth_value=2`. Cây tiến trình T3: `zsh ← claude ← -zsh ← login ← iTermServer-3.7.3` |
| `tccd` binary | 40 khoá `*UsageDescription`, **không có** `NSAccessibilityUsageDescription`; chuỗi `Service kTCCServiceAccessibility does not allow prompting` |
| Đọc source tại `fdd799b`+ (PM kiểm lại tại chỗ 2026-10-13) | `fireDueActions:37` · `fire:65` · `fireAction:74` · `evaluate:101` · `shouldFireSideEffect:109` · `setProcessedRecords:115` · `shouldConsiderActionEvent:162` · `NotificationScheduler.swift:191,212` · `TimeBeforeEvent` `Constants.swift:143-148` · `MeetingProvider.swift:188` · `MeetingBar.entitlements` app-sandbox=true · `project.pbxproj:453,483` |
| Nguồn ngoài | [Apple Developer Forums #847030](https://developer.apple.com/forums/thread/847030) — macOS 27 chặn im lặng, Apple DTS: *"This is an intentional change… I'm not sure whether Full Disk Access will get around this."* · [#801461](https://developer.apple.com/forums/thread/801461) — `kTCCServiceSystemPolicyAppData` · [Zoom API ToU (mirror)](https://hp.zoom.us/legal/zoom_api_license_and_tou) · Hanley & Lippman-Hand, JAMA 1983 — **trích từ trí nhớ, chưa mở lại bản gốc** |

---

*PRD này gộp bốn báo cáo phòng ban, hai vòng T2 chéo-phòng và một vòng T3 tái lập. PM kiểm lại tại chỗ sáu khẳng định về source code và entitlements. Mọi thứ còn lại là tự kiểm phía tác giả.*
**Same vendor, same priors — no external verifier ran.** Không bao giờ "independently verified".
**Review ≠ approve.** PRD này chưa được duyệt. Chỉ Duy duyệt, và việc phát file cho bất kỳ ai cần Duy duyệt riêng, ghi thành chữ có ngày.
