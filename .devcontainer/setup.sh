#!/bin/bash
set -e

# ─── Submodules (depuis la racine du repo parent) ────────────────────────────
echo "==> Initialisation des submodules git..."
cd /workspaces/HARP2_Docker
git submodule update --init --recursive

# ─── Build YDLidar-SDK ───────────────────────────────────────────────────────
echo "==> Building YDLidar-SDK..."
cd ~/ros2_ws/src/HARP2_ROS/ydlidar/YDLidar-SDK

[ -d build ] && sudo rm -rf build
mkdir -p build
cd build
cmake ..
make
sudo make install

# ─── rosdep ──────────────────────────────────────────────────────────────────
echo "==> Initialisation rosdep..."
sudo rosdep init 2>/dev/null || true
rosdep update

sudo apt-get update -y

# ─── Compilation workspace ───────────────────────────────────────────────────
echo "==> Compilation du workspace ROS 2..."
cd ~/ros2_ws
. /opt/ros/humble/setup.sh && \
    MAKEFLAGS="-j4" colcon build \
        --symlink-install \
        --executor sequential \
        --parallel-workers 1 \
        --cmake-args -DCMAKE_BUILD_TYPE=Release

# ─── Sourcing automatique (sans doublons) ────────────────────────────────────
grep -qxF 'source /opt/ros/humble/setup.bash' ~/.bashrc || \
    echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc

grep -qxF 'source ~/ros2_ws/install/setup.bash' ~/.bashrc || \
    echo "source ~/ros2_ws/install/setup.bash" >> ~/.bashrc

grep -qxF 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' ~/.bashrc || \
    echo 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' >> ~/.bashrc

echo "==> Setup terminé ✔"
