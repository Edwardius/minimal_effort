ARG BASE_IMAGE=arm64v8/ros:humble-ros-base-jammy

################################ Source ################################
FROM ${BASE_IMAGE} AS source
ENV AMENT_WS=/home/pi/ament_ws

WORKDIR ${AMENT_WS}/src

# Scan for rosdeps
RUN apt-get -qq update && rosdep update && \
    rosdep install --from-paths . --ignore-src -r -s \
        | grep 'apt-get install' \
        | awk '{print $3}' \
        | sort  > /tmp/colcon_install_list

################################# Dependencies ################################
FROM ${BASE_IMAGE} AS dependencies
ENV AMENT_WS=/home/pi/ament_ws

# Install Foxglove Deps
RUN apt-get update && apt-get install -y curl ros-humble-ros2bag ros-humble-rosbag2* ros-humble-foxglove-msgs&& \
    rm -rf /var/lib/apt/lists/*

# Set up apt repo
RUN apt-get update && apt-get install -y lsb-release software-properties-common apt-transport-https && \
    apt-add-repository universe

# Install Dependencies
RUN apt-get update && \
    apt-get install -y \ 
    ros-$ROS_DISTRO-foxglove-bridge \
    ros-$ROS_DISTRO-rosbridge-server \
    ros-$ROS_DISTRO-topic-tools \
    ros-$ROS_DISTRO-vision-msgs

# Install Rosdep requirements
COPY --from=source /tmp/colcon_install_list /tmp/colcon_install_list
RUN apt-get install -qq -y --no-install-recommends $(cat /tmp/colcon_install_list)

# Copy in source code from source stage
WORKDIR ${AMENT_WS}
COPY --from=source ${AMENT_WS}/src src

# Dependency Cleanup
WORKDIR /
RUN apt-get -qq autoremove -y && apt-get -qq autoclean && apt-get -qq clean && \
    rm -rf /root/* /root/.ros /tmp/* /var/lib/apt/lists/* /usr/share/doc/*

################################ Build ################################
FROM dependencies AS build
ENV AMENT_WS=/home/pi/ament_ws
ARG MINIMAL_EFFORT_INSTALL=/opt/minimal_effort/

# Build ROS2 packages
WORKDIR ${AMENT_WS}
RUN . /opt/ros/$ROS_DISTRO/setup.sh && \
    colcon build \
        --cmake-args -DCMAKE_BUILD_TYPE=Release --install-base ${MINIMAL_EFFORT_INSTALL}

# Source and Build Artifact Cleanup 
RUN rm -rf src/* build/* devel/* install/* log/*

# Entrypoint will run before any CMD on launch. Sources ~/opt/<ROS_DISTRO>/setup.bash and ~/ament_ws/install/setup.bash
COPY docker/min_ros_entrypoint.sh ${AMENT_WS}/min_ros_entrypoint.sh
ENTRYPOINT ["./min_ros_entrypoint.sh"]
