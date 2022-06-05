cmake_minimum_required (VERSION 3.0)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

set(CMAKE_CXX_FLAGS "-Wall -Wextra")
set(CMAKE_CXX_FLAGS_DEBUG "-g")
set(CMAKE_CXX_FLAGS_RELEASE "-O3")

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/output")

project(precomputed_atmosphere_scattering)

set(GLFW_BUILD_DOCS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/external/glfw)


include_directories(
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${CMAKE_CURRENT_SOURCE_DIR}/external
  ${CMAKE_CURRENT_SOURCE_DIR}/external/dimensional_types
  ${CMAKE_CURRENT_SOURCE_DIR}/external/glad/include
  ${CMAKE_CURRENT_SOURCE_DIR}/external/progress_bar
  ${CMAKE_CURRENT_SOURCE_DIR}/atmosphere)

add_executable(atmosphere_demo
  "${CMAKE_CURRENT_SOURCE_DIR}/atmosphere/demo/demo_main.cc"
  "${CMAKE_CURRENT_SOURCE_DIR}/atmosphere/demo/demo.cc"
  "${CMAKE_CURRENT_SOURCE_DIR}/atmosphere/model.cc"
  "${CMAKE_CURRENT_SOURCE_DIR}/external/glad/src/glad.cc"
  "${CMAKE_CURRENT_SOURCE_DIR}/text/text_renderer.cc"
)
target_link_libraries(atmosphere_demo glfw)

add_executable(precompute
  "${CMAKE_CURRENT_SOURCE_DIR}/atmosphere/demo/webgl/precompute.cc"
  "${CMAKE_CURRENT_SOURCE_DIR}/atmosphere/demo/demo.cc"
  "${CMAKE_CURRENT_SOURCE_DIR}/atmosphere/model.cc"
  "${CMAKE_CURRENT_SOURCE_DIR}/external/glad/src/glad.cc"
  "${CMAKE_CURRENT_SOURCE_DIR}/text/text_renderer.cc"
)
target_link_libraries(precompute glfw)

add_executable(test
  "${CMAKE_CURRENT_SOURCE_DIR}/atmosphere/reference/functions_test.cc"
  "${CMAKE_CURRENT_SOURCE_DIR}/atmosphere/reference/functions.cc"
  "${CMAKE_CURRENT_SOURCE_DIR}/external/dimensional_types/test/test_main.cc")

add_executable(integration_test
  "${CMAKE_CURRENT_SOURCE_DIR}/atmosphere/model.cc"
  "${CMAKE_CURRENT_SOURCE_DIR}/atmosphere/reference/functions.cc"
  "${CMAKE_CURRENT_SOURCE_DIR}/atmosphere/reference/model.cc"
  "${CMAKE_CURRENT_SOURCE_DIR}/atmosphere/reference/model_test.cc"
  "${CMAKE_CURRENT_SOURCE_DIR}/external/dimensional_types/test/test_main.cc"
  "${CMAKE_CURRENT_SOURCE_DIR}/external/glad/src/glad.cc"
  "${CMAKE_CURRENT_SOURCE_DIR}/external/progress_bar/util/progress_bar.cc")
target_link_libraries(integration_test glfw)
