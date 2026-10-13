//
//  AXMeetingSource.swift
//  presence-gate — thêm mới, không có trong MeetingBar gốc (Apache-2.0 §4(b)).
//
//  TẦNG 2 — app họp NATIVE (Zoom, Teams, Webex, Slack…), thứ mà lịch sử trình
//  duyệt không bao giờ nhìn thấy.
//
//  Vì sao phải đọc cây Accessibility chứ không có đường nào rẻ hơn — đã kiểm
//  từng cửa và ghi lại ở gates/00-discovery/PRODUCT-BRIEF.md:
//    · Zoom:  không local API · không port lắng nghe · DB mã hoá SQLCipher ·
//             không AppleScript dictionary (sdef trả lỗi -192)
//    · Teams: TỪNG có WebSocket ws://localhost:8124 phát thẳng isInMeeting,
//             Microsoft gỡ vĩnh viễn 30/06/2026 (MC1266901), không thay thế
//    · pgrep CptHost: heuristic được trích dẫn khắp nơi, và nó CHẾT trên Zoom
//             7.1.9 — không xuất hiện kể cả khi đang họp. caphost thì có mặt
//             cả lúc idle, nên dùng nó là false-positive 100%.
//
//  Quyết định D-1: thiếu quyền Accessibility ⇒ trả `.unknown`, im lặng lùi về
//  Tầng 1. Không nhắc, không chặn, không kêu.
//

import AppKit
import ApplicationServices
import Foundation

struct AXMeetingSource: PresenceSource {
    /// Những app có thể đang giữ một cuộc họp. Tên khớp theo tiền tố của
    /// `localizedName` vì Zoom đổi tên hiển thị giữa các bản ("zoom.us" →
    /// "Zoom Workplace").
    private static let meetingApps = ["zoom.us", "Zoom", "Microsoft Teams", "Webex", "Slack"]

    /// Tiêu đề cửa sổ KHÔNG phải cuộc họp — cửa sổ chính, cài đặt, chat.
    /// Danh sách này là thứ phân biệt "app đang mở" với "đang trong cuộc họp",
    /// và nó đo được: lúc idle Zoom có đúng một cửa sổ tên "Zoom Workplace".
    private static let notAMeeting = [
        "zoom workplace", "settings", "preferences", "chat", "contacts",
        "microsoft teams", "webex", "slack",
    ]

    func presence(for ctx: MeetingContext, window _: TimeInterval, now _: Date) -> Presence {
        // Quyết định D-1: không có quyền thì im lặng lùi về Tầng 1.
        guard AXIsProcessTrusted() else { return .unknown }

        let wanted = MeetingContext.normalize(ctx.eventTitle)
        guard !wanted.isEmpty else { return .unknown }

        var sawMeetingApp = false
        for app in NSWorkspace.shared.runningApplications {
            guard let name = app.localizedName,
                  Self.meetingApps.contains(where: { name.hasPrefix($0) || name == $0 })
            else { continue }
            sawMeetingApp = true

            let ax = AXUIElementCreateApplication(app.processIdentifier)
            var raw: CFTypeRef?
            guard AXUIElementCopyAttributeValue(ax, kAXWindowsAttribute as CFString, &raw) == .success,
                  let windows = raw as? [AXUIElement]
            else { continue }

            for w in windows {
                var t: CFTypeRef?
                guard AXUIElementCopyAttributeValue(w, kAXTitleAttribute as CFString, &t) == .success,
                      let title = t as? String, !title.isEmpty
                else { continue }
                let norm = MeetingContext.normalize(title)
                if Self.notAMeeting.contains(norm) { continue }

                if Self.titlesMatch(windowTitle: norm, eventTitle: wanted) {
                    return .present(source: "ax:\(name)")
                }
            }
        }

        // Thấy app họp đang chạy nhưng KHÔNG cửa sổ nào khớp — vẫn là `.unknown`,
        // KHÔNG phải `.absent`.
        //
        // Lý do: người dùng có thể đang họp trong một cửa sổ mà AX không phơi ra,
        // hoặc Zoom giấu thanh điều khiển (MuteDeck đã trả giá đúng chỗ này: detect
        // của họ phụ thuộc setting "Always show meeting controls" của chính Zoom).
        // Một `.absent` sai từ tầng này sẽ **phủ quyết** một `.present` đúng từ
        // Tầng 1 và làm cổng mở tab thừa — hoặc tệ hơn, nếu logic đảo chiều, làm
        // nó im nhầm.
        _ = sawMeetingApp
        return .unknown
    }

    /// Khớp mờ hai chiều.
    ///
    /// Zoom cắt bớt chủ đề dài, và người tổ chức hay thêm tiền tố (`[Only Reminder]`,
    /// `Re:`) vào tiêu đề lịch. Nên khớp chính xác là quá chặt, còn khớp theo từ rời
    /// là quá lỏng. Chọn: một chuỗi chứa chuỗi kia, và phần chung phải đủ dài để
    /// không phải trùng ngẫu nhiên.
    static func titlesMatch(windowTitle: String, eventTitle: String) -> Bool {
        if windowTitle == eventTitle { return true }
        let shorter = min(windowTitle.count, eventTitle.count)
        // Dưới 8 ký tự thì "họp" khớp với "họp tuần" — quá dễ trùng.
        guard shorter >= 8 else { return false }
        return windowTitle.contains(eventTitle) || eventTitle.contains(windowTitle)
    }
}
