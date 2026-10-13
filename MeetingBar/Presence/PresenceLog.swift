//
//  PresenceLog.swift
//  presence-gate — thêm mới, không có trong MeetingBar gốc (Apache-2.0 §4(b)).
//
//  Nhật ký CỤC BỘ. Không mạng, không analytics, không bao giờ rời máy do app này.
//
//  Vì sao tồn tại: Quyết định B là "im hẳn". Im hoàn toàn nghĩa là sáu tuần sau
//  không ai phân biệt được "nó chạy đúng" với "nó hỏng" — và chế độ hỏng của cổng
//  này là IM LẶNG, tức lỡ họp. Không có nhật ký thì một lần chặn sai là một sự
//  kiện không để lại dấu vết nào.
//
//  Vì sao HASH chứ không ghi mã phòng nguyên văn (bất đồng [2], chốt theo Legal):
//  link Meet là bearer credential — ai cầm link là vào được phòng. Theo Quyết định A,
//  file này sẽ nằm trên máy ĐỒNG NGHIỆP và chứa link họp của CÔNG TY HỌ. "Không gửi
//  ra mạng" không chặn được sysdiagnose hay Time Machine gom nó đi.
//

import CryptoKit
import Foundation
import os

enum PresenceLog {
    private static let queue = DispatchQueue(label: "presence-gate.log")

    static var fileURL: URL? {
        FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first?
            .appendingPathComponent("Logs/presence-gate.log")
    }

    /// 8 ký tự hex đầu của sha256 — đủ để nối hai dòng nhật ký nói về cùng một
    /// phòng, không đủ để ai đọc được file suy ngược ra link vào họp.
    static func tag(_ key: String) -> String {
        let d = SHA256.hash(data: Data(key.utf8))
        return d.compactMap { String(format: "%02x", $0) }.joined().prefix(8).description
    }

    private static let stamp: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return f
    }()

    static func write(_ line: String) {
        queue.async {
            guard let url = fileURL else { return }
            try? FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            let row = "\(stamp.string(from: Date()))  \(line)\n"
            guard let data = row.data(using: .utf8) else { return }
            if let h = try? FileHandle(forWritingTo: url) {
                defer { try? h.close() }
                _ = try? h.seekToEnd()
                try? h.write(contentsOf: data)
            } else {
                try? data.write(to: url)
            }
        }
    }

    /// Chạy MỘT LẦN lúc khởi động. Đây là tuyến phòng thủ duy nhất chống lại chế
    /// độ hỏng tệ nhất của cả tính năng: cổng không đọc được gì (sandbox bật lại,
    /// macOS siết TCC, người dùng đổi trình duyệt) nên **luôn** kết luận "chưa vào"
    /// và không bao giờ im — hỏng mà không ai biết, vì "không im" trông y hệt
    /// "chưa tới lúc im".
    static func selfCheck() {
        let since = Date().addingTimeInterval(-7 * 86400)
        let v = BrowserHistoryStore.roomVisits(since: since)
        var byBrowser: [String: Int] = [:]
        for x in v { byBrowser[x.browser, default: 0] += 1 }
        let detail = byBrowser.isEmpty
            ? "KHÔNG ĐỌC ĐƯỢC TRÌNH DUYỆT NÀO"
            : byBrowser.sorted { $0.key < $1.key }.map { "\($0.key)=\($0.value)" }.joined(separator: " ")
        write("selfcheck  \(v.count) lượt/7 ngày  ·  \(detail)")
        if v.isEmpty {
            write("selfcheck  ⚠ cổng sẽ KHÔNG BAO GIỜ im — kiểm sandbox, TCC, đường dẫn profile")
        }
    }
}
