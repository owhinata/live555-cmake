# Helper functions for creating live555 libraries and applications

# ============================================================================
# Compiler Warning Suppression
# ============================================================================
# live555 upstream code generates various warnings that are harmless but noisy.
# Instead of maintaining patches, we suppress these warnings via compiler flags.

if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang|AppleClang")
    set(LIVE555_WARNING_FLAGS
        -Wno-int-to-pointer-cast           # int used as hash key cast to pointer
        -Wno-pointer-to-int-cast           # pointer cast to int for hash operations
        -Wno-array-bounds                  # negative array index used as sentinel
        -Wno-deprecated-array-compare      # array comparison with == operator
        -Wno-format                        # format string type mismatches
    )
    if(APPLE)
        # macOS deprecates sprintf in favor of snprintf
        list(APPEND LIVE555_WARNING_FLAGS -Wno-deprecated-declarations)
    endif()
endif()

# ============================================================================
# Library Helper Functions
# ============================================================================

# Function to create a live555 library target
# Usage: live555_add_library(
#            TARGET_NAME <name>
#            SOURCE_DIR <dir>
#            INCLUDE_DIRS <dir1> [<dir2> ...]
#            [PRIVATE_INCLUDE_DIRS <dir1> [<dir2> ...]]
#            [LINK_LIBRARIES <lib1> [<lib2> ...]]
#            [EXCLUDE_SOURCES <file1> [<file2> ...]]
#            [EXTRA_SOURCES <file1> [<file2> ...]]
#        )
function(live555_add_library)
    cmake_parse_arguments(
        ARG
        ""
        "TARGET_NAME;SOURCE_DIR"
        "INCLUDE_DIRS;PRIVATE_INCLUDE_DIRS;LINK_LIBRARIES;EXCLUDE_SOURCES;EXTRA_SOURCES"
        ${ARGN}
    )

    if(NOT ARG_TARGET_NAME)
        message(FATAL_ERROR "TARGET_NAME is required")
    endif()

    if(NOT ARG_SOURCE_DIR)
        message(FATAL_ERROR "SOURCE_DIR is required")
    endif()

    # Collect source files (.cpp and .c)
    file(GLOB SOURCES ${ARG_SOURCE_DIR}/*.cpp ${ARG_SOURCE_DIR}/*.c)

    # Add extra sources if specified
    if(ARG_EXTRA_SOURCES)
        list(APPEND SOURCES ${ARG_EXTRA_SOURCES})
    endif()

    # Remove excluded sources if specified
    if(ARG_EXCLUDE_SOURCES)
        list(REMOVE_ITEM SOURCES ${ARG_EXCLUDE_SOURCES})
    endif()

    # Create library
    add_library(${ARG_TARGET_NAME} ${SOURCES})

    # Set public include directories
    if(ARG_INCLUDE_DIRS)
        target_include_directories(${ARG_TARGET_NAME} PUBLIC ${ARG_INCLUDE_DIRS})
    endif()

    # Set private include directories
    if(ARG_PRIVATE_INCLUDE_DIRS)
        target_include_directories(${ARG_TARGET_NAME} PRIVATE ${ARG_PRIVATE_INCLUDE_DIRS})
    endif()

    # Set compile definitions
    if(DEFINED LIVE555_COMPILE_DEFINITIONS)
        target_compile_definitions(${ARG_TARGET_NAME} PRIVATE ${LIVE555_COMPILE_DEFINITIONS})
    endif()

    # Suppress live555 upstream warnings
    if(DEFINED LIVE555_WARNING_FLAGS)
        target_compile_options(${ARG_TARGET_NAME} PRIVATE ${LIVE555_WARNING_FLAGS})
    endif()

    # Link libraries
    if(ARG_LINK_LIBRARIES)
        target_link_libraries(${ARG_TARGET_NAME} PUBLIC ${ARG_LINK_LIBRARIES})
    endif()
endfunction()

# ============================================================================
# Application Helper Functions
# ============================================================================

# Common libraries needed by all applications
set(LIVE555_COMMON_LIBS
    liveMedia
    groupsock
    BasicUsageEnvironment
    UsageEnvironment
)

# Common include directories
set(LIVE555_COMMON_INCLUDES
    ${LIVE555_DIR}/liveMedia/include
    ${LIVE555_DIR}/groupsock/include
    ${LIVE555_DIR}/UsageEnvironment/include
    ${LIVE555_DIR}/BasicUsageEnvironment/include
)

# Function to create a live555 application executable
# Usage: live555_add_executable(
#            TARGET_NAME <name>
#            SOURCES <file1> [<file2> ...]
#            [EXTRA_INCLUDE_DIRS <dir1> [<dir2> ...]]
#        )
function(live555_add_executable)
    cmake_parse_arguments(
        ARG
        ""
        "TARGET_NAME"
        "SOURCES;EXTRA_INCLUDE_DIRS"
        ${ARGN}
    )

    if(NOT ARG_TARGET_NAME)
        message(FATAL_ERROR "TARGET_NAME is required")
    endif()

    if(NOT ARG_SOURCES)
        message(FATAL_ERROR "SOURCES is required")
    endif()

    # Create executable
    add_executable(${ARG_TARGET_NAME} ${ARG_SOURCES})

    # Set include directories
    set(INCLUDE_DIRS ${LIVE555_COMMON_INCLUDES})
    if(ARG_EXTRA_INCLUDE_DIRS)
        list(APPEND INCLUDE_DIRS ${ARG_EXTRA_INCLUDE_DIRS})
    endif()
    target_include_directories(${ARG_TARGET_NAME} PRIVATE ${INCLUDE_DIRS})

    # Set compile definitions
    if(DEFINED LIVE555_COMPILE_DEFINITIONS)
        target_compile_definitions(${ARG_TARGET_NAME} PRIVATE ${LIVE555_COMPILE_DEFINITIONS})
    endif()

    # Suppress live555 upstream warnings
    if(DEFINED LIVE555_WARNING_FLAGS)
        target_compile_options(${ARG_TARGET_NAME} PRIVATE ${LIVE555_WARNING_FLAGS})
    endif()

    # Link libraries
    target_link_libraries(${ARG_TARGET_NAME} PRIVATE ${LIVE555_COMMON_LIBS})

    message(STATUS "Application: ${ARG_TARGET_NAME}")
endfunction()
