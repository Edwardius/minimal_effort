cmake_minimum_required(VERSION 3.10)
project(perception)

# Set compiler to use C++ 17 standard
if(NOT CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 17)
endif()

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# Search for dependencies required for building this package
find_package(ament_cmake REQUIRED) # ROS2 build tool
find_package(rclcpp REQUIRED)      # ROS2 C++ package
find_package(sensor_msgs REQUIRED)
find_package(std_msgs REQUIRED)
find_package(nav_msgs REQUIRED)
find_package(image_transport REQUIRED)
find_package(OpenCV REQUIRED)
find_package(cv_bridge REQUIRED)

# Create ROS2 node executable from source files
add_executable(perception_node src/perception_node.cpp)
target_include_directories(perception_node
  PUBLIC include)
# Add ROS2 dependencies required by package
ament_target_dependencies(perception_node 
  rclcpp
  sensor_msgs
  std_msgs
  nav_msgs
  image_transport
  cv_bridge
  OpenCV
)

# Copy executable to installation location
install(TARGETS
  perception_node
  DESTINATION lib/${PROJECT_NAME})

# Copy launch and config files to installation location
install(DIRECTORY
  config
  DESTINATION share/${PROJECT_NAME})

ament_package()
