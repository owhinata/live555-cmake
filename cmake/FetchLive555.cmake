# Download and extract live555 source code
# Expects LIVE555_VERSION to be set by parent CMakeLists.txt

if(NOT DEFINED LIVE555_VERSION)
    message(FATAL_ERROR "LIVE555_VERSION must be set before including FetchLive555.cmake")
endif()

set(LIVE555_URL "http://live555.com/liveMedia/public/live.${LIVE555_VERSION}.tar.gz")
set(LIVE555_TARBALL "${CMAKE_SOURCE_DIR}/live.${LIVE555_VERSION}.tar.gz")
set(LIVE555_DIR "${CMAKE_SOURCE_DIR}/live")

# Download if tarball doesn't exist
if(NOT EXISTS "${LIVE555_TARBALL}")
    message(STATUS "Downloading live555 ${LIVE555_VERSION}...")
    file(DOWNLOAD
        "${LIVE555_URL}"
        "${LIVE555_TARBALL}"
        SHOW_PROGRESS
        STATUS DOWNLOAD_STATUS
    )
    list(GET DOWNLOAD_STATUS 0 DOWNLOAD_ERROR)
    if(NOT DOWNLOAD_ERROR EQUAL 0)
        list(GET DOWNLOAD_STATUS 1 DOWNLOAD_ERROR_MSG)
        file(REMOVE "${LIVE555_TARBALL}")
        message(FATAL_ERROR "Failed to download live555: ${DOWNLOAD_ERROR_MSG}")
    endif()
endif()

# Extract if source directory doesn't exist
if(NOT EXISTS "${LIVE555_DIR}")
    message(STATUS "Extracting live555...")
    file(ARCHIVE_EXTRACT
        INPUT "${LIVE555_TARBALL}"
        DESTINATION "${CMAKE_SOURCE_DIR}"
    )
    if(NOT EXISTS "${LIVE555_DIR}")
        message(FATAL_ERROR "Failed to extract live555 - directory not found after extraction")
    endif()
endif()

message(STATUS "live555 source available at: ${LIVE555_DIR}")
message(STATUS "live555 version: ${LIVE555_VERSION}")
