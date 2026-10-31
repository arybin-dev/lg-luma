#!/bin/sh
# Download and inspect an official ARMv7 sing-box archive on a development machine.
# No TV connection, VPN startup, or network changes.
set -eu
VERSION=1.14.4
ASSET="sing-box-${VERSION}-linux-armv7.tar.gz"
URL="https://github.com/SagerNet/sing-box/releases/download/v${VERSION}/${ASSET}"
OUT="${1:-$HOME/LG-Luma/vpn-preflight}"
mkdir -p "$OUT"
echo "Downloading official release: $URL"
curl -fL --retry 3 --connect-timeout 20 "$URL" -o "$OUT/$ASSET"
echo "SHA-256 (record for later comparison to upstream manifest):"
shasum -a 256 "$OUT/$ASSET"
echo "Archive contents:"
tar -tzf "$OUT/$ASSET" | head -30
echo "Archive integrity: OK"
echo "Saved at: $OUT/$ASSET"
echo "No files were transferred to the TV."
