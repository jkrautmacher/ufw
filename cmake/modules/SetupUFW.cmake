if(__UFW_SetupUFW)
  return()
endif()
set(__UFW_SetupUFW 1)

function(ufw_add_board name)
  cmake_parse_arguments(PA "" "BUILDSYSTEM" "TOOLCHAINS;BUILDTYPES" ${ARGN})
  set(boards ${UFW_TOPLEVEL_BOARDS})
  list(FIND boards ${name} already_defined)
  if (${already_defined} GREATER_EQUAL 0)
    message(FATAL_ERROR "Board ${name} already added.")
  endif()
  list(APPEND boards ${name})
  set(UFW_TOPLEVEL_BOARDS ${boards} PARENT_SCOPE)
  if (NOT PA_TOOLCHAINS)
    message(FATAL_ERROR "Please define TOOLCHAINS for board ${name}")
  endif()
  if (NOT PA_BUILDTYPES)
    set(PA_BUILDTYPES Release Debug)
  endif()
  set(UFW_TOPLEVEL_BOARD_BUILDTYPES_${name} ${PA_BUILDTYPES} PARENT_SCOPE)
  set(UFW_TOPLEVEL_BOARD_TOOLCHAINS_${name} ${PA_TOOLCHAINS} PARENT_SCOPE)
  if (PA_BUILDSYSTEM)
    set(UFW_TOPLEVEL_BOARD_BUILDSYSTEM_${name} ${PA_BUILDSYSTEM} PARENT_SCOPE)
  endif()
endfunction()

macro(ufw_recursive_dispatch)
  if (NOT TARGET_BOARD)
    foreach (board ${UFW_TOPLEVEL_BOARDS})
      foreach (chain ${UFW_TOPLEVEL_BOARD_TOOLCHAINS_${board}})
        foreach (cfg ${UFW_TOPLEVEL_BOARD_BUILDTYPES_${board}})
          build_in_target_dir(
            BOARD ${board}
            TOOLCHAIN ${chain}
            BUILDCFG ${cfg})
        endforeach()
      endforeach()
    endforeach()
    return()
  endif()
endmacro()

macro(ufw_subtree_build)
  if (UFW_TOPLEVEL_BOARD_BUILDSYSTEM_${TARGET_BOARD})
    include(${UFW_TOPLEVEL_BOARD_BUILDSYSTEM_${TARGET_BOARD}})
    return()
  endif()
endmacro()

function(__ufw_toplevel_args)
  cmake_parse_arguments(PA "" "ROOT;ARTIFACTS" "MODULES" ${ARGN})
  if (NOT PA_ARTIFACTS)
    message(FATAL_ERROR "ufw_toplevel: Please specify ARTIFACTS destination!")
  endif()
  if (NOT PA_ROOT)
    message(FATAL_ERROR "ufw_toplevel: Please specify UFW ROOT directory!")
  endif()
  set(EMBEDDED_CMAKE 1 PARENT_SCOPE)
  set(MICROFRAMEWORK_ROOT "${PA_ROOT}" PARENT_SCOPE)
  set(UFW_ARTIFACTS_DIRECTORY "${PA_ARTIFACTS}" PARENT_SCOPE)
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${PA_ARTIFACTS}" PARENT_SCOPE)
  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${PA_ARTIFACTS}" PARENT_SCOPE)
  set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${PA_ARTIFACTS}" PARENT_SCOPE)
  if (PA_MODULES)
    set(loadpath ${CMAKE_MODULE_PATH})
    list(APPEND loadpath ${PA_MODULES})
    set(CMAKE_MODULE_PATH ${loadpath} PARENT_SCOPE)
  endif()
endfunction()

macro(ufw_toplevel)
  __ufw_toplevel_args(${ARGV})
  include(BuildInTargetDir)
  include(HardwareAbstraction)
  include(CTest)
endmacro()

function(setup_ufw)
  if (MICROFRAMEWORK_ROOT)
    set(_dir "${MICROFRAMEWORK_ROOT}")
  else()
    if (NOT ARGV0)
      message(FATAL_ERROR "setup_ufw used without ufw root directory!")
    endif()
    set(_dir "${CMAKE_CURRENT_SOURCE_DIR}/${ARGV0}")
    set(MICROFRAMEWORK_ROOT "${_dir}" PARENT_SCOPE)
  endif()
  add_subdirectory(${_dir})
endfunction()
