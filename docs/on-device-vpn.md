# On-device VPN specification — LG webOS 5

Decision: VPN runs on the TV itself and is switched independently from the router. No router API calls.

## User experience

- Home tile: VPN On / VPN Off / Connecting / Error / Unsupported.
- Press OK to toggle. Show current protocol and endpoint label (never secret).
- Settings: autoconnect on boot (off by default), reconnect, and diagnostics.
- Show _TV tunnel_ status only. If the router already routes traffic through VPN, turning the TV tunnel off does not remove the router VPN.

## Implementation boundary

- UI (Luma native app) calls a narrowly scoped, authenticated local service.
- Root-owned service implements only: status, connect, disconnect, and diagnostics.
- Service must not accept arbitrary shell commands, filenames or executable paths from the UI.
- Keep secrets in root-only files on the TV; never in preferences, UI logs, GitHub, or IPK.
- Verify binary compatibility and kernel TUN availability on K6LP/webOS 5 before selecting a VPN engine.
- Prefer WireGuard if compatible; otherwise evaluate OpenVPN. Do not assume a protocol works without tests.
- Start with a single configured profile and no routing changes until preflight passes.

## Network safety

- Record pre-VPN default route and DNS state and restore them on disconnect/failure.
- Explicitly define whether the tunnel carries all traffic or selected destinations.
- Do not modify the router or break the TV's local-network access.
- Confirm external IP changes, DNS behavior, IPv4/IPv6 handling and streaming-app compatibility.
- Handle cold boot, process crash, network loss, repeated toggles, and update/rollback.
- Disable the tile if the backend is missing or preflight fails; never display a false connected state.

## Preflight on user's LG 55UN74006LA

- Root SSH and Homebrew service confirmed in prior session.
- Read-only inspect: `uname -m`, `uname -r`, `ls -l /dev/net/tun`, `command -v ip`, `command -v wg`, `command -v openvpn`, `ip route`.
- Do not run `modprobe`, create TUN, change routes, install daemons, or start VPN until compatibility and rollback are reviewed.
- User must supply a TV-compatible VPN profile through a secure local process later; never request private keys in chat.

## Acceptance

1. Toggle ON establishes an actual tunnel on TV and verifies it.
2. Toggle OFF tears down only the TV tunnel and restores TV networking.
3. Router configuration remains unchanged.
4. Status remains accurate after reboot and connection loss.
5. Original Luma Home takeover and SSH recovery remain functional.

## Candidate engine identified (2026-10-31)

- Official sing-box v1.14.4 provides `sing-box-1.14.4-linux-armv7.tar.gz` and ARMv7 musl/glibc variants. Official release directory: https://dl.sing-box.org/releases/latest/
- Start with the ordinary ARMv7 archive, NOT the glibc NaiveProxy variant: LG has glibc 2.28 whereas that optional feature's CGO variant requires >=2.31.
- This is a candidate, not a compatibility guarantee: the LG kernel is 4.4.84 and its TUN interface has not been exercised.
- Next preflight: obtain upstream release asset on a build machine, verify hash against upstream release manifest if available, inspect ELF architecture and linkage, then transfer only to a temporary TV path and run `version` (no config, tunnel, routes, DNS or autostart).
- Stop if the binary cannot execute; do not force libraries or modify system linker paths.
