# Find required dependencies for live555

# Find OpenSSL
find_package(OpenSSL)
if(NOT OPENSSL_FOUND)
    # Try to find OpenSSL from Homebrew on macOS
    if(APPLE)
        execute_process(
            COMMAND brew --prefix openssl
            OUTPUT_VARIABLE OPENSSL_PREFIX
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
        )
        if(OPENSSL_PREFIX)
            set(OPENSSL_ROOT_DIR ${OPENSSL_PREFIX})
            find_package(OpenSSL REQUIRED)
        endif()
    endif()
endif()

if(OPENSSL_FOUND)
    message(STATUS "OpenSSL found: ${OPENSSL_VERSION}")
else()
    message(STATUS "OpenSSL not found - some features may be disabled")
    # Add NO_OPENSSL to compile definitions when OpenSSL is not found
    list(APPEND LIVE555_COMPILE_DEFINITIONS NO_OPENSSL=1)
endif()
