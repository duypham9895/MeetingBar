// Probe.swift — đo MỘT LẦN, trong một cuộc họp thật, bốn câu hỏi của S0.5.
// Chỉ ĐỌC. Không inject, không click, không ghi gì ra ngoài stdout.
import AVFoundation
import AppKit
import ApplicationServices
import CoreMediaIO
import Foundation

func h(_ s: String) { print("\n── \(s) " + String(repeating: "─", count: max(0, 60 - s.count))) }

// ── Q4: cờ camera đang-chạy có đọc được KHÔNG CẦN QUYỀN không ────────────
h("Q4  camera in-use (zero-permission?)")
print("AVCaptureDevice.authorizationStatus(.video) TRƯỚC = \(AVCaptureDevice.authorizationStatus(for: .video).rawValue)  (0=notDetermined 3=authorized)")
var allow: UInt32 = 1
var addr = CMIOObjectPropertyAddress(
    mSelector: CMIOObjectPropertySelector(kCMIOHardwarePropertyAllowScreenCaptureDevices),
    mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeGlobal),
    mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMain))
CMIOObjectSetPropertyData(CMIOObjectID(kCMIOObjectSystemObject), &addr, 0, nil, UInt32(MemoryLayout.size(ofValue: allow)), &allow)

var devAddr = CMIOObjectPropertyAddress(
    mSelector: CMIOObjectPropertySelector(kCMIOHardwarePropertyDevices),
    mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeGlobal),
    mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMain))
var size: UInt32 = 0
CMIOObjectGetPropertyDataSize(CMIOObjectID(kCMIOObjectSystemObject), &devAddr, 0, nil, &size)
let n = Int(size) / MemoryLayout<CMIOObjectID>.size
var devs = [CMIOObjectID](repeating: 0, count: max(n, 1))
CMIOObjectGetPropertyData(CMIOObjectID(kCMIOObjectSystemObject), &devAddr, 0, nil, size, &size, &devs)
for d in devs where d != 0 {
    var nameAddr = CMIOObjectPropertyAddress(
        mSelector: CMIOObjectPropertySelector(kCMIOObjectPropertyName),
        mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeGlobal),
        mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMain))
    var cf: CFString = "" as CFString
    var s2 = UInt32(MemoryLayout<CFString>.size)
    CMIOObjectGetPropertyData(d, &nameAddr, 0, nil, s2, &s2, &cf)
    var runAddr = CMIOObjectPropertyAddress(
        mSelector: CMIOObjectPropertySelector(kCMIODevicePropertyDeviceIsRunningSomewhere),
        mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeWildcard),
        mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMain))
    var running: UInt32 = 0
    var s3 = UInt32(MemoryLayout<UInt32>.size)
    let st = CMIOObjectGetPropertyData(d, &runAddr, 0, nil, s3, &s3, &running)
    print("  \(cf)  →  isRunningSomewhere=\(running)  OSStatus=\(st)")
}
print("authorizationStatus SAU = \(AVCaptureDevice.authorizationStatus(for: .video).rawValue)   ← nếu vẫn 0 thì ĐỌC ĐƯỢC KHÔNG CẦN QUYỀN")

// ── Q1: cây AX của các app họp — có AXWindow không, title mang gì ────────
h("Q1  cây Accessibility của app họp")
guard AXIsProcessTrusted() else {
    print("  ⛔ tiến trình này CHƯA có quyền Accessibility.")
    print("     System Settings → Privacy & Security → Accessibility → bật Terminal/iTerm, rồi chạy lại.")
    exit(0)
}
let targets = ["zoom.us", "Microsoft Teams", "Google Chrome", "Safari", "Arc", "Slack"]
for app in NSWorkspace.shared.runningApplications {
    guard let name = app.localizedName, targets.contains(where: { name.contains($0) }) else { continue }
    print("\n  ▸ \(name)  (pid \(app.processIdentifier), bundle \(app.bundleIdentifier ?? "?"))")
    let ax = AXUIElementCreateApplication(app.processIdentifier)
    var wins: CFTypeRef?
    let r = AXUIElementCopyAttributeValue(ax, kAXWindowsAttribute as CFString, &wins)
    guard r == .success, let list = wins as? [AXUIElement], !list.isEmpty else {
        print("    KHÔNG có AXWindow (AXError \(r.rawValue))  ← screenpipe nói đúng cho app này")
        continue
    }
    for (i, w) in list.enumerated() {
        var t: CFTypeRef?
        AXUIElementCopyAttributeValue(w, kAXTitleAttribute as CFString, &t)
        print("    [\(i)] title = \"\(t as? String ?? "<nil>")\"")
        // quét nông tìm nút rời cuộc họp — tín hiệu DUY NHẤT đáng tin (screenpipe)
        var kids: CFTypeRef?
        if AXUIElementCopyAttributeValue(w, kAXChildrenAttribute as CFString, &kids) == .success,
           let cs = kids as? [AXUIElement] {
            var found: [String] = []
            func walk(_ e: AXUIElement, _ d: Int) {
                if d > 6 { return }
                var ttl: CFTypeRef?
                AXUIElementCopyAttributeValue(e, kAXTitleAttribute as CFString, &ttl)
                if let s = ttl as? String {
                    let l = s.lowercased()
                    for k in ["leave", "end call", "hang up", "rời", "kết thúc"] where l.contains(k) {
                        found.append(s); break
                    }
                }
                var c: CFTypeRef?
                if AXUIElementCopyAttributeValue(e, kAXChildrenAttribute as CFString, &c) == .success,
                   let arr = c as? [AXUIElement] { for x in arr.prefix(40) { walk(x, d + 1) } }
            }
            for c in cs.prefix(20) { walk(c, 0) }
            print("        nút rời-họp tìm thấy: \(found.isEmpty ? "KHÔNG CÓ" : found.joined(separator: " | "))")
        }
    }
}
