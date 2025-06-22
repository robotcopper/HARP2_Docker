#!/bin/bash
set -e

# Build YDLidar-SDK
cd /ros_ws/src/HARP2_ROS/ydlidar/YDLidar-SDK
mkdir -p build
cd build
cmake ..
make
sudo make install

cd /ros_ws

# Init rosdep si ce n’est pas déjà fait
sudo rosdep init 2>/dev/null || true
rosdep update

# Install deps
rosdep install --from-paths src --ignore-src -r -y

# Build
. /opt/ros/humble/setup.sh && \
colcon build --symlink-install

# Source automatique
echo "source /ros_ws/install/setup.bash" >> ~/.bashrc

