//
//  RoomIdentity.swift
//  presence-gate — thêm mới, không có trong MeetingBar gốc (Apache-2.0 §4(b)).
//
//  Danh tính của một phòng họp, rút từ URL. Đây là thứ phân biệt "đang họp"
//  với "đang ở ĐÚNG cuộc này" — tức là toàn bộ Quyết định B.
//

import Foundation

/// Khoá định danh một phòng họp, so sánh được giữa link trong lịch và URL
/// trong lịch sử trình duyệt.
struct RoomIdentity: Hashable, Equatable, Sendable {
    let service: String
    let code: String

    var key: String { "\(service):\(code)" }
}

enum RoomIdentityParser {
    /// Mã phòng Google Meet. CHẶT có chủ đích: `xxx-xxxx-xxx`.
    ///
    /// Không nới lỏng. Một pattern lỏng nuốt luôn `/home`, `/new`, `/reauth`
    /// và `/accounts/SetOSID?...` — và `meet.google.com/home` xuất hiện nhiều
    /// lần mỗi ngày trong lịch sử thật. Một lần khớp nhầm `home` làm cổng im
    /// cho **mọi** cuộc Meet trong ngày hôm đó.
    private static let meetCode = try! NSRegularExpression(
        pattern: #"^/([a-z]{3}-[a-z]{4}-[a-z]{3})(?:[/?#]|$)"#)

    /// Số phòng Zoom: 9–11 chữ số, trong path `/j/<id>` hoặc `/s/<id>`.
    private static let zoomCode = try! NSRegularExpression(
        pattern: #"^/[js]/(\d{9,11})"#)

    /// Trả về danh tính phòng, hoặc `nil` nếu URL không phải một phòng cụ thể.
    /// `nil` **không** nghĩa là lỗi — `meet.google.com/home` trả nil là đúng.
    static func parse(_ url: URL) -> RoomIdentity? {
        guard let host = url.host?.lowercased() else { return nil }
        let path = url.path
        let r = NSRange(path.startIndex..., in: path)

        if host.hasSuffix("meet.google.com") {
            guard let m = meetCode.firstMatch(in: path, range: r),
                  let g = Range(m.range(at: 1), in: path) else { return nil }
            return RoomIdentity(service: "meet", code: String(path[g]))
        }
        if host.hasSuffix("zoom.us") || host.contains(".zoom.") {
            guard let m = zoomCode.firstMatch(in: path, range: r),
                  let g = Range(m.range(at: 1), in: path) else { return nil }
            return RoomIdentity(service: "zoom", code: String(path[g]))
        }
        return nil
    }

    /// Phiên bản cho chuỗi URL thô lấy từ SQLite, nơi URL có thể méo.
    static func parse(_ raw: String) -> RoomIdentity? {
        guard let u = URL(string: raw) else { return nil }
        return parse(u)
    }
}
