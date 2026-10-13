//
//  MeetingContext.swift
//  presence-gate — thêm mới, không có trong MeetingBar gốc (Apache-2.0 §4(b)).
//
//  Cái mà cổng biết về cuộc họp sắp mở. Hai nguồn nhận dạng, và chúng KHÁC NHAU
//  về bản chất — đó là lý do file này tồn tại thay vì truyền một chuỗi:
//
//    · trình duyệt  nhận ra phòng bằng MÃ PHÒNG trong URL  → chính xác tuyệt đối
//    · app native   nhận ra phòng bằng CHỦ ĐỀ trên tiêu đề → khớp mờ, có thể sai
//
//  Đo được 2026-10-13: tiêu đề cửa sổ Zoom CHÍNH LÀ chủ đề cuộc họp, không phải
//  chuỗi cứng. Hai quan sát độc lập cùng một chuỗi:
//    dialog đặt lịch, trường Topic (mặc định) = "Duy Pham's Zoom Meeting"
//    cuộc họp đang chạy, AXTitle              = "Duy Pham's Zoom Meeting"
//  Và meeting ID (\d{9,11}) KHÔNG xuất hiện ở bất kỳ đâu trong cây AX.
//

import Foundation

struct MeetingContext: Sendable {
    /// Mã phòng rút từ link họp. `nil` khi link không mang mã nhận dạng được
    /// (Teams, Webex, hoặc một URL tuỳ chỉnh).
    let room: RoomIdentity?

    /// Tiêu đề sự kiện lịch. Dùng để khớp mờ với tiêu đề cửa sổ app native.
    let eventTitle: String

    /// Dạng chuẩn hoá để so sánh: NFC, thường hoá, gộp khoảng trắng.
    ///
    /// NFC là bắt buộc chứ không phải cho đẹp: bộ gõ tiếng Việt phát ra cả NFC
    /// lẫn NFD, và `"Đêm Đông"` là **8 code point ở NFC, 10 ở NFD** — cùng một
    /// tên nhìn thấy, hai chuỗi khác nhau, so sánh trượt.
    static func normalize(_ s: String) -> String {
        s.precomposedStringWithCanonicalMapping
            .lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}
