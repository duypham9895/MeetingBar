# Bật Google Calendar API cho bản fork này

*Đọc ~3 phút. Làm ~10 phút. Chỉ Duy làm được — nó gắn với tài khoản Google của anh.*

## TL;DR

Nguồn lịch **"macOS Calendar app" vẫn chạy bình thường và không cần gì cả.** Tài liệu này chỉ
cần khi anh muốn dùng **"Google Calendar API"**, thứ hiện hiển thị *"not configured in this build"*.

## Vì sao nó không chạy — nguyên nhân gốc, đã truy

```
XCConfig/Project.xcconfig       GOOGLE_CLIENT_NUMBER = REPLACE_BY_YOUR_GOOGLE_CLIENT_NUMBER
         ↓  build-variable substitution
MeetingBar/Info.plist           GOOGLE_CLIENT_NUMBER + CFBundleURLSchemes
         ↓  Bundle.main.object(...)
kRedirectURI = "com.googleusercontent.apps.REPLACE_BY_YOUR_GOOGLE_CLIENT_NUMBER:/oauthredirect"
         ↓  dấu "_" KHÔNG hợp lệ trong scheme URL
URL(string:) = nil
         ↓
bản gốc: force-unwrap ⇒ CRASH ~28s sau khởi động, kể cả khi dùng macOS Calendar
sau sửa:  throw      ⇒ NSURLErrorDomain -1000 trên Preferences
hiện tại: chặn sớm   ⇒ "not configured in this build", không chọn được, không hỏng
```

**MeetingBar không công bố OAuth client của mình.** Bản chính thức trên App Store có credential
thật nhúng trong Info.plist; repo công khai thì chỉ có placeholder. Đây là chủ ý của tác giả,
không phải lỗi — và nó có nghĩa là **mọi bản fork phải tự cấp credential.**

## ⛔ KHÔNG chép credential từ bản chính thức

Chúng nằm sẵn trong `/Applications/MeetingBar.app/Contents/Info.plist` và kỹ thuật thì dùng được.
**Đừng.** Ba lý do, cái nào cũng đủ:

1. OAuth client đó đăng ký dưới tên **Andrii Leitsius**. Màn hình xin quyền của Google sẽ hiện
   tên app của ông ấy — đồng nghiệp anh đang cấp quyền cho một bên họ tưởng là ai khác.
2. Hạn mức API của anh ăn vào quota của ông ấy.
3. Apache-2.0 **§6** không cấp quyền dùng tên và nhãn hiệu của tác giả gốc.

## Làm thế nào — 6 bước

1. **Google Cloud Console** → tạo project mới (tên gì cũng được, ví dụ `presence-gate`).
   https://console.cloud.google.com/projectcreate
2. **Bật Google Calendar API** cho project đó.
   *APIs & Services → Library → "Google Calendar API" → Enable*
3. **OAuth consent screen** → chọn **External** → điền tên app, email hỗ trợ, email liên hệ.
   Để ở chế độ **Testing** và thêm chính anh (+ đồng nghiệp sẽ dùng) vào **Test users**.
   Ở chế độ Testing thì **không cần Google xét duyệt**, giới hạn 100 test user — thừa cho ≤5 người.
4. **Scopes** → thêm đúng hai cái MeetingBar xin
   (`GoogleCalendarEventStore.swift` có liệt kê, đây là bản chép lại):
   - `https://www.googleapis.com/auth/calendar.calendarlist.readonly`
   - `https://www.googleapis.com/auth/calendar.events.readonly`
   Cộng `email`. **Chỉ đọc** — không có scope ghi nào.
5. **Credentials → Create credentials → OAuth client ID → Desktop app.**
   Lấy về **Client ID** và **Client secret**.
6. **Điền vào repo:**
   ```sh
   cp XCConfig/GoogleOAuth.xcconfig.example XCConfig/GoogleOAuth.xcconfig
   # mở ra, điền Client ID (bỏ đuôi .apps.googleusercontent.com) và secret
   ```
   `XCConfig/GoogleOAuth.xcconfig` **đã nằm trong `.gitignore`** — nó sẽ không lọt vào repo.
   Build lại. Tuỳ chọn "Google Calendar API" sẽ hết chữ *"not configured"*.

## Kiểm đã xong chưa

```sh
xcodebuild -project MeetingBar.xcodeproj -scheme MeetingBar -configuration Debug \
  -destination 'platform=macOS' build CODE_SIGNING_ALLOWED=NO
APP=$(find ~/Library/Developer/Xcode/DerivedData -name MeetingBar.app -path '*Debug*' | head -1)
/usr/libexec/PlistBuddy -c "Print :GOOGLE_CLIENT_NUMBER" "$APP/Contents/Info.plist"
# phải ra số của anh, KHÔNG phải REPLACE_BY_...
```

## Chưa xác minh được

- **Chưa ai chạy hết luồng này tới cùng**, vì nó cần tài khoản Google Cloud của Duy. Các bước
  trên lấy từ code (scope, loại client, hình dạng redirect URI) và từ cấu trúc Console; phần
  thao tác trên Console **chưa được kiểm bằng cách bấm thật**.
- **Loại OAuth client**: code dựng redirect URI kiểu `com.googleusercontent.apps.<số>:/oauthredirect`,
  đó là khuôn của client **iOS/Desktop**, không phải Web. Nếu "Desktop app" không cho ra đúng
  khuôn đó, thử loại **iOS**.
- Bản fork **không có locale `vi`** — mọi chuỗi mới ở đây chỉ có tiếng Anh.
