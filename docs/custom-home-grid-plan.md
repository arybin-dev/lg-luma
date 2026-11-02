# Luma Custom — Home grid, privacy and VPN

Status: five-column interface implemented; Linux validation and ARM packaging in progress. VPN and privacy controls remain pending device verification. This document does not claim TV deployment.

## Interface

- Centered favorites grid, five columns and three visible rows (fourth row when needed), larger tiles, using most of the 1920x1080 Home canvas.
- Larger gaps, 4-way Magic Remote navigation, vertical scrolling, and correct HDMI input positioning. Put date and clock on the same header line at matching type size. When weather is disabled, collapse its entire reserved region rather than leaving blank space.
- Preserve wallpaper, favorites, installed apps, and webOS 5/6 Home takeover compatibility. Ensure 3-4 grid rows do not collide with nav, input cards or screen edges; allow content scroll as necessary.

## Privacy and advertising

- Offer reversible, explicit toggles for supported LG advertising and telemetry settings.
- Discover exact service/config behavior for each webOS version before implementation.
- Keep authentication, LG app store, DRM, network and application updates working.
- Never claim third-party in-app ads are removed.
- Keep all settings opt-in with before/after status and rollback.

## VPN

- Show a VPN tile and a real connection-state indicator.
- Prefer a dedicated local backend with a narrowly scoped command interface; do not execute arbitrary user-provided shell commands as root.
- Support a configured VPN provider/protocol only after verifying compatibility with webOS 5.
- Distinguish TV tunnel state from router VPN routing; do not claim the router VPN is off when the TV tunnel is off.
- Do not store private keys or subscription URLs in the GitHub repository.

## Build and verification

- Modify state/view/navigation/tests in a separate branch.
- Add tests for 1, 5, 6, 10, 11, 15 and 16 favorites, pointer focus, remote movement and scrolling.
- Test privacy changes for reversibility and network functionality.
- Test VPN state transitions, reconnection and loss-of-network behavior.
- Build and test an ARM IPK in Linux CI before any TV installation.

## Deployment and rollback

- Back up Luma preferences and keep the original 2.16.0 IPK.
- Disable active Home takeover before replacing its executable.
- Install/test as an ordinary app before re-enabling Home takeover.
- Verify root SSH, original LG Home restoration and rollback after reboot.
