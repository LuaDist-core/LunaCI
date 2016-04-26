# Generated Cmake file begin
cmake_minimum_required(VERSION 3.1)

project(LunaCI C CXX)

find_package(Lua REQUIRED)

## INSTALL DEFAULTS (Relative to CMAKE_INSTALL_PREFIX)
# Primary paths
set(INSTALL_BIN bin CACHE PATH "Where to install binaries to.")
set(INSTALL_LIB lib CACHE PATH "Where to install libraries to.")
set(INSTALL_ETC etc CACHE PATH "Where to store configuration files")
set(INSTALL_SHARE share CACHE PATH "Directory for shared data.")

set(INSTALL_LMOD ${INSTALL_LIB}/lua/${LUA_VERSION_MAJOR}.${LUA_VERSION_MINOR} CACHE PATH "Directory to install Lua modules.")
set(INSTALL_CMOD ${INSTALL_LIB}/lua/${LUA_VERSION_MAJOR}.${LUA_VERSION_MINOR} CACHE PATH "Directory to install Lua binary modules.")

set(lunaci.utils_SOURCES lunaci/utils.lua)
set(lunaci.Manager_SOURCES lunaci/Manager.lua)
set(lunaci.log_SOURCES lunaci/log.lua)
set(lunaci_SOURCES lunaci.lua)
set(lunaci.PackageReport_SOURCES lunaci/PackageReport.lua)
set(lunaci.Worker_SOURCES lunaci/Worker.lua)
set(lunaci.Cache_SOURCES lunaci/Cache.lua)
set(lunaci.config_SOURCES lunaci/config.lua.in)
set(lunaci.tasks.require_SOURCES lunaci/tasks/require.lua)
set(lunaci.tasks.dependencies_SOURCES lunaci/tasks/dependencies.lua)
set(lunaci.ReportGenerator_SOURCES lunaci/ReportGenerator.lua)
set(lunaci.tasks.build_SOURCES lunaci/tasks/build.lua)

install(DIRECTORY ${BUILD_COPY_DIRECTORIES} DESTINATION ${INSTALL_SHARE}/LunaCI)

# Install report templates
set(LUNACI_TEMPLATE_DIR ${INSTALL_SHARE}/LunaCI/templates)
install(DIRECTORY templates/ DESTINATION ${LUNACI_TEMPLATE_DIR}/)

# Set config variables
configure_file ( lunaci/config.lua.in lunaci/config.lua @ONLY )
install(FILES ${CMAKE_BINARY_DIR}/lunaci/config.lua DESTINATION ${INSTALL_LMOD}/lunaci RENAME config.lua)

function(build_install KEYS DIR)
    list(REMOVE_DUPLICATES KEYS)

    foreach(KEY ${${KEYS}})
        set(BASE_NAME ${KEYS}_${KEY})
        install(FILES ${${BASE_NAME}_SRC} DESTINATION ${DIR}/${${BASE_NAME}_DST} RENAME ${${BASE_NAME}_RENAME})
    endforeach(KEY)
endfunction(build_install)

build_install(BUILD_INSTALL_lua ${INSTALL_LMOD})
build_install(BUILD_INSTALL_lib ${INSTALL_LIB})
build_install(BUILD_INSTALL_conf ${INSTALL_ETC})
build_install(BUILD_INSTALL_bin ${INSTALL_BIN})

install(FILES ${lunaci.ReportGenerator_SOURCES} DESTINATION ${INSTALL_LMOD}/lunaci RENAME ReportGenerator.lua)
install(FILES ${lunaci.PackageReport_SOURCES} DESTINATION ${INSTALL_LMOD}/lunaci RENAME PackageReport.lua)
install(FILES ${lunaci.tasks.dependencies_SOURCES} DESTINATION ${INSTALL_LMOD}/lunaci/tasks RENAME dependencies.lua)
install(FILES ${lunaci.Cache_SOURCES} DESTINATION ${INSTALL_LMOD}/lunaci RENAME Cache.lua)
install(FILES ${lunaci.tasks.build_SOURCES} DESTINATION ${INSTALL_LMOD}/lunaci/tasks RENAME build.lua)
install(FILES ${lunaci.tasks.require_SOURCES} DESTINATION ${INSTALL_LMOD}/lunaci/tasks RENAME require.lua)
install(FILES ${lunaci_SOURCES} DESTINATION ${INSTALL_LMOD}/ RENAME lunaci.lua)
install(FILES ${lunaci.Worker_SOURCES} DESTINATION ${INSTALL_LMOD}/lunaci RENAME Worker.lua)
install(FILES ${lunaci.Manager_SOURCES} DESTINATION ${INSTALL_LMOD}/lunaci RENAME Manager.lua)
install(FILES ${lunaci.log_SOURCES} DESTINATION ${INSTALL_LMOD}/lunaci RENAME log.lua)
install(FILES ${lunaci.utils_SOURCES} DESTINATION ${INSTALL_LMOD}/lunaci RENAME utils.lua)
