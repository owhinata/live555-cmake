# Project-wide options and platform-specific settings

# ============================================================================
# Build Options
# ============================================================================

# Export compile commands for IDE/tools support
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Build shared libraries by default (for LGPL compliance)
# Users can override with: cmake -DBUILD_SHARED_LIBS=OFF
set(BUILD_SHARED_LIBS ON CACHE BOOL "Build shared libraries (.so/.dylib/.dll)")

# Set position independent code for shared libraries
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# ============================================================================
# Application Build Options
# ============================================================================

option(BUILD_MEDIA_SERVER "Build live555MediaServer executable" ON)
option(BUILD_PROXY_SERVER "Build live555ProxyServer executable" ON)
option(BUILD_HLS_PROXY "Build live555HLSProxy executable" ON)
option(BUILD_TEST_PROGS "Build test programs" OFF)

# ============================================================================
# Patch Options
# ============================================================================

option(APPLY_LIVE555_PATCHES "Apply warning fix patches to live555 source" ON)

# ============================================================================
# Platform-Specific Definitions
# ============================================================================

# Platform-specific compile definitions for live555
if(UNIX AND NOT APPLE)
    set(LIVE555_COMPILE_DEFINITIONS
        SOCKLEN_T=socklen_t
        _LARGEFILE_SOURCE=1
        _FILE_OFFSET_BITS=64
    )
elseif(APPLE)
    set(LIVE555_COMPILE_DEFINITIONS
        SOCKLEN_T=socklen_t
        _LARGEFILE_SOURCE=1
        _FILE_OFFSET_BITS=64
        BSD=1
        HAVE_SOCKADDR_LEN=1
    )
elseif(WIN32)
    set(LIVE555_COMPILE_DEFINITIONS
        SOCKLEN_T=int
        NO_SSTREAM=1
    )
endif()

# ============================================================================
# Development Tools
# ============================================================================

# Create symbolic link to compile_commands.json in project root
if(CMAKE_EXPORT_COMPILE_COMMANDS)
    # Create symlink after all targets are defined
    add_custom_target(compile_commands_symlink ALL
        COMMAND ${CMAKE_COMMAND} -E create_symlink
            ${CMAKE_BINARY_DIR}/compile_commands.json
            ${CMAKE_SOURCE_DIR}/compile_commands.json
        COMMENT "Creating symlink: compile_commands.json -> build/compile_commands.json"
        VERBATIM
    )

    message(STATUS "compile_commands.json will be symlinked to project root after build")
endif()
