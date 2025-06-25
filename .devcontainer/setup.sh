#!/bin/bash
set -e

cd ~/ros2_ws/src/HARP2_ROS/ydlidar/YDLidar-SDK

# Build YDLidar-SDK
echo "Contenu du dossier courant au début :"
ls
#cd src/HARP2_ROS/ydlidar/YDLidar-SDK
[ -d build ] && sudo rm -r build
mkdir -p build
cd build
cmake ..
make
sudo make install

cd ~/ros2_ws

sudo apt update
# Init rosdep si ce n’est pas déjà fait
sudo rosdep init 2>/dev/null || true
rosdep update

# Install deps
# rosdep install --from-paths ~/ros2_ws/src --ignore-src --skip-keys="gazebo libgazebo-dev ros-humble-warehouse-ros-mongo" -r -y

# Build
. /opt/ros/humble/setup.sh && \
colcon build --symlink-install

# Automatic sourcing
echo "source ~/ros2_ws/install/setup.bash" >> ~/.bashrc
echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' >> ~/.bashrc
