#!/bin/bash
# Vect installer (macOS / Linux).
# Usage: curl -fsSL https://raw.githubusercontent.com/seonglae/vect-app/main/scripts/install.sh | bash
set -euo pipefail

REPO="seonglae/vect-app"
INSTALL_DIR="${VECT_INSTALL_DIR:-/Applications}"
# The key every release download is signed with, the one the app's updater trusts.
PUBLIC_KEY='RWQY6le0WOYq1SK6aFpv/yMkyKdqnfO+SZ3R+Qf+X0IcnPuBlKsCcOjR'
TEAM_ID='2VL29CKKDM'

err() { printf "\033[31m✗\033[0m %s\n" "$*" >&2; exit 1; }
info() { printf "\033[36m→\033[0m %s\n" "$*"; }
ok() { printf "\033[32m✓\033[0m %s\n" "$*"; }

verify() {
  local file="$1" name dir
  name="$(basename "$file")"
  dir="$(mktemp -d)"
  base64 -d < "$2" > "$dir/minisig" 2>/dev/null || err "Unreadable signature for $name"
  if command -v minisign >/dev/null 2>&1; then
    minisign -Vm "$file" -x "$dir/minisig" -P "$PUBLIC_KEY" >/dev/null 2>&1 || err "The signature of $name does not match Vect's key"
    rm -rf "$dir"
    return
  fi
  { command -v openssl >/dev/null 2>&1 && openssl pkeyutl -help 2>&1 | grep -q -- '-rawin'; } ||
    err "Install minisign or OpenSSL 3 to check the signature of $name"
  # minisign: the key is "Ed", an 8-byte key id and the Ed25519 key; the signature line is "ED",
  # the key id and an Ed25519 signature over the BLAKE2b-512 digest of the file.
  printf '%s' "$PUBLIC_KEY" | base64 -d > "$dir/key"
  sed -n 2p "$dir/minisig" | base64 -d > "$dir/line" 2>/dev/null || err "Unreadable signature for $name"
  [ "$(head -c 2 "$dir/line")" = "ED" ] || err "The signature of $name is not in the expected form"
  [ "$(od -An -tx1 -j2 -N8 "$dir/line" | tr -d ' \n')" = "$(od -An -tx1 -j2 -N8 "$dir/key" | tr -d ' \n')" ] || err "$name is signed with another key"
  tail -c 64 "$dir/line" > "$dir/signature"
  { printf '\x30\x2a\x30\x05\x06\x03\x2b\x65\x70\x03\x21\x00'; tail -c 32 "$dir/key"; } > "$dir/key.der"
  openssl dgst -blake2b512 -binary "$file" > "$dir/digest"
  openssl pkeyutl -verify -pubin -keyform DER -inkey "$dir/key.der" -rawin -in "$dir/digest" -sigfile "$dir/signature" >/dev/null 2>&1 ||
    err "The signature of $name does not match Vect's key"
  rm -rf "$dir"
}

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
    info "Checking the signature"
    unmount() { hdiutil detach -quiet "$MOUNT_POINT" || true; err "$*"; }
    codesign --verify --deep --strict "$APP_PATH" 2>/dev/null || unmount "The app's signature is broken"
    [ "$(codesign -dv "$APP_PATH" 2>&1 | sed -n 's/^TeamIdentifier=//p')" = "$TEAM_ID" ] || unmount "The app is not signed by Vect's developer"
    spctl --assess --type execute "$APP_PATH" 2>/dev/null || unmount "macOS does not accept the app as notarized"
    ok "Signed and notarized by Vect's developer"
    info "Copying to $INSTALL_DIR"
    cp -R "$APP_PATH" "$INSTALL_DIR/"
    hdiutil detach -quiet "$MOUNT_POINT"
    ok "Installed to $INSTALL_DIR/$(basename "$APP_PATH")"
    ;;
  *.AppImage)
    info "Checking the signature"
    curl -fsSL -o "$TMP/$FILENAME.sig" "$ASSET_URL.sig" || err "No signature is published for $FILENAME"
    verify "$TMP/$FILENAME" "$TMP/$FILENAME.sig"
    ok "Signed by Vect"
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
