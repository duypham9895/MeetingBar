---
owner: Phòng Data
freshness: 2026-10-13
status: draft — CHƯA được Duy duyệt
---

# SUCCESS-CRITERIA — presence-gate

**Thời gian đọc phần quyết định: ~4 phút.** Phần THAM CHIẾU ở cuối không cần review.

> Số liệu dưới đây do chính phòng Data đo trong phiên 2026-10-13, chưa qua reviewer —
> *same vendor, same priors — no external verifier ran*.

## TL;DR

Dự án này có **ground truth sẵn**, nên tôi không thiết kế phép đo rồi chờ — tôi chạy luôn.
Kết quả:

> **Với cấu hình thật của Duy (`automaticEventJoinTime=180`), cổng presence sẽ im đúng
> 1 lần trên 71 cuộc Meet trong 30 ngày. 1,4%.**

Không phải vì detector yếu. Vì **MeetingBar luôn thắng cuộc đua**: nó mở tab ở T-180s,
trước khi Duy kịp tự mở. 55/71 lần ghé đầu tiên rơi vào khoảng `[T-180s, T]`; **chỉ 1/71 rơi
trước T-180s** — và đó đúng là cuộc duy nhất cổng sẽ chặn.

Phép đo này tái lập **chính xác** ba con số của S0 (99 sự kiện · 71 Meet · 96 lượt ghé), nên
nó không phải một phương pháp khác cho ra kết quả khác.

## 1. Bảng số — mỗi dòng trả lời một câu hỏi quyết định

| # | Metric | Số hôm nay | Nếu X ⇒ làm gì | Nếu Y ⇒ làm gì khác |
|---|---|---|---|---|
| **M1** | `n_silence_30d` — số sự kiện cổng sẽ im, trên 71 | **1** | ≥ 8 ⇒ đặc tả cả hai tầng, đúng Quyết định D | ≤ 2 ⇒ **dừng, hỏi Duy** trước khi đặc tả Tầng 2 |
| **M2** | `n_wrong_silence` — số lần im nhầm (⇒ lỡ họp) | 0 / 1 | 0 ⇒ được ship | ≥ 1 ⇒ hạ W xuống 5 phút, đo lại; vẫn ≥ 1 ⇒ **không ship Tầng 1** |
| **M3** | `tier2_fire_60d` — số lần Tầng 2 thực sự chặn được gì | chưa chạy (dự kiến 0) | ≥ 1 ⇒ giữ Tầng 2 và quyền Accessibility | = 0 sau 60 ngày ⇒ đề xuất **gỡ Tầng 2**, trả lại quyền |
| **M4** | `n_no_history` — sự kiện không để lại dấu nào trong Vivaldi | 11 / 71 | ≥ 20 ⇒ detector phải đọc thêm Chrome/Brave/Safari | ≤ 15 ⇒ chỉ đọc Vivaldi, đủ |

Không có metric nào khác. Những thứ đo được mà không đổi hành động nào — số tab đã mở, thời
gian chạy detector, số sự kiện mỗi ngày — **cố ý không nằm trong bảng này.**

## 2. Ngưỡng ship — ba cổng, phải đạt CẢ BA

| Cổng | Ngưỡng (một con số, không phải tính từ) | Hôm nay |
|---|---|---|
| **G1** | Replay 30 ngày: số lần im-lặng-nhầm = **0** | **ĐẠT** — 0/1 (xem cảnh báo §4) |
| **G2** | Cửa sổ `W` ≤ ¼ khoảng tái dùng mã phòng nhỏ nhất. Đo được: nhỏ nhất = **1440 phút** ⇒ W ≤ 360. **Chọn W = 15 phút.** | **ĐẠT**, biên 96× |
| **G3** | 14 ngày dùng thật, đọc log cục bộ: số lần im-lặng-nhầm = **0** | **CHƯA** — cần TRACKING-PLAN được thực thi |

**Không đạt G3 thì không gọi là xong**, kể cả khi code chạy đúng. "Xong" nghĩa là **đã mở file
log và NHÌN THẤY dòng** — không suy ra từ việc đọc code (Quy tắc 8).

## 3. Hai loại lỗi KHÔNG đối xứng — và hệ quả của nó

| | Xảy ra khi | Người dùng thấy gì | Chi phí | Tôi chấp nhận |
|---|---|---|---|---|
| **FP — im lặng nhầm** | cổng tin là đã vào họp, thực tế chưa | **không thấy gì cả.** Không tab, không notify (Quyết định B) ⇒ **lỡ họp** | Cao. Không hồi phục. Theo thiết kế thì **vô hình** | **0 lần / 30 ngày.** Tuyệt đối, không phải tỉ lệ |
| **FN — mở thừa** | cổng không nhận ra đã vào họp | một tab thừa — **đúng bằng MeetingBar hôm nay** | 0 so với hiện trạng | **Tới 100%.** Cổng không bao giờ im thì sản phẩm vẫn không tệ hơn bản gốc |

**Hệ quả kiến trúc, và nó là ràng buộc cứng cho SWE:**

```
   Cổng MẶC ĐỊNH là PASS. Nghi ngờ ⇒ MỞ.
   Detector phải là BẰNG CHỨNG CÓ MẶT, không phải THIẾU BẰNG CHỨNG VẮNG MẶT.
   Mọi lỗi đọc, mọi DB khoá, mọi regex không khớp ⇒ PASS, không bao giờ ⇒ SILENCE.
```

Vì FN miễn phí còn FP đắt, mọi đánh đổi đều nghiêng về một phía. Không có chỗ cho "cân bằng".

## 4. Cảnh báo phải đọc trước khi tin vào G1

**0 lỗi trên 1 mẫu không chứng minh gì.** Quy tắc rule-of-three: không có lỗi nào trong n lần
thử thì cận trên 95% của tỉ lệ lỗi vẫn là ~3/n. Với n = 1, cận trên là **300%** — tức là vô
nghĩa. (Hanley & Lippman-Hand, *JAMA* 1983, "Interpreting zero numerators" — trích từ trí nhớ,
tôi **không mở lại bản gốc** trong phiên này.)

Nên cái bảo vệ Duy khỏi FP **không phải thống kê**, mà là hai thứ cơ học:

1. **Cửa sổ W = 15 phút** — biên 96× so với khoảng tái dùng mã phòng nhỏ nhất đo được (24h).
2. **Log cục bộ** — xem `TRACKING-PLAN.md`. Không có log thì FP là một sự kiện không để lại
   dấu vết nào ở bất kỳ đâu.

## 5. Mâu thuẫn phải gỡ — `ONE-PAGER.md` §4

`ONE-PAGER.md` §4 hiện ghi: *"không có instrumentation và cố ý không có"*. `TRACKING-PLAN.md`
đề xuất **có** một log cục bộ. Hai câu này không sống cùng nhau được.

**Duy sở hữu ONE-PAGER** (Quy tắc 11). Đề nghị thêm một dòng có ngày ở §4, **không sửa tại chỗ**:

> `2026-10-13 — có một log cục bộ, chỉ trên máy người dùng, không gửi đi đâu. Vẫn không có`
> `analytics và vẫn cố ý không có. Lý do: Quyết định B làm cho lỗi im-lặng-nhầm trở thành vô hình.`

## 6. Việc này cần Duy, không agent nào làm thay (Quy tắc 6)

| Việc | Vì sao không tự động được | Tốn bao lâu |
|---|---|---|
| **Trả lời câu hỏi ở §M1** — 1/71 có đổi gì không | Đây là mức chịu rủi ro và thứ tự ưu tiên, không phải phép tính | 5 phút |
| **Dán nhãn tay 1 sự kiện duy nhất cổng sẽ im** (`09-14 16:30 · iat-dpyb-uvb · Product Team Daily Checkpoint`) — hôm đó anh có thật sự đang ở trong cuộc lúc 16:27 không? | Lịch sử trình duyệt chỉ biết *một tab đã mở*, không biết *người có trong phòng họp* | 2 phút |
| **Đọc log sau 14 ngày** và nói "có lần nào tôi lỡ họp mà không hiểu vì sao không" | Chỉ Duy biết mình đã lỡ cuộc nào | 10 phút |

## 7. Chưa xác minh được

| # | Thứ chưa biết | Vì sao nó quan trọng |
|---|---|---|
| 1 | **Phản thực tế**: nếu TẮT `automaticEventJoin`, Duy sẽ tự mở link trước T-180s bao nhiêu lần? | Toàn bộ dữ liệu 30 ngày được sinh ra khi auto-join ĐANG BẬT. Nên **1/71 là cận DƯỚI của lợi ích**, không phải ước lượng đúng. Chỉ đo được bằng cách tắt auto-join một thời gian — mà tắt rồi thì sản phẩm này mất lý do tồn tại |
| 2 | 11/71 sự kiện không có dấu nào trong Vivaldi — vào bằng Chrome/Brave/Safari, bằng điện thoại, hay không dự? | Ba trình duyệt kia **chưa được đọc** trong phiên này. Ảnh hưởng tới M4 |
| 3 | 6/71 sự kiện có ≥2 lần ghé trong cửa sổ bắn `[T-180s, T+15s]` — là mở tab thừa thật, hay chỉ là điều hướng trong trang? | Không phân biệt được bằng lịch sử. Đây có thể là **nguồn đau thật sự** mà cổng presence không chạm tới |
| 4 | `visit_duration` của một tab **đang mở** có bằng 0 không? | Tôi suy ra là có (Chromium chỉ ghi khi rời trang), **chưa làm thí nghiệm**. Hệ quả ở §THAM CHIẾU-C — nếu đúng thì bộ lọc dwell ở runtime sẽ loại đúng các true positive |
| 5 | Tiêu đề cửa sổ Zoom khi **đang trong** cuộc họp có mang meeting ID không | Từ S0, chưa đo được. Duy có 0 cuộc Zoom/30 ngày |
| 6 | `~/Library/Logs` có bị `sysdiagnose` quét không | Chưa kiểm. Vì vậy TRACKING-PLAN chọn `Application Support` cho chắc |
| 7 | Bản History tôi đọc là **bản copy của file chính**; có một file `History-journal` cạnh đó không được gộp | Vài dòng cuối cùng có thể thiếu. Ảnh hưởng không đáng kể ở quy mô 30 ngày |

---
---

# THAM CHIẾU — không ai review phần này. Chỉ mở ra lúc build hoặc lúc đo lại.

## A. Nguồn dữ liệu và cách join

| | Nguồn | Lấy thế nào | Bẫy |
|---|---|---|---|
| **Lịch** | Google Calendar, lịch primary, `2026-09-13` → `2026-10-14` | API `list_events`, `orderBy=startTime`, `pageSize=250` | **Phải dedupe theo `event.id`.** Hai lần gọi chồng biên trả về 150 dòng cho 99 sự kiện thật |
| **Hiện diện** | `~/Library/Application Support/Vivaldi/Default/History` | `sqlite3`, **copy file ra trước** rồi mới đọc. Không prompt TCC nào | **Phải JOIN bảng `visits`.** `urls.last_visit_time` chỉ giữ lần cuối ⇒ 32 thay vì 96 |
| **Khoá join** | mã phòng Meet | regex `meet\.google\.com/([a-z]{3}-[a-z]{4}-[a-z]{3})` trên **toàn bộ** JSON sự kiện (link nằm rải ở `hangoutLink`, `conferenceData.entryPoints[].uri`, `location`, `description`) | `meet.google.com/home` và `meet.google.com/?authuser=…` **không có mã phòng**. Match lỏng `LIKE '%meet.google.com/%'` cho ra 163 dòng thay vì 96 |
| **Thời gian** | | Chromium: `visit_time/1000000 - 11644473600` = epoch giây | Trong SQLite, `strftime('%s',…)` trả về **TEXT**. So INTEGER với TEXT luôn sai ⇒ phải `CAST(… AS INTEGER)`. Quên là ra 0 kết quả, im lặng |

## B. Kết quả đầy đủ, 2026-10-13

**Tái lập S0 — khớp tuyệt đối:**

| | S0 nói | Tôi đo lại | |
|---|---|---|---|
| Sự kiện 30 ngày | 99 | **99** | ✓ |
| Có link Google Meet | 71 | **71** | ✓ |
| Lượt ghé phòng trong Vivaldi | 96 | **96** | ✓ |

**Kết quả mới:**

| Phép đo | Số |
|---|---|
| Mã phòng distinct trong lịch sử | 23 |
| Phiên (phòng × ngày) distinct | 65 |
| Mã phòng distinct trên lịch | 22 — trong đó **6 phòng dùng lại cho >1 sự kiện** |
| Khoảng cách nhỏ nhất giữa hai sự kiện cùng mã phòng | **1440 phút (24h)** |
| Phòng tái dùng nhiều nhất | `iat-dpyb-uvb` — 17 ngày khác nhau; `qjk-vtad-gdr` — 14 ngày |
| Trạng thái trả lời của Duy | 67 accepted · 4 needsAction · **0 declined · 0 cancelled** |

**`n_silence` theo cửa sổ W, lead = 180s:**

| W | 5p | 10p | 15p | 30p | 60p | 24h |
|---|---|---|---|---|---|---|
| sự kiện bị im | 1 | 1 | **1** | 1 | 2 | 7 |

**Lần ghé ĐẦU TIÊN rơi ở đâu so với T:**

| khoảng | số sự kiện | nghĩa là gì |
|---|---|---|
| T-30p … T-5p | 0 | |
| T-5p … T-181s | **1** | ghé thủ công sớm — **đây là toàn bộ giá trị của cổng** |
| **T-180s ± 5s** | **15** | chữ ký của chính auto-join |
| T-175s … T | 40 | auto-join + độ trễ poll (median offset toàn bộ = **−171s**) |
| T … T+5p | 1 | |
| T+5p … T+60p | 3 | |
| không ghé lần nào | 11 | |

15 lần ghé rơi đúng `T-180±5s` **xác nhận bằng dữ liệu** rằng mô hình "bắn ở T-lead" là đúng và
`automaticEventJoinTime=180` đang có hiệu lực thật.

**Phân bố dwell của 96 lượt ghé:**

| =0s | <10s | 10–60s | 1–5p | ≥5p |
|---|---|---|---|---|
| 9 | 21 | 5 | 12 | 49 |

**31% số lượt ghé kéo dài dưới 10 giây** — đây đúng là lớp "mở ra rồi thoát" sẽ làm detector im
nhầm nếu chỉ xét sự tồn tại của lượt ghé.

**Sự kiện duy nhất cổng sẽ im (W = 15p):**

```
09-14 16:30  iat-dpyb-uvb  [recurring]  ghé lúc T-230s  dwell=453s  có ghé lại sau đó
"Product Team Daily Checkpoint"
```

Ghé 230 giây trước giờ họp, ở lại 7,5 phút, và còn ghé lại sau T-180s. Đây gần như chắc chắn là
một true positive — nhưng **Duy phải xác nhận bằng tay** (§6).

**Hai phép đo phụ:**

| | Số | Diễn giải |
|---|---|---|
| Sự kiện bị `updated` ngay trong cửa sổ bắn | **1 / 71** | Đường "sửa sự kiện ⇒ khoá `(id, lastModifiedDate)` reset ⇒ bắn lại" giải thích được **nhiều nhất 1 cuộc/tháng** |
| Sự kiện có ≥2 lượt ghé trong `[T-180s, T+15s]` | **6 / 71** | Khuôn mẫu: lần đầu ~T-171s (auto-open), lần sau muộn hơn 50–120s. **Không phân biệt được** tab thứ hai với điều hướng trong trang |

## C. Ba ràng buộc kỹ thuật rút ra, gửi thẳng cho SWE

1. **KHÔNG dùng `visit_duration` làm bộ lọc ở runtime.** Chromium chỉ ghi `visit_duration` khi
   người dùng rời trang. Tab cuộc họp **đang mở** ⇒ duration = 0. Một bộ lọc "dwell ≥ 60s" sẽ
   loại đúng các true positive và cổng sẽ không bao giờ im. Dùng `visit_duration` **chỉ trong
   backtest**, nơi mọi lượt ghé đã kết thúc. (Giả định này nằm ở mục *chưa xác minh được* #4 —
   kiểm bằng một thí nghiệm 2 phút trước khi viết dòng code đầu tiên.)

2. **Regex mã phòng phải chặt**: `^[a-z]{3}-[a-z]{4}-[a-z]{3}$`. Match lỏng sẽ nuốt
   `meet.google.com/home`, thứ xuất hiện 4 lần chỉ trong một ngày của Duy và sẽ làm cổng im cho
   **mọi** cuộc Meet trong ngày hôm đó.

3. **Mọi lỗi đều PASS.** DB khoá, file không tồn tại, SQL hỏng, regex trượt ⇒ trả `pass`. Không
   bao giờ để một lỗi đọc biến thành một quyết định im lặng.

## D. Script tái lập

Nằm ở scratchpad của phiên (`.../scratchpad/backtest.py`, `offset.py`, `gap.py`) — **sẽ mất khi
phiên đóng**. Đề nghị SWE commit vào `probe/backtest-presence-gate.py`. Lõi:

```python
LEAD = 180                     # automaticEventJoinTime thật của Duy
W    = 900                     # cửa sổ 15 phút
# visits: {room: [(epoch_sec, dwell_sec), ...]}  — từ Vivaldi History, JOIN visits
# evs:    [(start_epoch, room), ...]             — từ Google Calendar, dedupe theo id
for t, room in evs:
    hits = [v for v in visits.get(room, []) if t - W <= v[0] <= t - LEAD]
    decision = "silence" if hits else "pass"
```

Chạy lại sau mỗi lần đổi `W` hoặc đổi `automaticEventJoinTime`. **Đổi lead time là đổi toàn bộ
bài toán** — ở lead = 300s (mức tối đa MeetingBar cho phép) con số sẽ khác, chưa đo.
