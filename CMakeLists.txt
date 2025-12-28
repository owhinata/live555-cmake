cmake_minimum_required(VERSION 3.14)
project(live555-cmake)

# Set C++ standard to C++20 for atomic support
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Add cmake/ directory to module path
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

# Project options and platform-specific settings
include(Options)

# live555 version (controlled at top level)
set(LIVE555_VERSION "2025.12.26")

# Download live555 source
include(FetchLive555)

# Find dependencies (OpenSSL, etc.)
include(FindDependencies)

# Include helper functions for library creation
include(Live555Helpers)

# ============================================================================
# live555 Library Targets
# ============================================================================

# UsageEnvironment library
# Note: BasicHashTable.cpp is needed by UsageEnvironment for shared library builds
live555_add_library(
    TARGET_NAME UsageEnvironment
    SOURCE_DIR ${LIVE555_DIR}/UsageEnvironment
    INCLUDE_DIRS
        ${LIVE555_DIR}/UsageEnvironment/include
        ${LIVE555_DIR}/groupsock/include
    PRIVATE_INCLUDE_DIRS
        ${LIVE555_DIR}/BasicUsageEnvironment/include
    EXTRA_SOURCES
        ${LIVE555_DIR}/BasicUsageEnvironment/BasicHashTable.cpp
)

# BasicUsageEnvironment library
# Remove BasicHashTable.cpp since it's already in UsageEnvironment
live555_add_library(
    TARGET_NAME BasicUsageEnvironment
    SOURCE_DIR ${LIVE555_DIR}/BasicUsageEnvironment
    INCLUDE_DIRS
        ${LIVE555_DIR}/BasicUsageEnvironment/include
        ${LIVE555_DIR}/UsageEnvironment/include
        ${LIVE555_DIR}/groupsock/include
    LINK_LIBRARIES
        UsageEnvironment
    EXCLUDE_SOURCES
        ${LIVE555_DIR}/BasicUsageEnvironment/BasicHashTable.cpp
)

# groupsock library
live555_add_library(
    TARGET_NAME groupsock
    SOURCE_DIR ${LIVE555_DIR}/groupsock
    INCLUDE_DIRS
        ${LIVE555_DIR}/groupsock/include
        ${LIVE555_DIR}/UsageEnvironment/include
    LINK_LIBRARIES
        UsageEnvironment
)

# liveMedia library
live555_add_library(
    TARGET_NAME liveMedia
    SOURCE_DIR ${LIVE555_DIR}/liveMedia
    INCLUDE_DIRS
        ${LIVE555_DIR}/liveMedia/include
        ${LIVE555_DIR}/groupsock/include
        ${LIVE555_DIR}/UsageEnvironment/include
    LINK_LIBRARIES
        groupsock
        UsageEnvironment
)

# Link OpenSSL to liveMedia if found
if(OPENSSL_FOUND)
    target_include_directories(liveMedia PRIVATE ${OPENSSL_INCLUDE_DIR})
    target_link_libraries(liveMedia PUBLIC OpenSSL::SSL OpenSSL::Crypto)
endif()

# Status messages
if(BUILD_SHARED_LIBS)
    message(STATUS "Building live555 as SHARED libraries (LGPL compliant)")
else()
    message(STATUS "Building live555 as STATIC libraries")
endif()

message(STATUS "live555 libraries configured:")
message(STATUS "  - UsageEnvironment")
message(STATUS "  - BasicUsageEnvironment")
message(STATUS "  - groupsock")
message(STATUS "  - liveMedia")

# ============================================================================
# Applications
# ============================================================================

# live555MediaServer
if(BUILD_MEDIA_SERVER)
    live555_add_executable(
        TARGET_NAME live555MediaServer
        SOURCES
            ${LIVE555_DIR}/mediaServer/live555MediaServer.cpp
            ${LIVE555_DIR}/mediaServer/DynamicRTSPServer.cpp
        EXTRA_INCLUDE_DIRS
            ${LIVE555_DIR}/mediaServer
    )
endif()

# live555ProxyServer
if(BUILD_PROXY_SERVER)
    live555_add_executable(
        TARGET_NAME live555ProxyServer
        SOURCES
            ${LIVE555_DIR}/proxyServer/live555ProxyServer.cpp
    )
endif()

# live555HLSProxy
if(BUILD_HLS_PROXY)
    live555_add_executable(
        TARGET_NAME live555HLSProxy
        SOURCES
            ${LIVE555_DIR}/hlsProxy/live555HLSProxy.cpp
    )
endif()

# Test programs (37 programs)
if(BUILD_TEST_PROGS)
    file(GLOB TEST_PROG_SOURCES ${LIVE555_DIR}/testProgs/*.cpp)

    # Exclude helper files that don't have main()
    list(FILTER TEST_PROG_SOURCES EXCLUDE REGEX "announceURL\\.cpp$")
    list(FILTER TEST_PROG_SOURCES EXCLUDE REGEX "playCommon\\.cpp$")

    # Exclude 'extra' programs that require additional dependencies
    list(FILTER TEST_PROG_SOURCES EXCLUDE REGEX "testGSMStreamer\\.cpp$")

    # Programs that need announceURL.cpp
    set(PROGRAMS_NEED_ANNOUNCE_URL
        testAMRAudioStreamer testDVVideoStreamer testGSMStreamer
        testH264VideoStreamer testH265VideoStreamer testMKVStreamer
        testMP3Streamer testMPEG1or2AudioVideoStreamer testMPEG1or2VideoStreamer
        testMPEG2TransportStreamer testMPEG4VideoStreamer testOggStreamer
        testOnDemandRTSPServer testWAVAudioStreamer vobStreamer
    )

    foreach(TEST_SOURCE ${TEST_PROG_SOURCES})
        get_filename_component(TEST_NAME ${TEST_SOURCE} NAME_WE)

        # Special cases that need multiple source files
        if(TEST_NAME STREQUAL "openRTSP")
            live555_add_executable(
                TARGET_NAME ${TEST_NAME}
                SOURCES ${LIVE555_DIR}/testProgs/openRTSP.cpp ${LIVE555_DIR}/testProgs/playCommon.cpp
            )
        elseif(TEST_NAME STREQUAL "playSIP")
            live555_add_executable(
                TARGET_NAME ${TEST_NAME}
                SOURCES ${LIVE555_DIR}/testProgs/playSIP.cpp ${LIVE555_DIR}/testProgs/playCommon.cpp
            )
        elseif(TEST_NAME IN_LIST PROGRAMS_NEED_ANNOUNCE_URL)
            live555_add_executable(
                TARGET_NAME ${TEST_NAME}
                SOURCES ${TEST_SOURCE} ${LIVE555_DIR}/testProgs/announceURL.cpp
            )
        else()
            live555_add_executable(
                TARGET_NAME ${TEST_NAME}
                SOURCES ${TEST_SOURCE}
            )
        endif()
    endforeach()

    list(LENGTH TEST_PROG_SOURCES TEST_PROG_COUNT)
    message(STATUS "Built ${TEST_PROG_COUNT} test programs")
endif()
