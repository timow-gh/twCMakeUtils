function(checkIsVarBuildTypeDefined)
    if (NOT CMAKE_BUILD_TYPE)
        message(FATAL_ERROR "CMAKE_BUILD_TYPE not defined.")
        return()
    endif ()
endfunction()

macro(setMSVCOutputDirectories)
    if (MSVC)
        include(GNUInstallDirs)
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
endmacro()

function(preamble)
    checkIsVarBuildTypeDefined()
    setMSVCOutputDirectories()

    set_property(GLOBAL PROPERTY USE_FOLDERS ON)

    set(CMAKE_CXX_VISIBILITY_PRESET hidden PARENT_SCOPE)
    set(CMAKE_VISIBILITY_INLINES_HIDDEN 1 PARENT_SCOPE)

    if (${PROJECT_NAME}_INSTALL_LIB)
        include(GNUInstallDirs)
        if (NOT CMAKE_GENERATOR STREQUAL "Xcode")
            file(RELATIVE_PATH relDir
                    ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_BINDIR}
                    ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
            set(CMAKE_INSTALL_RPATH $ORIGIN $ORIGIN/${relDir} PARENT_SCOPE)
        endif ()
    endif ()
endfunction()

function(setupExportSetInstall project_name export_set)
    include(CMakePackageConfigHelpers)

    if (NOT EXISTS "${PROJECT_SOURCE_DIR}/cmake/Config.cmake.in")
        message(FATAL_ERROR "Missing file Config.cmake.in")
        return()
    endif ()

    set(${project_name}_INSTALL_CMAKEDIR
            "${CMAKE_INSTALL_LIBDIR}/cmake/${project_name}"
            CACHE STRING "Path to install ${project_name} Config*.cmake files to.")
    set(${project_name}_MODULE_INSTALL_DIR
            "${CMAKE_INSTALL_LIBDIR}/cmake"
            CACHE STRING "Path to install ${project_name}'s .cmake  module files to.")

    install(EXPORT ${export_set}
            NAMESPACE ${project_name}::
            FILE ${project_name}Targets.cmake
            DESTINATION ${${project_name}_INSTALL_CMAKEDIR})

    write_basic_package_version_file(
            ${CMAKE_BINARY_DIR}/${project_name}ConfigVersion.cmake
            VERSION ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}
            COMPATIBILITY SameMajorVersion)

    configure_package_config_file(
            ${PROJECT_SOURCE_DIR}/cmake/Config.cmake.in
            ${CMAKE_BINARY_DIR}/${project_name}Config.cmake
            INSTALL_DESTINATION ${${project_name}_INSTALL_CMAKEDIR}
            PATH_VARS ${project_name}_MODULE_INSTALL_DIR
            NO_SET_AND_CHECK_MACRO
            NO_CHECK_REQUIRED_COMPONENTS_MACRO)

    install(FILES
            "${CMAKE_BINARY_DIR}/${project_name}Config.cmake"
            "${CMAKE_BINARY_DIR}/${project_name}ConfigVersion.cmake"
            DESTINATION ${${project_name}_INSTALL_CMAKEDIR})
endfunction()