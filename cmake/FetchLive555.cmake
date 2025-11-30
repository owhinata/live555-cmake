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

# Apply patches if requested
if(APPLY_LIVE555_PATCHES)
    set(PATCH_DIR "${CMAKE_SOURCE_DIR}/patches")
    set(PATCH_STAMP "${CMAKE_BINARY_DIR}/live555_patches_applied.stamp")

    # Check if patches have already been applied
    if(NOT EXISTS "${PATCH_STAMP}")
        message(STATUS "Applying live555 warning fix patches...")

        # Apply each patch in order
        set(PATCHES
            "${PATCH_DIR}/01-fix-int-to-pointer-casts.patch"
            "${PATCH_DIR}/02-fix-array-bounds.patch"
            "${PATCH_DIR}/03-fix-array-compare.patch"
            "${PATCH_DIR}/04-fix-sprintf-deprecation.patch"
        )

        foreach(PATCH_FILE ${PATCHES})
            if(EXISTS "${PATCH_FILE}")
                execute_process(
                    COMMAND patch -p1 --forward --no-backup-if-mismatch --reject-file=- -d "${LIVE555_DIR}" -i "${PATCH_FILE}"
                    RESULT_VARIABLE PATCH_RESULT
                    OUTPUT_VARIABLE PATCH_OUTPUT
                    ERROR_VARIABLE PATCH_ERROR
                )

                if(NOT PATCH_RESULT EQUAL 0)
                    message(WARNING "Failed to apply patch: ${PATCH_FILE}\n${PATCH_ERROR}")
                else()
                    get_filename_component(PATCH_NAME "${PATCH_FILE}" NAME)
                    message(STATUS "  Applied: ${PATCH_NAME}")
                endif()
            else()
                message(WARNING "Patch file not found: ${PATCH_FILE}")
            endif()
        endforeach()

        # Create stamp file to mark patches as applied
        file(WRITE "${PATCH_STAMP}" "Patches applied on ${CMAKE_CURRENT_LIST_FILE}")
        message(STATUS "All patches applied successfully")
    else()
        message(STATUS "Patches already applied (stamp file exists)")
    endif()
else()
    message(STATUS "Patch application disabled (APPLY_LIVE555_PATCHES=OFF)")
endif()
