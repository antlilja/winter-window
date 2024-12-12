cmake_minimum_required(VERSION 3.28)
project(realsense-extension)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

include(FetchContent)
set(GODOT_DISABLE_EXCEPTIONS OFF CACHE INTERNAL "Enable exceptions") # Exceptions required by librealsense
FetchContent_Declare(
        GDExtension
        GIT_REPOSITORY https://github.com/godotengine/godot-cpp.git
        GIT_TAG godot-4.3-stable
)
FetchContent_MakeAvailable(GDExtension)

add_library(realsense-extension SHARED
  src/realsense.cpp
  src/register_types.cpp
)

if(DEFINED REALSENSE2_SDK_ROOT)
    find_path(realsense2_INCLUDE_DIRS NAMES librealsense2/rs.hpp PATHS ${REALSENSE2_SDK_ROOT}/include)
    find_library(realsense2_LIBRARY NAMES realsense2 PATHS ${REALSENSE2_SDK_ROOT}/lib ${REALSENSE2_SDK_ROOT}/lib/x64 ${REALSENSE2_SDK_ROOT}/bin ${REALSENSE2_SDK_ROOT}/bin/x64)
else()
    find_package(realsense2 REQUIRED)
endif()

target_include_directories(realsense-extension PRIVATE
  src
  ${realsense2_INCLUDE_DIRS}
)

target_link_libraries(realsense-extension PUBLIC
  godot::cpp
  ${realsense2_LIBRARY}
)

install(TARGETS realsense-extension
  ARCHIVE DESTINATION .
  LIBRARY DESTINATION .
  RUNTIME DESTINATION .
)
