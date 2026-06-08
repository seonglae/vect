#!/bin/bash
# Vect installer (macOS / Linux).
# Usage: curl -fsSL https://raw.githubusercontent.com/seonglae/vect-app/main/scripts/install.sh | bash
set -euo pipefail

REPO="seonglae/vect-app"
INSTALL_DIR="${VECT_INSTALL_DIR:-/Applications}"

err() { printf "\033[31m✗\033[0m %s\n" "$*" >&2; exit 1; }
info() { printf "\033[36m→\033[0m %s\n" "$*"; }
ok() { printf "\033[32m✓\033[0m %s\n" "$*"; }

OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS-$ARCH" in
  Darwin-arm64) ASSET_PATTERN='_aarch64.dmg' ;;
  Darwin-x86_64) ASSET_PATTERN='_x64.dmg' ;;
  Linux-x86_64) ASSET_PATTERN='_amd64.AppImage' ;;
  Linux-aarch64) ASSET_PATTERN='_aarch64.AppImage' ;;
  *) err "Unsupported platform: $OS-$ARCH" ;;
esac

info "Detected $OS-$ARCH"
info "Fetching latest release metadata"

LATEST_JSON="$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest")"
ASSET_URL="$(printf "%s" "$LATEST_JSON" | grep -E '"browser_download_url"' | grep -E "$ASSET_PATTERN" | head -1 | sed -E 's/.*"(https[^"]+)".*/\1/')"

if [ -z "$ASSET_URL" ]; then
  err "No asset matching $ASSET_PATTERN in the latest release"
fi

FILENAME="$(basename "$ASSET_URL")"
TMP="$(mktemp -d)"
info "Downloading $FILENAME"
curl -fL --progress-bar -o "$TMP/$FILENAME" "$ASSET_URL"

case "$FILENAME" in
  *.dmg)
    info "Mounting $FILENAME"
    MOUNT_POINT="$(hdiutil attach -nobrowse -mountrandom /tmp "$TMP/$FILENAME" | tail -1 | awk '{print $NF}')"
    APP_PATH="$(find "$MOUNT_POINT" -name '*.app' -maxdepth 2 | head -1)"
    [ -n "$APP_PATH" ] || err "No .app inside DMG"
    info "Copying to $INSTALL_DIR"
    cp -R "$APP_PATH" "$INSTALL_DIR/"
    hdiutil detach -quiet "$MOUNT_POINT"
    ok "Installed to $INSTALL_DIR/$(basename "$APP_PATH")"
    ;;
  *.AppImage)
    BIN="${VECT_INSTALL_DIR:-$HOME/.local/bin}"
    mkdir -p "$BIN"
    mv "$TMP/$FILENAME" "$BIN/vect.AppImage"
    chmod +x "$BIN/vect.AppImage"
    ok "Installed to $BIN/vect.AppImage"
    case ":$PATH:" in *":$BIN:"*) ;; *) info "Add $BIN to PATH to run 'vect.AppImage' from anywhere" ;; esac
    ;;
esac

rm -rf "$TMP"
ok "Done"
