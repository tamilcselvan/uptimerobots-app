#!/usr/bin/env bash
# Builds a .deb package from the Flutter Linux release bundle.
#
# `flutter build linux` only produces a bare folder (binary + data + libs) —
# it has no installer, no desktop entry, no icon integration. This script
# wraps that bundle the standard Debian way: install it under
# /usr/lib/<pkg>/, symlink the binary into /usr/bin/, and install the
# .desktop file + icon into the paths the desktop environment scans.
#
# Usage: packaging/linux/build-deb.sh
# Output: dist/uptimerobots-app_<version>_amd64.deb

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

PKG_NAME="uptimerobots-app"
APP_ID="com.agilecyber.uptimerobots_app"
VERSION="$(grep '^version:' pubspec.yaml | sed -E 's/version:\s*([0-9]+\.[0-9]+\.[0-9]+).*/\1/')"
ARCH="amd64"

echo "Building release bundle..."
flutter build linux --release

BUNDLE_DIR="$ROOT_DIR/build/linux/x64/release/bundle"
if [ ! -d "$BUNDLE_DIR" ]; then
  echo "error: release bundle not found at $BUNDLE_DIR" >&2
  exit 1
fi

STAGE_DIR="$ROOT_DIR/build/deb-stage"
DIST_DIR="$ROOT_DIR/dist"
rm -rf "$STAGE_DIR"
mkdir -p "$STAGE_DIR/DEBIAN"
mkdir -p "$STAGE_DIR/usr/lib/$PKG_NAME"
mkdir -p "$STAGE_DIR/usr/bin"
mkdir -p "$STAGE_DIR/usr/share/applications"
mkdir -p "$STAGE_DIR/usr/share/icons/hicolor/512x512/apps"

echo "Staging package contents..."
cp -r "$BUNDLE_DIR"/. "$STAGE_DIR/usr/lib/$PKG_NAME/"
ln -s "/usr/lib/$PKG_NAME/uptimerobots_app" "$STAGE_DIR/usr/bin/$PKG_NAME"

sed "s|Exec=uptimerobots_app|Exec=/usr/bin/$PKG_NAME|" \
  "$ROOT_DIR/linux/$APP_ID.desktop" \
  > "$STAGE_DIR/usr/share/applications/$APP_ID.desktop"

cp "$ROOT_DIR/assets/icon/app_icon.png" \
  "$STAGE_DIR/usr/share/icons/hicolor/512x512/apps/$APP_ID.png"

cat > "$STAGE_DIR/DEBIAN/control" <<EOF
Package: $PKG_NAME
Version: $VERSION
Section: utils
Priority: optional
Architecture: $ARCH
Depends: libgtk-3-0, libsecret-1-0
Maintainer: Tamilselvan <tamilselvan@agilecybersolutions.com>
Description: Multi-account UptimeRobot dashboard
 Aggregates monitors across multiple UptimeRobot accounts into one
 dashboard, with local notifications on status changes, client-side
 SSL certificate expiry checks, and response-time history charts.
EOF

mkdir -p "$DIST_DIR"
OUTPUT="$DIST_DIR/${PKG_NAME}_${VERSION}_${ARCH}.deb"
echo "Building $OUTPUT..."
dpkg-deb --root-owner-group --build "$STAGE_DIR" "$OUTPUT"

echo "Done: $OUTPUT"
