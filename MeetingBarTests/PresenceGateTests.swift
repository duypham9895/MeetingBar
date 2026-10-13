//
//  PresenceGateTests.swift
//  MeetingBarTests
//
//  presence-gate — thêm mới, không có trong MeetingBar gốc (Apache-2.0 §4(b)).
//

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
    func presence(for _: RoomIdentity, window _: TimeInterval, now _: Date) -> Presence { verdict }
}

final class PresenceGateMergeTests: XCTestCase {
    private let url = URL(string: "https://meet.google.com/abc-defg-hij")!

    private func suppress(_ sources: [Presence]) -> Bool {
        PresenceGate(sources: sources.map { StubSource(verdict: $0) }, window: 900)
            .shouldSuppress(url: url).suppress
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
        let gate = PresenceGate(sources: [StubSource(verdict: .present(source: "a"))], window: 900)
        XCTAssertFalse(gate.shouldSuppress(url: URL(string: "https://meet.google.com/home")!).suppress)
    }
}
