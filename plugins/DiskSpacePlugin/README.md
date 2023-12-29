# DiskSpacePlugin macOS

Valheim patch 0.217.38 introduced a new disk space check prior to saving, as outlined [by @mattcocca]. Since the
game officially only supports Windows and Linux, this library is non-existent for macOS and prevents the game
from saving properly.

This sub-folder contains source code to produce `DiskSpacePlugin.dylib`, a macOS version of said library. As this
is based on reverse engineering `libDiskSpacePlugin.so` (Linux), this plugin may need adjustments over time.

## Building

Running `make build` generates `build/DiskSpacePlugin.dylib`, a universal (arm64 / x64 compatible) dynamic link library.

> [!NOTE]
>
> The `build.sh` script automatically builds the plugin and bundles it with the game. No manual steps needed.

[by @mattcocca]: https://github.com/timkurvers/valheim-macos/issues/73#issuecomment-1868596874
