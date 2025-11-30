# live555-cmake

Modern CMake build system for LIVE555 Streaming Media libraries with comprehensive warning fixes.

## Overview

This project provides a CMake-based build system for [LIVE555 Streaming Media](http://www.live555.com/liveMedia/), making it easier to integrate into modern C++ projects. It includes 4 patches organized by warning type that fix compiler warnings in the original LIVE555 codebase.

## Features

- ✅ **Zero Warnings**: Compiler warnings fixed with automatic patching
- ✅ **Modern CMake**: Clean, modular CMake configuration
- ✅ **Shared Libraries**: Builds LGPL-compliant shared libraries by default
- ✅ **Automatic Patching**: 4 patches organized by warning type, automatically applied during build
- ✅ **Test Programs**: Optional build of test programs
- ✅ **C++20 Support**: Built with C++20 standard for atomic support

## Quick Start

```bash
# Clone the repository
git clone <your-repo-url>
cd live555-cmake

# Configure and build
cmake -B build -S .
cmake --build build

# Optional: Build with test programs
cmake -B build -S . -DBUILD_TEST_PROGS=ON
cmake --build build
```

## Build Outputs

### Main Applications
- `live555MediaServer` - RTSP media server
- `live555ProxyServer` - RTSP proxy server
- `live555HLSProxy` - HTTP Live Streaming (HLS) proxy

### Libraries (Shared by default)
- `libUsageEnvironment`
- `libBasicUsageEnvironment`
- `libgroupsock`
- `libliveMedia`

### Test Programs (34 programs, optional)
Build with `-DBUILD_TEST_PROGS=ON` to enable.

## Applied Patches

This project applies 4 patches organized by warning type to fix compiler warnings:

| Patch | Warning Type | Description |
|-------|--------------|-------------|
| 01-fix-int-to-pointer-casts | Type conversion warnings | Add (uintptr_t) intermediate casts for int-to-pointer conversions |
| 02-fix-array-bounds | Array bounds warnings | Fix out-of-bounds array access |
| 03-fix-array-compare | Array comparison warnings | Fix array pointer comparison |
| 04-fix-sprintf-deprecation | Deprecation warnings | Convert all sprintf() to snprintf() with correct buffer sizes |

All patches are located in the `patches/` directory and are automatically applied during the CMake configuration phase.

## CMake Options

- `BUILD_TEST_PROGS` - Build test programs (default: OFF)
- `BUILD_SHARED_LIBS` - Build shared libraries (default: ON for LGPL compliance)

## Requirements

- CMake 3.14 or later
- C++20 compatible compiler (for atomic support)
- OpenSSL (optional, for SSL support)

## License

**Important**: This project uses LIVE555 Streaming Media, which is licensed under the **GNU Lesser General Public License (LGPL) v3**.

### Your Application License

You **do NOT need to make your entire project LGPL**. You can use any license for your own application code (MIT, Apache-2.0, proprietary, etc.) when linking to LIVE555.

### LGPL Compliance Requirements

When distributing applications that use LIVE555, you must:

1. **Provide LGPL Notice**: Include the LGPL license text and acknowledge that you use LIVE555
2. **Source Code Access**: Provide access to the LIVE555 source code (including any modifications you made)
3. **Library Replacement**: Allow users to replace the LIVE555 library

This project builds LIVE555 as **shared libraries by default** to easily satisfy LGPL requirements:
- Users can replace the `.so`/`.dylib`/`.dll` files
- Your application code remains under your chosen license
- LIVE555 library code remains under LGPL

### LIVE555 License Files

The original LIVE555 license files are preserved in the downloaded source:
- `live/COPYING` - GPL license
- `live/COPYING.LESSER` - LGPL license

### Source Code Availability

- **Original LIVE555 Source**: http://www.live555.com/liveMedia/
- **This Project's Patches**: Available in the `patches/` directory
- If you modify LIVE555 code, you must make your modifications available under LGPL

### Official LIVE555 License Statement

From live555.com:

> The "LIVE555 Streaming Media" code is licensed under the LGPL - i.e., the GNU *Lesser* General Public License. This is a *much* less restrictive license than the GPL. (For example, the LGPL does not have a 'viral' effect on other code in your application.) See http://www.gnu.org/copyleft/lesser.txt for the complete LGPL license.

### Recommended License Statement

Include this in your project documentation:

```markdown
This software uses LIVE555 Streaming Media (http://www.live555.com/liveMedia/),
which is licensed under the GNU Lesser General Public License (LGPL) v3.
The LIVE555 source code is available from the official website.
Any modifications to LIVE555 made by this project are available in the patches/ directory.
```

## Project Structure

```
live555-cmake/
├── CMakeLists.txt          # Main CMake configuration
├── LICENSE                 # Project license (MIT)
├── README.md              # This file
├── cmake/                 # CMake modules
│   ├── FetchLive555.cmake    # Downloads and patches LIVE555
│   ├── FindDependencies.cmake
│   ├── Live555Helpers.cmake
│   └── Options.cmake
└── patches/               # Warning fix patches (auto-applied)
    ├── 01-fix-int-to-pointer-casts.patch
    ├── 02-fix-array-bounds.patch
    ├── 03-fix-array-compare.patch
    └── 04-fix-sprintf-deprecation.patch
```

## Build Results

- **Patches Applied**: 4 patches automatically applied during configuration
- **Build Status**: ✅ Clean build with zero warnings
- **Executables**: Main applications and optional test programs

## Disclaimer

This is not an official LIVE555 project. For the official LIVE555 source and documentation, visit http://www.live555.com/liveMedia/.

**Legal Notice**: The license information provided here is for general guidance only and does not constitute legal advice. For commercial use or specific legal questions, consult with a qualified attorney or your legal department.
