# Luma Custom validation — 2026-11-01

Runtime fixes: `88b57c2a99270a0990744cd944ad3f4bd2b01421`.
Custom rendering tests and CI integration: `5ca84751247e295dacbc0e532ebd5f6b9ffd11ea`.

## Completed

- Preserved the original dirty Mac checkout and saved a timestamped binary patch under `~/LG-Luma/custom-backup/`.
- Compared local changes with GitHub without reset or merge; saved `local-versus-github.patch`.
- Created a clean detached worktree at `~/LG-Luma/luma-work-source`, verified at `5ca8475`. Original `luma-source` still retains its two modified files.
- Added branch-push validation to CI and a dedicated custom-grid rendering suite. No GitHub Actions runs were observed; do not describe Actions as having passed.
- Fixed the navigation test's starting tile: index 14, rather than 9, tests clamping into the partial fourth row.
- Removed the unused horizontal EdgeFadeX draw command, fixing strict Clippy failure.
- Added a minor Changeset and updated Homebrew capability text.
- Compiled Rust and ARMv7 binaries in an isolated Linux x86_64 workspace, using Rust 1.93.0, the pinned webOS NDK and checksum-verified SDL-webOS.

## Verified checks

- `cargo fmt --all -- --check`: passed.
- Oxfmt and Oxlint: passed.
- `cargo clippy --locked --workspace --all-targets --all-features -- -D warnings`: passed.
- Full serial workspace Rust run: 293 application tests and 43 helper tests passed, zero failures. A parallel run had an intermittent wallpaper socket-revocation assertion failure; serial validation passed. Do not erase that limitation.
- Node tests: 39 passed, zero failures, using pnpm 10.34.5.
- Custom desktop rendering: 1, 5, 6, 10, 11, 15 and 16 favorites; partial final row; pointer selection; Russian text; zero missing images/glyphs; passed.
- Brand rendering: all 40 SVG-backed demo apps passed.
- Translation smoke suite: process completed with exit code 0.
- General navigation smoke suite: stopped on its framebuffer-variance assertion for the empty recent-apps view. It is not a fully passing suite.
- Mock weather suite: started, but final completion was not retrieved before the workspace disconnected. Status unknown.

## ARM test package

Packaging completed and verified metadata, assets, executable modes, ARM runtime and 230 payload entries.

- Internal package: `com.ecklf.luma_2.16.0_arm.ipk` (a custom test build retaining upstream version and app ID).
- SHA-256: `cbd6b9700d9902c2c327c3f5321c5c307a77b148795ac8d0ede14c275ad6e62f`.
- ELF32 ARM, EABI5 soft-float, interpreter `/lib/ld-linux.so.3`.
- Main executable GLIBC version requirements checked through GLIBC 2.12, below the stated TV glibc 2.28. This is static compatibility evidence, not a successful device launch.

The temporary Linux environment disconnected after packaging, before the IPK could be exported. The file upload was rejected because no primary turn environment was available. **No durable downloadable IPK was saved.** Recover the prior workspace if available, or rebuild from the commits above; never claim the package was delivered.

## TV and installation blockers

SSH reached Dropbear on the TV. The server recognized `~/.ssh/lg_homebrew`, but authentication failed: the private key is encrypted (`aes256-ctr`), the SSH agent held no identities, and UseKeychain did not unlock it. No private key or credential was disclosed. An authorized user must unlock the existing key before further SSH operations.

The original Luma 2.16.0 backup remains on the Mac at `~/LG-Backup/55UN74006LA/com.ecklf.luma_2.16.0_arm.ipk`; SHA-256 was verified as `98c6b94a683d2a17c3ba6bb424f06f4fff12e914b69635e6441a025358729274`.

Current TV preferences and Home takeover configuration have **not** yet been backed up in this session. No installation, Home replacement, route/DNS changes, privacy changes, VPN binary execution or reboot was performed. Existing TV operation was left untouched.

## Next authorized continuation

Recover/rebuild the IPK, unlock existing SSH access, back up current preferences, uploaded wallpaper data and `/var/lib/luma-home`, then test the new runtime without replacing the active Home. Verify device behavior and a recoverable rollback before installation. VPN and privacy work remain pending and must not block the interface release. Do not infer VPN compatibility from the previously downloaded archive alone.

## Device follow-up — 2026-11-02

This section supersedes the earlier installation blockers and undelivered-artifact status.

- Existing SSH key was unlocked by the owner; root SSH verified.
- The original Linux workspace recovered, and the existing IPK was saved as `Luma-Custom-5x3-Test.ipk` (Library identity `libfile_7f70a5bbf6288191a2e47282e55eb277`). User downloaded it to the Mac; its SHA-256 matched the package above.
- Mac backup: `~/LG-Backup/55UN74006LA/custom-before-20261102T000332/luma-current-and-home.tar.gz`, SHA-256 `90973e320079452b6615976c8e4a93dbbaeafac965408c2d06cbba88054968f8`.
- On-TV original payload, preferences and Home backup: `/media/developer/luma-custom-original-20261102.tar.gz`, SHA-256 `350132878fb6c6f185ba35a94a2ac29303c8f561db49034b9327b97febdea8df`. Recovery script: `/media/developer/luma-custom-rollback-20261102.sh`.
- Recovery was exercised: restore LG Home, restore original payload/settings, reapply original `fullhome`. The first timed trial also automatically reverted successfully when its four-minute acceptance window expired.
- Final update used a ten-minute recovery window and was accepted only after the installed binary, mounted Home executable and live `/proc/PID/exe` all matched SHA-256 `66442da0caebaafe4fdbd59e1db76c28c0300e9fae328a924316dfe43e2c1df6`.
- Custom is installed and running as `com.webos.app.fullhome`; helper status confirms enabled, mounted and boot hook present. Foreground query independently returned `com.webos.app.fullhome`. Acceptance marker `/tmp/luma-custom-accepted` suppresses the trial watchdog.
- Device log confirms Wayland, GL context, lifecycle registration, focus, inventory of 18 apps / 3 inputs and first frame in about 1.2 seconds. Existing 11 favorites, Russian language, Prism background and disabled weather retained.
- Physical Magic Remote Home button and subjective on-screen usability still need owner confirmation. No reboot was performed; boot behavior has not been hardware-verified in this session.
- Direct SSH rendering initially failed due to missing Wayland environment / LS2 identity, not loader failure. The proper installed/SAM-launched app and native Home both rendered successfully. Bounded interactive Luna queries used the canonical `com.webos.service.applicationmanager` service and kept stdin open for replies.
- Mock-weather rendering suite also completed successfully after the workspace recovered. The earlier general smoke failure for empty Recents remains unresolved; do not describe every smoke suite as passing.
- VPN and privacy controls remain pending. No VPN routes, DNS or advertising settings changed.
