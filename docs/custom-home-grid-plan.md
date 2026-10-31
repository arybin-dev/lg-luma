# Luma Custom — centered Home grid

Status: implementation in progress. Do not deploy to a TV yet.

## Target
- Keep original `com.ecklf.luma` and the working Home takeover intact until tested.
- Center favorites in five columns, with two or three visible rows depending on count.
- Increase horizontal spacing to about 45 logical pixels.
- Preserve favorite order, wallpaper, app labels, input cards and Magic Remote pointer.
- Navigate with all four remote directions; ensure focused tile remains visible.
- Vertically scroll when the grid or input section exceeds the viewport.
- Support the existing webOS 5/6 executable Home takeover and its disable/restore path.

## Required code changes
1. `src/view.rs`: replace the horizontal favorites strip with a grid; update clipping and vertical height accounting, including HDMI inputs.
2. `src/state.rs`: remove horizontal strip scroll assumptions; update focus reveal, wheel behavior, directional navigation and viewport handling.
3. `src/tests.rs`: replace strip-specific expectations and add 1, 5, 6, 10, 11, 15 and 16 favorite scenarios, including pointer hit testing and remote navigation.
4. Verify a local preview and all tests before building an ARM IPK.

## Safety and release
- The first build must be a test artifact, not automatically installed.
- Back up preferences and the original 2.16.0 IPK.
- Disable the active Home takeover before replacing its executable.
- Validate normal app launch before enabling Home takeover again.
- Confirm SSH root access and the rollback command remain available.
