cmake_minimum_required(VERSION 3.9)
set(CMAKE_TOOLCHAIN_FILE "${CMAKE_SOURCE_DIR}/cmake/teensy-arm.toolchain.cmake")
set(PROJECT_NAME TeensySaber)
project(${PROJECT_NAME})

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/bin")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/lib")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/lib")
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

set(TEENSY_USB_MODE SERIAL)

include(Teensy)
import_arduino_library(EEPROM)
import_arduino_library(i2c_t3)
import_arduino_library(SD)
import_arduino_library(SD/utility)
import_arduino_library(SPI)

add_teensy_executable(lightsaber lightsaber.cpp)