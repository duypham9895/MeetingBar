---
stage: 01-spec
phòng sở hữu: PM
date: 2026-10-13
---

# UNDERSTOOD — PM, trước khi mở S1

## Tôi đã đọc ONE-PAGER

<grounding>
"Một bản MeetingBar đã sửa, cho **Duy và vài đồng nghiệp ở Ringkas**."
"Không phải sản phẩm công khai. Không lên App Store. Không bán."
"Đây là quyết định gu — không agent nào chọn thay."
</grounding>

## Kể lại bằng chữ của tôi

Duy mở Meet trong Vivaldi khoảng ba lần một ngày. Ba phút trước giờ, MeetingBar bắn một quả
auto-join không nhìn ngó gì — kể cả khi phòng đã mở sẵn trên màn hình. Kết quả là một cửa sổ
thừa, đúng lúc anh đang nói chuyện với người khác.

Thứ chúng tôi làm không phải một cảm biến. Nó là một cuốn sổ nợ: *trước khi mở bất cứ thứ gì,
hãy xem mình đã mở nó rồi chưa.* Trình duyệt vốn đã ghi lại mọi phòng từng vào, kèm giờ tới
từng giây, trong một file SQLite không khoá — nên câu trả lời đã nằm sẵn trên đĩa, chỉ chưa
ai nghĩ tới chuyện hỏi nó.

Điều này chỉ phục vụ một người cộng vài đồng nghiệp. Nó không đi ra chợ. Nghĩa là mọi lập
luận kiểu "người dùng sẽ không hiểu" đều vô nghĩa ở đây — người dùng ngồi ngay đây và tự
quyết. Và cũng nghĩa là mọi chi phí dựng cho một sản phẩm công khai — App Store, review,
hỗ trợ, marketing — đều là tiền tiêu nhầm.

Cái duy nhất tôi không được tự quyết là thẩm mỹ và mức chịu đựng rủi ro. Tên app, cảm giác
khi nó im lặng, chấp nhận hay không chấp nhận một lần đoán sai — những cái đó là của Duy.

## Stage của tôi phục vụ điều đó thế nào

S1 biến bốn quyết định đã chốt ở S0 (A phân phối · B im hẳn khi đúng cuộc · C không setup ·
D cả hai tầng) thành một spec mà S3 code thẳng được, không phải hỏi lại. Cụ thể S1 phải chốt
ba thứ mà S0 cố ý để mở:

1. **Cửa sổ thời gian nào tính là "đã vào"** — thấy phòng này 40 phút trước có tính không?
   Đây là tham số quyết định tỉ lệ đoán sai, và nó ăn thẳng vào Quyết định B.
2. **Tầng 2 kiểm thử bằng cách nào**, khi Zoom có 0 cuộc và Teams/Webex không cài. S0 nêu ba
   đường và cố ý không chọn.
3. **Chuyện gì xảy ra khi hai tầng bất đồng** — Tầng 1 nói đã vào, Tầng 2 nói chưa.

Nếu S1 để hở ba thứ này thì S3 sẽ tự đoán, và cái nó đoán sẽ không phải cái Duy muốn.
