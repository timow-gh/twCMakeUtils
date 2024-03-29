function(checkIsVarBuildTypeDefined)
    if (NOT CMAKE_BUILD_TYPE)
        message(FATAL_ERROR "CMAKE_BUILD_TYPE not defined.")
        return()
    endif ()
endfunction()

function(preamble)
    checkIsVarBuildTypeDefined()
    include(GNUInstallDirs)
    if (MSVC)
        set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

        if (NOT CMAKE_RUNTIME_OUTPUT_DIRECTORY)
            set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR} PARENT_SCOPE)
        endif ()
        if (NOT CMAKE_LIBRARY_OUTPUT_DIRECTORY)
            #CMAKE_INSTALL_LIBDIR
            set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR} PARENT_SCOPE)
        endif ()
        if (NOT CMAKE_ARCHIVE_OUTPUT_DIRECTORY)
            #CMAKE_INSTALL_LIBDIR
            set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR} PARENT_SCOPE)
        endif ()
    endif ()

    set_property(GLOBAL PROPERTY USE_FOLDERS ON)

    set(CMAKE_CXX_VISIBILITY_PRESET hidden PARENT_SCOPE)
    set(CMAKE_VISIBILITY_INLINES_HIDDEN 1 PARENT_SCOPE)

    if (NOT CMAKE_GENERATOR STREQUAL "Xcode")
        file(RELATIVE_PATH relDir
                ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_BINDIR}
                ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
        set(CMAKE_INSTALL_RPATH $ORIGIN $ORIGIN/${relDir} PARENT_SCOPE)
    endif ()
endfunction()

function(setupExportSetInstall proj_config_name export_set_name)
    include(GNUInstallDirs)
    include(CMakePackageConfigHelpers)

    set(${proj_config_name}_CONFIG_IN_FILE
            "${PROJECT_SOURCE_DIR}/cmake/Config.cmake.in"
            CACHE STRING "Path to the ${project_name} Config*.cmake.in file.")

    message(STATUS "${project_name} Config.cmake.in file path: ${${proj_config_name}_CONFIG_IN_FILE}")

    if (NOT EXISTS "${${proj_config_name}_CONFIG_IN_FILE}")
        message(STATUS "Absolute Config.cmake.in path: ${${proj_config_name}_CONFIG_IN_FILE}")
        message(FATAL_ERROR "Missing file Config.cmake.in")
        return()
    endif ()

    write_basic_package_version_file(
            ${CMAKE_BINARY_DIR}/${proj_config_name}ConfigVersion.cmake
            VERSION ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}
            COMPATIBILITY SameMajorVersion)

    # Name of ${proj_config_name}'s targets file.
    set(projTargetsFileName "${proj_config_name}Targets")

    # The cmake module path for ${proj_config_name}.
    set(cmakeModulesDir "${CMAKE_INSTALL_LIBDIR}/cmake")

    # Installation path for ${proj_config_name} files.
    set(cmakeProjDir "${cmakeModulesDir}/${proj_config_name}")

    # Installation path and file name of ${proj_config_name}'s targets file.
    set(cmakeProjTargetsFilePath "${cmakeProjDir}/${projTargetsFileName}")

    configure_package_config_file(
            ${${proj_config_name}_CONFIG_IN_FILE}
            ${CMAKE_BINARY_DIR}/${proj_config_name}Config.cmake
            INSTALL_DESTINATION ${cmakeProjDir}
            PATH_VARS cmakeModulesDir cmakeProjTargetsFilePath
            NO_SET_AND_CHECK_MACRO
            NO_CHECK_REQUIRED_COMPONENTS_MACRO)

    install(EXPORT ${export_set_name}
            NAMESPACE ${proj_config_name}::
            FILE ${projTargetsFileName}.cmake
            DESTINATION "${cmakeProjDir}/")

    install(FILES
            "${CMAKE_BINARY_DIR}/${proj_config_name}Config.cmake"
            "${CMAKE_BINARY_DIR}/${proj_config_name}ConfigVersion.cmake"
            DESTINATION "${cmakeProjDir}/")
endfunction()

macro(setup_google_test_using_fetch_content)
    if (TARGET gtest)
        message(STATUS "gtest is already configured.")
    else ()
        option(INSTALL_GTEST OFF)
        mark_as_advanced(BUILD_GMOCK)
        mark_as_advanced(BUILD_TESTING)
        mark_as_advanced(INSTALL_GTEST)

        FetchContent_Declare(
                googletest
                GIT_REPOSITORY https://github.com/google/googletest.git
                GIT_TAG release-1.12.1
        )
        FetchContent_MakeAvailable(googletest)

        # For Windows: Prevent overriding the parent project's compiler/linker settings
        set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
        FetchContent_MakeAvailable(googletest)

        if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
            target_compile_options(gtest_main INTERFACE
                    "-Wno-weak-vtables"
                    )
        endif ()

        mark_as_advanced(FETCHCONTENT_BASE_DIR)
        mark_as_advanced(FETCHCONTENT_FULLY_DISCONNECTED)
        mark_as_advanced(FETCHCONTENT_QUIET)
        mark_as_advanced(FETCHCONTENT_SOURCE_DIR_GOOGLETEST)
        mark_as_advanced(FETCHCONTENT_UPDATES_DISCONNECTED)
        mark_as_advanced(FETCHCONTENT_UPDATES_DISCONNECTED_GOOGLETEST)
    endif ()
endmacro()