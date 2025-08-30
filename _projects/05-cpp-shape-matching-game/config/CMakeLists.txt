cmake_minimum_required(VERSION 3.10)
project(ShapeHuntGame)

# Set C++ standard
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Add include directories
include_directories(headers)

# Find CMU Graphics library (adjust path as needed)
# set(CMU_GRAPHICS_PATH "/path/to/cmu/graphics")
# include_directories(${CMU_GRAPHICS_PATH})
# link_directories(${CMU_GRAPHICS_PATH})

# Collect all source files
file(GLOB SOURCES "source/*.cpp")
file(GLOB HEADERS "headers/*.h")

# Create executable
add_executable(ShapeHuntGame ${SOURCES} ${HEADERS})

# Link CMU Graphics library (adjust library names as needed)
# target_link_libraries(ShapeHuntGame CMUgraphics)

# For Windows, you might need additional libraries
if(WIN32)
    target_link_libraries(ShapeHuntGame user32 gdi32)
endif()
