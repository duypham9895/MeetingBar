//
//  SandboxContainerMigration.swift
//  presence-gate — thêm mới, không có trong MeetingBar gốc (Apache-2.0 §4(b)).
//
//  Nhặt lại cấu hình mà việc GỠ SANDBOX đã bỏ lại phía sau.
//
//  MeetingBar gốc chạy trong App Sandbox, nên UserDefaults của nó nằm ở
//      ~/Library/Containers/<bundle-id>/Data/Library/Preferences/<bundle-id>.plist
//  Bản fork này bỏ sandbox (Quyết định A, để dùng được Accessibility), nên nó đọc
//      ~/Library/Preferences/<bundle-id>.plist
//  — một kho KHÁC, và nó trống.
//
//  Hậu quả nếu không có file này, đã quan sát thật 2026-10-13: người dùng cài bản fork
//  thấy một app trắng tinh. Onboarding chạy lại, lịch đã chọn biến mất, và
//  `automaticEventJoin` rơi về mặc định `false` — tức là **chính tính năng mà cả dự án
//  này tồn tại để sửa thì không chạy**, mà không báo gì.
//
//  Chế độ hỏng đó im lặng tuyệt đối: app vẫn mở, vẫn hiện lịch, chỉ là không bao giờ
//  auto-join. Tôi mất một vòng debug mới tìm ra, và chỉ tìm ra nhờ in giá trị settings
//  lúc chạy thay vì tin vào `defaults read`.
//

import Foundation
import os

enum SandboxContainerMigration {
    private static let marker = "presenceGateDidMigrateFromSandboxContainer"

    /// Những khoá KHÔNG được mang sang: chúng mô tả trạng thái của bản cũ,
    /// không phải lựa chọn của người dùng.
    private static let skip: Set<String> = [
        marker,
        "NSWindow Frame",            // tiền tố — xử lý riêng bên dưới
    ]

    static var containerPlistURL: URL? {
        guard let bundleID = Bundle.main.bundleIdentifier else { return nil }
        return FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Containers/\(bundleID)/Data/Library/Preferences/\(bundleID).plist")
    }

    /// Chạy MỘT LẦN, càng sớm càng tốt, TRƯỚC khi bất cứ gì đọc `AppSettings`.
    ///
    /// Nguyên tắc: **không bao giờ ghi đè giá trị đã có.** Nếu người dùng đã chỉnh gì đó
    /// trong bản fork rồi thì lựa chọn mới thắng; di cư chỉ lấp chỗ trống.
    @discardableResult
    static func runIfNeeded() -> Int {
        let std = UserDefaults.standard
        guard !std.bool(forKey: marker) else { return 0 }

        guard let url = containerPlistURL,
              FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              let old = try? PropertyListSerialization.propertyList(
                  from: data, options: [], format: nil) as? [String: Any]
        else {
            // Không có container = cài mới tinh, không phải lỗi. Đánh dấu để khỏi tìm lại.
            std.set(true, forKey: marker)
            PresenceLog.write("migrate   không có container sandbox để di cư (cài mới)")
            return 0
        }

        var moved = 0
        for (key, value) in old {
            if skip.contains(key) || key.hasPrefix("NSWindow Frame") { continue }
            if std.object(forKey: key) != nil { continue }   // đã có thì giữ nguyên
            std.set(value, forKey: key)
            moved += 1
        }
        std.set(true, forKey: marker)
        PresenceLog.write("migrate   mang \(moved)/\(old.count) khoá từ container sandbox sang")
        MeetingBarLogger.lifecycle.info("presence-gate: migrated \(moved) defaults from sandbox container")
        return moved
    }
}
