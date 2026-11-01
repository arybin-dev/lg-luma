#!/bin/sh
# Verify the upstream sing-box ARMv7 archive on the developer's Mac.
# Read-only with respect to the TV: no SSH, daemon, DNS, VPN or route changes.
set -eu

VERSION=1.14.4
ASSET="sing-box-${VERSION}-linux-armv7.tar.gz"
URL="https://github.com/SagerNet/sing-box/releases/download/v${VERSION}/${ASSET}"
# Digest published in the official GitHub release asset metadata on 2026-10-24.
EXPECTED_SHA256=fd164ed45ebc784f657a3e1d0e0ad0f68afdcff864ee57122c2cfed3ddb80a00
OUT="${1:-$HOME/LG-Luma/vpn-preflight}"
mkdir -p "$OUT"

verify_archive() {
    [ -f "$OUT/$ASSET" ] || return 1
    actual=$(shasum -a 256 "$OUT/$ASSET" | awk '{print $1}')
    [ "$actual" = "$EXPECTED_SHA256" ]
}

if ! verify_archive; then
    tmp="$OUT/$ASSET.part.$$"
    trap 'rm -f "$tmp"' EXIT HUP INT TERM
    printf 'Downloading official release: %s\n' "$URL"
    curl -fL --retry 3 --connect-timeout 20 "$URL" -o "$tmp"
    actual=$(shasum -a 256 "$tmp" | awk '{print $1}')
    if [ "$actual" != "$EXPECTED_SHA256" ]; then
        printf '%s\n' 'ERROR: upstream SHA-256 mismatch; refusing to use archive.' >&2
        exit 1
    fi
    mv "$tmp" "$OUT/$ASSET"
    trap - EXIT HUP INT TERM
fi

printf 'Verified SHA-256: %s\n' "$EXPECTED_SHA256"
tar -tzf "$OUT/$ASSET"
tar -xzf "$OUT/$ASSET" -C "$OUT" "sing-box-${VERSION}-linux-armv7/sing-box"
BIN="$OUT/sing-box-${VERSION}-linux-armv7/sing-box"
file "$BIN"
if ! file "$BIN" | grep -q 'ELF 32-bit LSB executable, ARM, EABI5'; then
    printf '%s\n' 'ERROR: unexpected architecture; no deployment permitted.' >&2
    exit 1
fi
printf '%s\n' 'Archive, digest and ARM EABI5 format: OK.'
printf '%s\n' 'Only local files were inspected; TV compatibility and TUN/routing are NOT verified.'
