// Câu hỏi: Accessibility API có đọc được URL + tiêu đề tab của trình duyệt không?
// Nếu CÓ  → một quyền Accessibility phủ mọi trình duyệt + mọi app họp.
// Nếu KHÔNG → phải dùng AppleScript ⇒ một dialog Automation cho MỖI trình duyệt.
import AppKit
import ApplicationServices

func attr(_ e: AXUIElement, _ k: String) -> Any? {
    var v: CFTypeRef?
    return AXUIElementCopyAttributeValue(e, k as CFString, &v) == .success ? v : nil
}

guard AXIsProcessTrusted() else { print("⛔ chưa có quyền Accessibility"); exit(1) }

let want = ["Google Chrome", "Safari", "Brave Browser", "Vivaldi", "zoom.us", "Discord"]
for app in NSWorkspace.shared.runningApplications {
    guard let n = app.localizedName, want.contains(where: { n.contains($0) }) else { continue }
    print("\n▸ \(n)  pid=\(app.processIdentifier)")
    let ax = AXUIElementCreateApplication(app.processIdentifier)

    guard let wins = attr(ax, kAXWindowsAttribute as String) as? [AXUIElement], !wins.isEmpty else {
        print("   KHÔNG có AXWindow.  AXRole gốc = \(attr(ax, kAXRoleAttribute as String) ?? "nil")")
        if let mb = attr(ax, kAXMenuBarAttribute as String) {
            print("   nhưng CÓ AXMenuBar: \(mb)   ← khớp với mô tả của screenpipe về Zoom")
        }
        continue
    }
    print("   số AXWindow = \(wins.count)")
    for (i, w) in wins.enumerated().prefix(4) {
        print("   [\(i)] AXTitle = \"\(attr(w, kAXTitleAttribute as String) as? String ?? "<nil>")\"")
        // tìm AXWebArea và hỏi URL — đây là câu hỏi thật
        var hits = 0
        func walk(_ e: AXUIElement, _ d: Int) {
            if d > 10 || hits > 3 { return }
            let role = attr(e, kAXRoleAttribute as String) as? String ?? ""
            if role == "AXWebArea" {
                hits += 1
                let url = attr(e, "AXURL")
                let t = attr(e, kAXTitleAttribute as String) as? String ?? "<nil>"
                print("        AXWebArea #\(hits)  AXURL = \(url.map { "\($0)" } ?? "<KHÔNG ĐỌC ĐƯỢC>")")
                print("                      AXTitle = \"\(t)\"")
                return
            }
            if let cs = attr(e, kAXChildrenAttribute as String) as? [AXUIElement] {
                for c in cs.prefix(25) { walk(c, d + 1) }
            }
        }
        walk(w, 0)
        if hits == 0 { print("        (không tìm thấy AXWebArea trong 10 tầng)") }
    }
}
