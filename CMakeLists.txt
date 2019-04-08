cmake_minimum_required(VERSION 3.0)

#Avoid cmake from test compiling to host
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

project (starbase)
if (NOT DEFINED CONAN_DEPENDENCIES)
  include(${CMAKE_CURRENT_BINARY_DIR}/conanbuildinfo.cmake OPTIONAL RESULT_VARIABLE HAS_CONAN)
  if (NOT HAS_CONAN)
    message(FATAL_ERROR "missing conanbuildinfo.cmake did you forget to run conan install ?")
  endif()
endif()
conan_basic_setup()

include(os)

os_add_executable(starbase "Starbase" service.cpp)
os_add_drivers(starbase virtionet vmxnet3 e1000 boot_logger timestamps)
os_add_plugins(starbase autoconf system_log)
os_add_stdout(starbase default_stdout)
os_add_stdout(starbase vga_output)
