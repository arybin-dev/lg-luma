# On-device VPN specification — LG webOS 5

Decision: VPN runs on the TV itself and is switched independently from the router. No router API calls.

## User experience
- Home tile: VPN On / VPN Off / Connecting / Error / Unsupported.
- Press OK to toggle. Show current protocol and endpoint label (never secret).
- Settings: autoconnect on boot (off by default), reconnect, and diagnostics.
- Show *TV tunnel* status only. If the router already routes traffic through VPN, turning the TV tunnel off does not remove the router VPN.

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
