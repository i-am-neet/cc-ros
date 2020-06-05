set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_VERSION 1)
#set(CMAKE_LIBRARY_ARCHITECTURE arm-linux-gnueabihf)
set(CMAKE_LIBRARY_ARCHITECTURE aarch64)

set( CMAKE_C_COMPILER   aarch64-linux-gcc)
set( CMAKE_CXX_COMPILER aarch64-linux-g++)
#set( CMAKE_C_COMPILER   "/opt/pi-tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin/arm-linux-gnueabihf-gcc")
#set( CMAKE_CXX_COMPILER "/opt/pi-tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin/arm-linux-gnueabihf-g++")

#set( CMAKE_C_COMPILER   "/usr/bin/arm-linux-gnueabihf-gcc")
#set( CMAKE_CXX_COMPILER "/usr/bin/arm-linux-gnueabihf-g++")

#set(CMAKE_FIND_ROOT_PATH "/opt/pi-tools/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf/arm-linux-gnueabihf/sysroot/")
set(CMAKE_FIND_ROOT_PATH "/home/developer/buildroot-2020.02.1/output/host/aarch64-buildroot-linux-gnu/sysroot")

#set(CMAKE_CXX_FLAGS "-Wl,-rpath-link,/home/erik/mnt/pi/lib/arm-linux/gnueabihf" CACHE STRING "" FORCE)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

#include_directories(/home/erik/mnt/pi/usr/include/arm-linux-gnueabihf/)
include_directories(/home/developer/buildroot-2020.02.1/output/host/aarch64-buildroot-linux-gnu/sysroot/usr/include/)
