// make-icons.swift — sinh toàn bộ icon của bản fork từ MỘT nguồn hình học.
//
// Chạy:  make icons        (hoặc:  swift Scripts/make-icons.swift <đường-dẫn-Assets.xcassets>)
//
// Vì sao sinh bằng code thay vì vẽ trong app đồ hoạ:
//
//   1. MỘT nguồn hình học cho CẢ SVG lẫn PNG. Icon thanh menu là SVG (template, macOS tự
//      nhuộm theo nền sáng/tối), icon Dock là 10 file PNG. Vẽ tay hai đường là hai hình sẽ
//      trôi khỏi nhau sau vài lần sửa. Ở đây cả hai cùng gọi framePath() và vPath().
//
//   2. Nét V phải chuyển thành ĐƯỜNG BAO TÔ ĐẶC, không để dạng stroke. Bộ nhập SVG của
//      asset catalog chỉ hỗ trợ một tập con của SVG, và stroke là chỗ rụng âm thầm — ảnh
//      vẫn biên dịch, chỉ là nét biến mất. Hai file SVG gốc của MeetingBar cũng chỉ dùng
//      path tô đặc, không phải ngẫu nhiên. CGPath.copy(strokingWithWidth:) lo việc này.
//
//   3. Đổi màu nhấn = sửa đúng một hằng số `accent` rồi chạy lại.
//
// Vì sao hình là chữ V trong khung lịch:
//   Đo ở 16px — kích thước THẬT trên thanh menu — bốn phương án khác đều hỏng. Bỏ lưới ô
//   ngày thì khung bo góc đọc ra "máy ảnh"; giữ lưới rồi thêm huy hiệu thì nhoè thành một
//   vệt; tô đặc ô giữa thì không phân biệt nổi với bản gốc. Chỉ bóng chữ V đọc được tức
//   thì. Thanh menu của máy đích vốn đã có sẵn một ô-vuông-tick và một ô-ngày-số, nên hai
//   hướng hiển nhiên đó cũng bị loại vì trùng hàng xóm.

import AppKit
import CoreGraphics

// MARK: - Hình học, dùng chung

/// Khung lịch của MeetingBar gốc: một chữ nhật bo góc bị khoét ruột theo even-odd.
/// Dải đặc còn lại phía trên chính là gáy lịch. Giữ nguyên để bản fork cùng dòng dõi.
func framePath() -> CGPath {
    let p = CGMutablePath()
    p.addPath(CGPath(roundedRect: CGRect(x: 0, y: 0, width: 16, height: 16),
                     cornerWidth: 2.75, cornerHeight: 2.75, transform: nil))
    // Toạ độ gốc trong SVG là y-xuống 4.08…14.44; CoreGraphics y-lên nên thành 1.56…11.92.
    p.addPath(CGPath(roundedRect: CGRect(x: 1.44, y: 1.56, width: 13.12, height: 10.36),
                     cornerWidth: 1.15, cornerHeight: 1.15, transform: nil))
    return p
}

func vPath(width w: CGFloat) -> CGPath {
    let l = CGMutablePath()
    l.move(to: CGPoint(x: 4.6, y: 9.6))
    l.addLine(to: CGPoint(x: 8.0, y: 4.0))
    l.addLine(to: CGPoint(x: 11.4, y: 9.6))
    return l.copy(strokingWithWidth: w, lineCap: .round, lineJoin: .round, miterLimit: 10)
}

/// Chấm trạng thái, nằm trên gáy lịch. Gáy đã tô đặc nên chấm phải là LỖ KHOÉT — tô đen
/// lên đen là vô hình, và template rendering xoá luôn mọi khác biệt màu.
func dotPath() -> CGPath {
    CGPath(ellipseIn: CGRect(x: 11.6, y: 12.7, width: 2.6, height: 2.6), transform: nil)
}

// MARK: - Xuất SVG

func svgData(_ path: CGPath) -> String {
    var out = ""
    var flip = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 16)   // CG y-lên -> SVG y-xuống
    let flipped = path.copy(using: &flip)!
    func f(_ v: CGFloat) -> String {
        let r = (v * 1000).rounded() / 1000
        return r == r.rounded() ? String(Int(r)) : String(Double(r))
    }
    flipped.applyWithBlock { e in
        let p = e.pointee.points
        switch e.pointee.type {
        case .moveToPoint:         out += "M\(f(p[0].x)) \(f(p[0].y))"
        case .addLineToPoint:      out += "L\(f(p[0].x)) \(f(p[0].y))"
        case .addQuadCurveToPoint: out += "Q\(f(p[0].x)) \(f(p[0].y)) \(f(p[1].x)) \(f(p[1].y))"
        case .addCurveToPoint:     out += "C\(f(p[0].x)) \(f(p[0].y)) \(f(p[1].x)) \(f(p[1].y)) \(f(p[2].x)) \(f(p[2].y))"
        case .closeSubpath:        out += "Z"
        @unknown default: break
        }
    }
    return out
}

func writeSVG(_ file: String, withDot: Bool) {
    let header = """
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" version="1.1" xml:space="preserve" \
    style="fill-rule:evenodd;clip-rule:evenodd">
    <!-- SINH TỰ ĐỘNG bởi Scripts/make-icons.swift — đừng sửa tay, sửa script rồi `make icons`.
         Nét chữ V đã chuyển thành đường bao tô đặc; asset catalog không đảm bảo dựng stroke. -->

    """
    let frame = CGMutablePath()
    frame.addPath(framePath())
    if withDot { frame.addPath(dotPath()) }        // even-odd biến chấm thành lỗ trên gáy
    var body = "<path fill=\"#000\" fill-rule=\"evenodd\" d=\"\(svgData(frame))\"/>\n"
    body += "<path fill=\"#000\" d=\"\(svgData(vPath(width: 2.6)))\"/>\n"
    try! (header + body + "</svg>\n").write(toFile: file, atomically: true, encoding: .utf8)
}

// MARK: - Xuất PNG cho AppIcon

/// Màu nhấn của icon Dock. Icon THANH MENU không dùng màu này: nó là template image, macOS
/// luôn nhuộm đen/trắng theo nền. Đổi ở đây chỉ đổi Dock và màn hình Giới thiệu.
let accent = NSColor(red: 0.98, green: 0.76, blue: 0.16, alpha: 1)   // vàng

func renderAppIcon(_ px: Int, _ file: String) {
    let s = CGFloat(px)
    let ctx = CGContext(data: nil, width: px, height: px, bitsPerComponent: 8, bytesPerRow: 0,
                        space: CGColorSpace(name: CGColorSpace.sRGB)!,
                        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    ctx.interpolationQuality = .high
    // Lưới icon của macOS: thân chiếm ~82% khung, phần còn lại chừa cho bóng đổ hệ thống.
    let inset = s * 0.09
    let r = CGRect(x: inset, y: inset, width: s - 2 * inset, height: s - 2 * inset)
    let body = CGPath(roundedRect: r, cornerWidth: r.width * 0.225, cornerHeight: r.width * 0.225, transform: nil)

    ctx.saveGState(); ctx.addPath(body); ctx.clip()
    let g = CGGradient(colorsSpace: CGColorSpace(name: CGColorSpace.sRGB)!,
                       colors: [NSColor(white: 0.27, alpha: 1).cgColor,
                                NSColor(white: 0.09, alpha: 1).cgColor] as CFArray,
                       locations: [0, 1])!
    ctx.drawLinearGradient(g, start: CGPoint(x: 0, y: s), end: CGPoint(x: 0, y: 0), options: [])
    ctx.restoreGState()

    ctx.addPath(body)
    ctx.setStrokeColor(NSColor(white: 1, alpha: 0.18).cgColor)
    ctx.setLineWidth(max(0.5, s * 0.008)); ctx.strokePath()

    let m = r.width * 0.56, k = m / 16
    ctx.saveGState()
    ctx.translateBy(x: r.minX + (r.width - m) / 2, y: r.minY + (r.height - m) / 2)
    ctx.scaleBy(x: k, y: k)
    ctx.setFillColor(accent.cgColor)
    ctx.addPath(framePath()); ctx.fillPath(using: .evenOdd)
    ctx.addPath(vPath(width: 2.6)); ctx.fillPath()
    ctx.restoreGState()

    let rep = NSBitmapImageRep(cgImage: ctx.makeImage()!)
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: file))
}

// MARK: - Ghi thẳng vào asset catalog

let assets = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : "MeetingBar/Assets.xcassets"

writeSVG("\(assets)/iconCalendar.imageset/Icon-Calendar.svg", withDot: false)
writeSVG("\(assets)/iconCalendar.imageset/Icon-Calendar_dark-1.svg", withDot: false)
writeSVG("\(assets)/iconCalendarCheckmark.imageset/Icon-Calendar-Checkmark.svg", withDot: true)

for (name, px) in [("16x16", 16), ("16x16@2x", 32), ("32x32", 32), ("32x32@2x", 64),
                   ("128x128", 128), ("128x128@2x", 256), ("256x256", 256), ("256x256@2x", 512),
                   ("512x512", 512), ("512x512@2x", 1024)] {
    renderAppIcon(px, "\(assets)/AppIcon.appiconset/\(name).png")
}
renderAppIcon(256, "\(assets)/appIconForAbout.imageset/128x128@2x.png")

print("icon: 3 SVG + 11 PNG đã ghi vào \(assets)")
