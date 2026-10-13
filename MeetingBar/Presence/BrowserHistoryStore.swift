//
//  BrowserHistoryStore.swift
//  presence-gate — thêm mới, không có trong MeetingBar gốc (Apache-2.0 §4(b)).
//
//  Đọc lịch sử Chromium. Zero permission — đã đo bằng app bundle có danh tính
//  TCC riêng, kèm hai nhóm đối chứng bị chặn (gates/01-spec/TCC-CLEAN-MEASURE.md).
//
//  Safari CỐ Ý không có mặt ở đây: nó đòi Full Disk Access (một toggle tay ⇒
//  vi phạm Quyết định C) và đổi lại 0 lượt Meet trong 102.522 lượt duyệt thật.
//

import Foundation
import SQLite3

struct RoomVisit: Sendable {
    let room: RoomIdentity
    let at: Date
    let browser: String
}

enum BrowserHistoryStore {
    /// Chênh lệch giữa epoch Chromium (1601-01-01) và epoch Unix.
    private static let chromiumEpochOffset: TimeInterval = 11_644_473_600

    private static let profiles: [(name: String, relative: String)] = [
        ("Vivaldi", "Vivaldi"),
        ("Chrome", "Google/Chrome"),
        ("Brave", "BraveSoftware/Brave-Browser"),
        ("Edge", "Microsoft Edge"),
        ("Arc", "Arc/User Data"),
    ]

    /// Mọi lượt vào phòng họp trong `[since, now]`, gộp từ mọi trình duyệt.
    ///
    /// **Mọi lỗi đều trả mảng rỗng cho trình duyệt đó, không bao giờ ném.**
    /// Một lỗi đọc không được phép biến thành một quyết định im lặng — xem
    /// `PresenceGate`, nơi "không có dữ liệu" nghĩa là `.unknown`, nghĩa là MỞ.
    static func roomVisits(since: Date) -> [RoomVisit] {
        let support = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask).first
        guard let support else { return [] }

        var all: [RoomVisit] = []
        for (name, rel) in profiles {
            let root = support.appendingPathComponent(rel)
            guard let dirs = try? FileManager.default.contentsOfDirectory(
                at: root, includingPropertiesForKeys: nil) else { continue }
            // "Default", "Profile 1", "Profile 2"… — Duy có thể đổi profile bất cứ lúc nào
            for d in dirs where d.lastPathComponent == "Default"
                || d.lastPathComponent.hasPrefix("Profile ") {
                all += visits(in: d.appendingPathComponent("History"),
                              browser: "\(name)/\(d.lastPathComponent)", since: since)
            }
        }
        return all
    }

    private static func visits(in db: URL, browser: String, since: Date) -> [RoomVisit] {
        guard FileManager.default.fileExists(atPath: db.path) else { return [] }

        // KHÔNG mở file gốc. Trình duyệt đang chạy giữ khoá ghi, và một
        // Vivaldi thoát không sạch còn để lại SingletonLock. Chép ra rồi đọc.
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent("pg-\(UUID().uuidString).db")
        defer { try? FileManager.default.removeItem(at: tmp) }
        guard (try? FileManager.default.copyItem(at: db, to: tmp)) != nil else { return [] }

        var handle: OpaquePointer?
        guard sqlite3_open_v2(tmp.path, &handle, SQLITE_OPEN_READONLY, nil) == SQLITE_OK else {
            sqlite3_close(handle); return []
        }
        defer { sqlite3_close(handle) }

        // visits JOIN urls — KHÔNG dùng urls.last_visit_time: cột đó chỉ giữ
        // lần CUỐI nên gộp mất mọi lần lặp (đo thật: 32 so với 96, chênh 3×),
        // mà lần lặp chính là cái ta đang đi tìm.
        let cutoff = (since.timeIntervalSince1970 + chromiumEpochOffset) * 1_000_000
        let sql = """
            SELECT u.url, v.visit_time
            FROM visits v JOIN urls u ON v.url = u.id
            WHERE v.visit_time >= ?
            """
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(handle, sql, -1, &stmt, nil) == SQLITE_OK else { return [] }
        defer { sqlite3_finalize(stmt) }
        sqlite3_bind_double(stmt, 1, cutoff)

        var out: [RoomVisit] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            guard let c = sqlite3_column_text(stmt, 0) else { continue }
            let raw = String(cString: c)
            guard let room = RoomIdentityParser.parse(raw) else { continue }
            let micros = sqlite3_column_double(stmt, 1)
            out.append(RoomVisit(
                room: room,
                at: Date(timeIntervalSince1970: micros / 1_000_000 - chromiumEpochOffset),
                browser: browser))
        }
        return out
    }
}
