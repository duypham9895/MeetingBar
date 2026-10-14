#!/bin/sh
# install-local.sh — build bản Release, ký bằng chứng chỉ của người fork, cài vào /Applications.
#
# Vì sao cần script này thay vì `xcodebuild build` rồi kéo thả:
#
#   1. KHÔNG để xcodebuild ký. App ID `leits.MeetingBar` thuộc team KGH289N6T8; không ai
#      ngoài leits xin được provisioning profile cho nó. Bản fork đã đổi bundle ID, nhưng
#      ngay cả ID mới cũng cần Xcode đăng nhập Apple ID mới xin được profile. Nên ta build
#      KHÔNG KÝ rồi tự ký — không cần tài khoản, không cần mạng.
#
#   2. Ký TỪ TRONG RA NGOÀI. Chữ ký bundle ngoài băm cả nội dung bên trong. Ký vỏ trước
#      rồi ký ruột sau là làm hỏng chữ ký vỏ. (Cũng là lý do Apple khuyên tránh --deep.)
#
#   3. Dùng MeetingBar-local.entitlements, KHÔNG dùng MeetingBar.entitlements. Khác đúng
#      một khoá: com.apple.developer.usernotifications.time-sensitive. Mọi entitlement họ
#      com.apple.developer.* đòi provisioning profile; giữ nó thì không ra được app nào.
#      Cái mất: thông báo không xuyên qua Focus. Cái không mất: tự mở link họp.
#
# Chạy:  make install     (hoặc  Scripts/install-local.sh)
set -eu

ROOT=$(cd "$(dirname "$0")/.." && pwd)
DEST=${DEST:-/Applications/MeetingBar.app}
DD=${DD:-"$ROOT/.build-release"}
ENT="$ROOT/MeetingBar/MeetingBar-local.entitlements"

# Chứng chỉ: lấy chứng chỉ Apple Development duy nhất trong keychain. Có nhiều cái thì
# truyền tay qua biến SIGN_ID, kẻo ký nhầm bằng chứng chỉ của tổ chức khác.
if [ -z "${SIGN_ID:-}" ]; then
    SIGN_ID=$(security find-identity -v -p codesigning \
        | awk '/Apple Development/ {print $2}' | head -1)
    [ -n "$SIGN_ID" ] || { echo "LỖI: keychain không có chứng chỉ Apple Development." >&2; exit 1; }
fi

echo "==> build Release (không ký)"
xcodebuild -project "$ROOT/MeetingBar.xcodeproj" -scheme MeetingBar \
    -configuration Release -destination 'platform=macOS,arch=arm64' \
    -derivedDataPath "$DD" CODE_SIGNING_ALLOWED=NO build >"$DD.log" 2>&1 \
    || { echo "BUILD THẤT BẠI — xem $DD.log"; grep "error:" "$DD.log" | head -10; exit 1; }

APP="$DD/Build/Products/Release/MeetingBar.app"

echo "==> ký, từ trong ra ngoài"
for b in "$APP"/Contents/Resources/*.bundle; do
    [ -e "$b" ] || continue
    codesign --force --options runtime --timestamp=none --sign "$SIGN_ID" "$b"
done
for h in "$APP"/Contents/Library/LoginItems/*.app; do
    [ -e "$h" ] || continue
    codesign --force --options runtime --timestamp=none --sign "$SIGN_ID" "$h"
done
codesign --force --options runtime --timestamp=none --entitlements "$ENT" --sign "$SIGN_ID" "$APP"
codesign --verify --deep --strict "$APP"

echo "==> cài vào $DEST"
osascript -e 'tell application "MeetingBar" to quit' 2>/dev/null || true
sleep 2
pkill -x MeetingBar 2>/dev/null || true

# Thay NGUYÊN KHỐI. Không ditto đè lên cây cũ: ditto trộn hai cây, nên file mà bản mới đã
# bỏ đi vẫn nằm lại trong bundle và lọt vào chữ ký. Dựng bên cạnh rồi hoán đổi.
STAGE="$DEST.new-$$"
OLD="$DEST.old-$$"
/bin/rm -rf "$STAGE"
ditto "$APP" "$STAGE"
if [ -e "$DEST" ]; then mv "$DEST" "$OLD"; fi
mv "$STAGE" "$DEST"
if [ -e "$OLD" ]; then /bin/rm -rf "$OLD"; fi

codesign --verify --deep --strict "$DEST"
echo "==> xong"
codesign -dv --verbose=2 "$DEST" 2>&1 | grep -E "Identifier=|TeamIdentifier=|Authority=Apple Development"
echo "version $(defaults read "$DEST/Contents/Info.plist" CFBundleShortVersionString)"
