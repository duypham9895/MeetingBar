//
//  PresenceGate.swift
//  presence-gate — thêm mới, không có trong MeetingBar gốc (Apache-2.0 §4(b)).
//
//  Cổng đứng trước auto-join: máy này đã ở trong ĐÚNG cuộc họp sắp mở chưa?
//
//  Quyết định B (Duy, 2026-10-13): đã ở trong đúng cuộc đó ⇒ IM HẲN, không notify.
//  Quyết định C: không setup, không quyền mới.
//

import Foundation

/// Ba giá trị, không bao giờ hai.
///
/// Phần lớn lỗi thiết kế ở đây đến từ việc nhét *"tôi không có thẩm quyền"*
/// chung ô với *"tôi khẳng định là chưa"*. Tách ra thì quy tắc hợp nhất
/// trở nên tầm thường và không ai cãi được.
enum Presence: Equatable, Sendable {
    case present(source: String)
    case absent(source: String)
    case unknown
}

protocol PresenceSource: Sendable {
    func presence(for room: RoomIdentity, window: TimeInterval, now: Date) -> Presence
}

/// TẦNG 1 — lịch sử trình duyệt. Zero permission.
struct BrowserHistorySource: PresenceSource {
    func presence(for room: RoomIdentity, window: TimeInterval, now: Date) -> Presence {
        let visits = BrowserHistoryStore.roomVisits(since: now.addingTimeInterval(-window))
        if let hit = visits.first(where: { $0.room == room }) {
            return .present(source: "history:\(hit.browser)")
        }
        // KHÔNG BAO GIỜ .absent.
        // Lịch sử chứng minh được *đã mở*, không chứng minh được *chưa mở*:
        // một tab mở từ hai tiếng trước trông giống hệt một tab đã đóng, và
        // một phòng vào từ máy khác không để lại gì ở đây. Một `.absent` sai
        // từ tầng này sẽ vô hiệu hoá một `.present` đúng từ tầng kia.
        return .unknown
    }
}

struct PresenceGate: Sendable {
    let sources: [PresenceSource]
    let window: TimeInterval

    /// Ngân sách thời gian. Ở cấu hình MẶC ĐỊNH của MeetingBar
    /// (`automaticEventJoinTime = .atStart = 5s`) cửa sổ bắn chỉ rộng 20 giây,
    /// nên cổng phải quyết nhanh hơn thế nhiều bậc.
    static let budget: TimeInterval = 0.150

    init(sources: [PresenceSource] = [BrowserHistorySource()], window: TimeInterval) {
        self.sources = sources
        self.window = window
    }

    /// `true` ⇒ im hẳn. Quy tắc hợp nhất, một dòng:
    ///
    ///     IM  ⇔  có ÍT NHẤT MỘT nguồn nói `present`  VÀ  KHÔNG nguồn nào nói `absent`
    ///
    /// Mọi trường hợp còn lại ⇒ MỞ, tức hành xử y hệt MeetingBar gốc.
    /// **Thất bại luôn MỞ.** Mở thừa một tab là cái giá đúng bằng hiện trạng
    /// hôm nay; im nhầm là lỡ họp và không hồi phục được.
    func shouldSuppress(url: URL, now: Date = Date()) -> (suppress: Bool, reason: String) {
        guard let room = RoomIdentityParser.parse(url) else {
            return (false, "không rút được danh tính phòng từ link")
        }
        let deadline = Date().addingTimeInterval(Self.budget)
        var present: String?
        for s in sources {
            if Date() > deadline { return (false, "quá ngân sách \(Int(Self.budget * 1000))ms") }
            switch s.presence(for: room, window: window, now: now) {
            case .absent(let src): return (false, "bị phủ quyết bởi \(src)")
            case .present(let src): present = present ?? src
            case .unknown: continue
            }
        }
        guard let src = present else { return (false, "không nguồn nào thấy \(room.key)") }
        return (true, "đã vào \(room.key) — \(src)")
    }
}
