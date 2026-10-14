//
//  PresenceGateTests.swift
//  MeetingBarTests
//
//  presence-gate — thêm mới, không có trong MeetingBar gốc (Apache-2.0 §4(b)).
//

import Defaults
import XCTest

@testable import MeetingBar

final class RoomIdentityTests: XCTestCase {
    private func key(_ s: String) -> String? {
        RoomIdentityParser.parse(s)?.key
    }

    func testMeetRoomCodesAreRecognised() {
        XCTAssertEqual(key("https://meet.google.com/abc-defg-hij"), "meet:abc-defg-hij")
        XCTAssertEqual(key("https://meet.google.com/abc-defg-hij?authuser=0"), "meet:abc-defg-hij")
        XCTAssertEqual(key("https://meet.google.com/abc-defg-hij#x"), "meet:abc-defg-hij")
    }

    /// Mỗi dòng dưới đây là một false positive ĐÃ QUAN SÁT ĐƯỢC trong lịch sử thật
    /// của người dùng. Một lần khớp nhầm `/home` làm cổng im cho MỌI cuộc Meet
    /// trong ngày hôm đó — nên regex phải chặt, và phải có test giữ nó chặt.
    func testTrapsFromRealHistoryAreRejected() {
        XCTAssertNil(key("https://meet.google.com/home"))
        XCTAssertNil(key("https://meet.google.com/new"))
        XCTAssertNil(key("https://meet.google.com/reauth"))
        XCTAssertNil(key("https://meet.google.com/accounts/SetOSID?authuser=0&continue=x"))
        // MeetingProvider.swift gốc cho phép tiền tố _meet/ — chúng ta KHÔNG.
        XCTAssertNil(key("https://meet.google.com/_meet/abc-defg-hij"))
        // popup "Join with Google Meet" trong Google Calendar
        XCTAssertNil(key("https://calendar.google.com/event?x=Join+with+Google+Meet"))
    }

    func testZoomConferenceNumbers() {
        XCTAssertEqual(key("https://us02web.zoom.us/j/81234567890"), "zoom:81234567890")
        XCTAssertEqual(key("https://zoom.us/s/123456789"), "zoom:123456789")
        XCTAssertNil(key("https://zoom.us/j/1234"))          // quá ngắn
        XCTAssertNil(key("https://zoom.us/my/duypham"))      // PMI theo tên, không phải số
    }

    func testOtherServicesAreNotClaimed() {
        XCTAssertNil(key("https://teams.microsoft.com/l/meetup-join/x"))
        XCTAssertNil(key("https://example.com/abc-defg-hij"))
    }
}

// MARK: - Cổng hợp nhất

private struct StubSource: PresenceSource {
    let verdict: Presence
    func presence(for _: MeetingContext, window _: TimeInterval, now _: Date) -> Presence { verdict }
}

final class PresenceGateMergeTests: XCTestCase {
    private let url = URL(string: "https://meet.google.com/abc-defg-hij")!

    private func suppress(_ sources: [Presence]) -> Bool {
        PresenceGate(sources: sources.map { StubSource(verdict: $0) }, window: 900)
            .shouldSuppress(url: url, eventTitle: "Họp tuần").suppress
    }

    func testSilenceNeedsAtLeastOnePresentAndNoAbsent() {
        XCTAssertTrue(suppress([.present(source: "a")]))
        XCTAssertTrue(suppress([.present(source: "a"), .unknown]))
    }

    /// Bất đồng thật ⇒ MỞ. Mở thừa một tab là cái giá đúng bằng hiện trạng;
    /// im nhầm là lỡ họp và không hồi phục được. Hai hướng sai không đối xứng.
    func testDisagreementFailsOpen() {
        XCTAssertFalse(suppress([.present(source: "a"), .absent(source: "b")]))
        XCTAssertFalse(suppress([.absent(source: "b"), .present(source: "a")]))
    }

    func testNoEvidenceOpens() {
        XCTAssertFalse(suppress([]))
        XCTAssertFalse(suppress([.unknown, .unknown]))
        XCTAssertFalse(suppress([.absent(source: "b")]))
    }

    /// Link không rút được danh tính phòng thì cổng không có gì để so — phải MỞ,
    /// không được im "cho chắc".
    func testUnparseableLinkOpens() {
        // /home không rút được mã phòng VÀ không có tiêu đề ⇒ không có gì để nhận dạng.
        let gate = PresenceGate(sources: [StubSource(verdict: .present(source: "a"))], window: 900)
        XCTAssertFalse(
            gate.shouldSuppress(url: URL(string: "https://meet.google.com/home")!, eventTitle: "")
                .suppress)
    }
}

// MARK: - Dây nối: auto-join → cổng → sink
//
// Đây là test quan trọng nhất của Lát 1. Nó trả lời câu mà "BUILD SUCCEEDED"
// không trả lời được: cổng có THẬT SỰ nằm trên đường đi của auto-join không.
//
// Ban đầu tôi định kiểm bằng một cuộc họp thật. Không được: MeetingBar đọc lịch
// qua EventKit (`eventStoreProvider = "MacOS Calendar App"`), nên một sự kiện tạo
// bằng Google Calendar API phải chờ Lịch macOS đồng bộ — hàng chục phút, và không
// tất định. Nên cổng được TIÊM VÀO runner, và dây nối kiểm bằng 3 mili giây.

@MainActor
final class PresenceGateWiringTests: XCTestCase {
    private func autoJoinSettings() -> NotificationPlanningSettings {
        NotificationPlanningSettings(
            eventStart: .disabled,
            eventEnd: .disabled,
            fullscreen: .disabled,
            autoJoin: .init(enabled: true, offset: 180),
            scriptOnStart: .disabled,
            dismissedEventIDs: [],
            fullscreenNotificationsForEventsWithoutMeetingLink: false
        )
    }

    private func makeRunner(suppress: Bool) -> (NotificationActionRunner, FakeNotificationActionSink) {
        let sink = FakeNotificationActionSink()
        let runner = NotificationActionRunner(actionSink: sink)
        runner.presenceGate = { _, _ in (suppress, suppress ? "test: đã vào" : "test: chưa vào") }
        return (runner, sink)
    }

    /// Cổng nói IM ⇒ sink KHÔNG được gọi. Không có tab thứ hai.
    func testGateSuppressesAutoJoin() {
        let now = Date()
        let (runner, sink) = makeRunner(suppress: true)
        let evt = makeFakeEvent(
            id: "S", start: now.addingTimeInterval(60),
            end: now.addingTimeInterval(1860), withLink: true)

        runner.fireDueActions(events: [evt], settings: autoJoinSettings(), now: now)

        XCTAssertTrue(sink.actions.isEmpty, "cổng nói IM mà auto-join vẫn chạy")
        XCTAssertTrue(sink.attempts.isEmpty, "sink không được chạm tới khi cổng im")
    }

    /// Cổng nói MỞ ⇒ hành xử y hệt MeetingBar gốc.
    func testGateLetsAutoJoinThroughWhenAbsent() {
        let now = Date()
        let (runner, sink) = makeRunner(suppress: false)
        let evt = makeFakeEvent(
            id: "P", start: now.addingTimeInterval(60),
            end: now.addingTimeInterval(1860), withLink: true)

        runner.fireDueActions(events: [evt], settings: autoJoinSettings(), now: now)

        XCTAssertEqual(sink.actions.map(\.eventID), ["P"])
        XCTAssertEqual(sink.actions.map(\.kind), [.autoJoin])
    }

    /// Khi im, VẪN phải ghi processed.
    ///
    /// Nếu return sớm mà không ghi, `EventActionPolicy.evaluate` sẽ chạy lại với
    /// cùng `(id, lastModifiedDate)` ở MỌI tick, và cổng biến thành một vòng lặp
    /// đánh giá vô tận — mỗi tick là một lần đọc 5 file SQLite.
    func testSuppressionStillRecordsProcessed() {
        let now = Date()
        let (runner, sink) = makeRunner(suppress: true)
        let evt = makeFakeEvent(
            id: "R", start: now.addingTimeInterval(60),
            end: now.addingTimeInterval(1860), withLink: true)

        runner.fireDueActions(events: [evt], settings: autoJoinSettings(), now: now)
        // tick thứ hai: nếu lần đầu không ghi processed thì lần này cổng chạy lại
        runner.fireDueActions(events: [evt], settings: autoJoinSettings(), now: now)

        XCTAssertTrue(sink.actions.isEmpty)
        XCTAssertTrue(
            Defaults[.processedEventsForAutoJoin].contains { $0.id == "R" },
            "im lặng rồi mà không ghi processed ⇒ vòng lặp đánh giá mỗi tick")
    }
}


// MARK: - Tầng 2: khớp danh tính app native bằng CHỦ ĐỀ

final class AXTitleMatchTests: XCTestCase {
    private func m(_ win: String, _ evt: String) -> Bool {
        AXMeetingSource.titlesMatch(
            windowTitle: MeetingContext.normalize(win),
            eventTitle: MeetingContext.normalize(evt))
    }

    /// Tiêu đề cửa sổ Zoom CHÍNH LÀ chủ đề cuộc họp — đo được 2026-10-13.
    func testExactAndTruncatedTopicsMatch() {
        XCTAssertTrue(m("Weekly Product Sync", "Weekly Product Sync"))
        XCTAssertTrue(m("Weekly Product Sync", "Weekly Product Sync - Ringkas"))  // lịch có hậu tố
        XCTAssertTrue(m("[Only Reminder] UAT session", "UAT session"))            // lịch có tiền tố
    }

    /// NFC: bộ gõ tiếng Việt phát ra cả NFC lẫn NFD. Cùng tên nhìn thấy, khác byte.
    func testVietnameseNFCvsNFD() {
        let nfc = "Họp Đầu Tuần".precomposedStringWithCanonicalMapping
        let nfd = "Họp Đầu Tuần".decomposedStringWithCanonicalMapping
        XCTAssertNotEqual(nfc.unicodeScalars.count, nfd.unicodeScalars.count, "mẫu thử phải thật sự khác dạng")
        XCTAssertTrue(m(nfd, nfc))
        XCTAssertTrue(m(nfc, nfd))
    }

    func testCaseAndWhitespaceInsensitive() {
        XCTAssertTrue(m("  WEEKLY   PRODUCT  SYNC ", "weekly product sync"))
    }

    /// Chuỗi ngắn trùng nhau quá dễ — phải từ chối, nếu không cổng sẽ im nhầm.
    func testShortTitlesDoNotMatch() {
        XCTAssertFalse(m("Họp", "Họp tuần"))
        XCTAssertFalse(m("Sync", "Daily Sync"))
    }

    func testUnrelatedTitlesDoNotMatch() {
        XCTAssertFalse(m("Zoom Workplace", "Weekly Product Sync"))
        XCTAssertFalse(m("Interview — Backend", "Weekly Product Sync"))
    }
}

// MARK: - Di cư cấu hình: nguồn phải là container CŨ, không phải chính mình

final class SandboxContainerMigrationTests: XCTestCase {
    /// Bản fork đã đổi bundle ID sang `com.duypham.meeting-menubar` vì App ID
    /// `leits.MeetingBar` thuộc team KGH289N6T8 và không ký được bằng chứng chỉ của
    /// người fork. Kể từ lúc đó, `Bundle.main.bundleIdentifier` KHÔNG còn là nơi chứa
    /// cấu hình cũ nữa.
    ///
    /// Chế độ hỏng mà test này canh đã xảy ra thật một lần: di cư chạy, không báo lỗi,
    /// mang đúng 0 khoá, và `automaticEventJoin` rơi về `false` — tức là tính năng mà
    /// cả dự án tồn tại để sửa thì tắt ngấm, không một dòng cảnh báo.
    func testMigrationReadsLegacyContainerNotOwnBundleID() throws {
        let url = try XCTUnwrap(SandboxContainerMigration.containerPlistURL)
        let path = url.path

        XCTAssertTrue(
            path.hasSuffix("Library/Containers/leits.MeetingBar/Data/Library/Preferences/leits.MeetingBar.plist"),
            "nguồn di cư phải là container của bản App Store cũ, nhận được: \(path)")

        // Chiều ngược lại mới là chiều bắt được lỗi: một bản cài nối cả hai ID lại vẫn
        // "chứa" chuỗi mong đợi ở trên, nhưng trỏ vào thư mục không tồn tại.
        let own = try XCTUnwrap(Bundle.main.bundleIdentifier)
        XCTAssertFalse(
            path.contains(own),
            "đường dẫn không được chứa bundle ID của app đang chạy (\(own)) — nhận được: \(path)")
    }
}
