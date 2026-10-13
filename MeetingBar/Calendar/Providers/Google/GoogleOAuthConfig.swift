//
//  GoogleOAuthConfig.swift
//  presence-gate — thêm mới, không có trong MeetingBar gốc (Apache-2.0 §4(b)).
//
//  MỘT nguồn sự thật cho câu hỏi: bản build này có cấu hình Google OAuth chưa?
//
//  Vì sao cần: MeetingBar KHÔNG công bố OAuth client của nó. `XCConfig/Project.xcconfig`
//  ship placeholder `REPLACE_BY_YOUR_GOOGLE_CLIENT_NUMBER`, chuỗi đó chui vào Info.plist
//  qua build-variable substitution, rồi thành
//      kRedirectURI = "com.googleusercontent.apps.REPLACE_BY_YOUR_GOOGLE_CLIENT_NUMBER:/oauthredirect"
//  Dấu gạch dưới không hợp lệ trong scheme URL ⇒ URL(string:) trả nil.
//
//  Bản gốc force-unwrap chỗ đó ⇒ app CHẾT ~28 giây sau khi khởi động, kể cả khi người
//  dùng đang dùng "MacOS Calendar App" và không đụng gì tới Google. Sau khi thay bằng
//  throw, nó thành `NSURLErrorDomain -1000` trên màn hình Preferences — hết crash,
//  nhưng -1000 không nói cho ai biết điều gì.
//
//  File này biến "chưa cấu hình" thành một trạng thái ĐƯỢC KHAI BÁO, kiểm được trước
//  khi chạm tới mạng, và nói được thành câu.
//

import Foundation

enum GoogleOAuthConfig {
    /// Chuỗi placeholder mà repo ship sẵn. Nhận ra nó bằng tiền tố, không so bằng,
    /// để một placeholder bị sửa dở dang cũng vẫn bị bắt.
    private static let placeholderPrefix = "REPLACE_BY_"

    private static func plistValue(_ key: String) -> String? {
        // KHÔNG dùng `as! String` như bản gốc: khoá thiếu thì nên là "chưa cấu hình",
        // không nên là một vụ crash.
        guard let raw = Bundle.main.object(forInfoDictionaryKey: key) as? String else { return nil }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty || trimmed.hasPrefix(placeholderPrefix) { return nil }
        return trimmed
    }

    /// Đuôi mà Google gắn vào Client ID đầy đủ. Code dựng `kClientID` bằng cách
    /// TỰ NỐI đuôi này, nên nếu người cấu hình dán nguyên Client ID từ Console thì
    /// nó bị nối hai lần:
    ///
    ///     000000000000-abc.apps.googleusercontent.com.apps.googleusercontent.com
    ///                        └──── của người dùng ────┘└──── code tự nối ────────┘
    ///
    /// Google trả `401 invalid_client — The OAuth client was not found`, một câu
    /// chỉ thẳng vào "credential sai" và không hề gợi ý rằng nó chỉ bị thừa đuôi.
    /// **Đã xảy ra thật, 2026-10-13.** Hướng dẫn có ghi "bỏ đuôi" cũng không cứu được:
    /// dán nguyên cái Console đưa cho là phản xạ đúng của con người.
    private static let clientIDSuffix = ".apps.googleusercontent.com"

    /// Phần SỐ của Client ID. Chấp nhận **cả hai** dạng người ta hay dán.
    static var clientNumber: String? {
        guard let raw = plistValue("GOOGLE_CLIENT_NUMBER") else { return nil }
        guard raw.hasSuffix(clientIDSuffix) else { return raw }
        let trimmed = String(raw.dropLast(clientIDSuffix.count))
        return trimmed.isEmpty ? nil : trimmed
    }
    static var clientSecret: String? { plistValue("GOOGLE_CLIENT_SECRET") }

    /// `true` chỉ khi CẢ HAI giá trị có thật **và** redirect URI dựng ra là URL hợp lệ.
    /// Kiểm luôn vế cuối vì đó chính là chỗ bản gốc nổ.
    static var isConfigured: Bool {
        guard let n = clientNumber, clientSecret != nil else { return false }
        return URL(string: "com.googleusercontent.apps.\(n):/oauthredirect") != nil
    }

    /// Câu giải thích cho người đọc, không phải cho máy. Hiện ở Preferences.
    static let unconfiguredReason = "google_oauth_not_configured".loco()

    enum ConfigError: LocalizedError {
        case notConfigured
        var errorDescription: String? { GoogleOAuthConfig.unconfiguredReason }
    }
}
