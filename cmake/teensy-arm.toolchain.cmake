# Copyright (c) 2015, Pierre-Andre Saulais <pasaulais@free.fr>
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer. 
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
include(CMakeForceCompiler)

set(TRIPLE "arm-none-eabi")

set(ARDUINO_ROOT "/Applications/Arduino.app" CACHE PATH "Path to the Arduino application")
set(TEENSY_CORES_ROOT "${ARDUINO_ROOT}/Contents/Java/hardware/teensy/avr/cores" CACHE PATH "Path to the Teensy 'cores' repository")
set(TEENSY_ROOT "${TEENSY_CORES_ROOT}/teensy3")
set(TOOLCHAIN_ROOT ${ARDUINO_ROOT}/Contents/Java/hardware/tools/arm)
set(ARDUINO_LIB_ROOT "${ARDUINO_ROOT}/Contents/Java/hardware/teensy/avr/libraries" CACHE PATH "Path to the Arduino library directory")
set(ARDUINO_VERSION "10805" CACHE STRING "Version of the Arduino SDK")
set(TEENSYDUINO_VERSION "141" CACHE STRING "Version of the Teensyduino SDK")
#set(TEENSY_MODEL "MK20DX256" CACHE STRING "Model of the Teensy MCU")
set(TEENSY_MODEL "MK20DX256") # XXX Add Teensy 3.0 support.

set(TEENSY_FREQUENCY "96" CACHE STRING "Frequency of the Teensy MCU (Mhz)")
set_property(CACHE TEENSY_FREQUENCY PROPERTY STRINGS 96 72 48 24 16 8 4 2)

set(TEENSY_USB_MODE "SERIAL" CACHE STRING "What kind of USB device the Teensy should emulate")
set_property(CACHE TEENSY_USB_MODE PROPERTY STRINGS SERIAL HID SERIAL_HID MIDI RAWHID FLIGHTSIM)

if(WIN32)
    set(TOOL_OS_SUFFIX .exe)
else(WIN32)
    set(TOOL_OS_SUFFIX )
endif(WIN32)

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)
set(CMAKE_CROSSCOMPILING 1)

set(CMAKE_C_COMPILER "${TOOLCHAIN_ROOT}/bin/${TRIPLE}-gcc${TOOL_OS_SUFFIX}" CACHE PATH "gcc" FORCE)
set(CMAKE_CXX_COMPILER "${TOOLCHAIN_ROOT}/bin/${TRIPLE}-g++${TOOL_OS_SUFFIX}" CACHE PATH "g++" FORCE)
set(CMAKE_AR "${TOOLCHAIN_ROOT}/bin/${TRIPLE}-gcc-ar${TOOL_OS_SUFFIX}" CACHE PATH "archive" FORCE)
set(CMAKE_OBJCOPY "${TOOLCHAIN_ROOT}/bin/${TRIPLE}-objcopy${TOOL_OS_SUFFIX}" CACHE PATH "objcopy" FORCE)
set(CMAKE_OBJDUMP "${TOOLCHAIN_ROOT}/bin/${TRIPLE}-objdump${TOOL_OS_SUFFIX}" CACHE PATH "objdump" FORCE)

include_directories("${TEENSY_ROOT}")

set(TARGET_FLAGS "-mthumb -mcpu=cortex-m4 -fsingle-precision-constant")
set(BASE_FLAGS "-O2 -g -Wall -ffunction-sections -fdata-sections -nostdlib ${TARGET_FLAGS}")

set(CMAKE_C_FLAGS "${BASE_FLAGS}" CACHE STRING "c flags")
set(CMAKE_CXX_FLAGS "${BASE_FLAGS} -fno-exceptions -felide-constructors -std=gnu++14 -fno-rtti" CACHE STRING "c++ flags")

set(TEENSY_S_FLAGS "-x assembler-with-cpp")

set(CMAKE_CXX_COMPILE_OBJECT "<CMAKE_CXX_COMPILER> -c <FLAGS> <DEFINES> <INCLUDES> <SOURCE> -o <OBJECT>")
set(CMAKE_C_COMPILE_OBJECT "<CMAKE_C_COMPILER> -c <FLAGS> <DEFINES> <INCLUDES> <SOURCE> -o <OBJECT>")

set(CMAKE_CXX_ARCHIVE_CREATE "<CMAKE_AR> rcs <TARGET> <LINK_FLAGS> <OBJECTS>")
set(CMAKE_C_ARCHIVE_CREATE "<CMAKE_AR> rcs <TARGET> <LINK_FLAGS> <OBJECTS>")

set(LINKER_FLAGS "-O2 -Wl,--gc-sections,--relax,--defsym=__rtc_localtime=1421620748 -T${TEENSY_ROOT}/mk20dx256.ld -lstdc++ ${TARGET_FLAGS}" )
set(LINKER_LIBS "-larm_cortexM4l_math -lm" )

set(CMAKE_SHARED_LINKER_FLAGS "${LINKER_FLAGS}" CACHE STRING "linker flags" FORCE)
set(CMAKE_MODULE_LINKER_FLAGS "${LINKER_FLAGS}" CACHE STRING "linker flags" FORCE)
set(CMAKE_EXE_LINKER_FLAGS "${LINKER_FLAGS}" CACHE STRING "linker flags" FORCE)

# Do not pass flags like '-ffunction-sections -fdata-sections' to the linker.
# This causes undefined symbol errors when linking.
set(CMAKE_CXX_LINK_EXECUTABLE "<CMAKE_C_COMPILER> <CMAKE_CXX_LINK_FLAGS> <LINK_FLAGS> -o <TARGET> <OBJECTS> <LINK_LIBRARIES> ${LINKER_LIBS}" CACHE STRING "Linker command line" FORCE)

add_definitions("-DARDUINO=${ARDUINO_VERSION}")
add_definitions("-DTEENSYDUINO=${TEENSYDUINO_VERSION}")
add_definitions("-D__${TEENSY_MODEL}__")
add_definitions(-DLAYOUT_US_ENGLISH)
add_definitions(-MMD)
