##############################################
# Created from template ros2.dockerfile.jinja
##############################################

###########################################
# Base image
###########################################
FROM ubuntu:22.04 AS base

ENV DEBIAN_FRONTEND=noninteractive

# Install language
RUN apt-get update && apt-get install -y --no-install-recommends \
  locales \
  && locale-gen en_US.UTF-8 \
  && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
  && rm -rf /var/lib/apt/lists/*
ENV LANG=en_US.UTF-8

# Install timezone
RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime \
  && export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get install -y --no-install-recommends tzdata \
  && dpkg-reconfigure --frontend noninteractive tzdata \
  && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get -y upgrade \
    && rm -rf /var/lib/apt/lists/*

# Install common programs
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    gnupg2 \
    lsb-release \
    sudo \
    software-properties-common \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install ROS2
RUN sudo add-apt-repository universe \
  && curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null \
  && apt-get update && apt-get install -y --no-install-recommends \
    ros-humble-ros-base \
    python3-argcomplete \
  && rm -rf /var/lib/apt/lists/*

ENV ROS_DISTRO=humble
ENV AMENT_PREFIX_PATH=/opt/ros/humble
ENV COLCON_PREFIX_PATH=/opt/ros/humble
ENV LD_LIBRARY_PATH=/opt/ros/humble/lib/x86_64-linux-gnu:/opt/ros/humble/lib
ENV PATH=/opt/ros/humble/bin:$PATH
ENV PYTHONPATH=/opt/ros/humble/local/lib/python3.10/dist-packages:/opt/ros/humble/lib/python3.10/site-packages
ENV ROS_PYTHON_VERSION=3
ENV ROS_VERSION=2
ENV ROS_AUTOMATIC_DISCOVERY_RANGE=SUBNET
ENV DEBIAN_FRONTEND=

###########################################
#  Develop image
###########################################
FROM base AS dev

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
  bash-completion \
  build-essential \
  cmake \
  gdb \
  git \
  openssh-client \
  python3-argcomplete \
  python3-pip \
  ros-dev-tools \
  ros-humble-ament-* \
  vim \
  && rm -rf /var/lib/apt/lists/*

RUN rosdep init || echo "rosdep already initialized"

ARG USERNAME=ros
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Supprime l'user "ubuntu" s'il existe, puis crée l'user "ros"
RUN if getent passwd ubuntu > /dev/null 2>&1; then \
        userdel -r ubuntu && \
        echo "Deleted existing ubuntu user"; \
    fi && \
    groupadd --gid $USER_GID $USERNAME && \
    useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME && \
    echo "Created new user $USERNAME"

# Sudo sans mot de passe
RUN apt-get update && apt-get install -y sudo \
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
  && chmod 0440 /etc/sudoers.d/$USERNAME \
  && rm -rf /var/lib/apt/lists/*

# Autocomplétion et sourcing ROS dans .bashrc
RUN apt-get update && apt-get install -y --no-install-recommends git-core bash-completion \
  && echo "if [ -f /opt/ros/${ROS_DISTRO}/setup.bash ]; then source /opt/ros/${ROS_DISTRO}/setup.bash; fi" >> /home/$USERNAME/.bashrc \
  && echo "if [ -f /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash ]; then source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash; fi" >> /home/$USERNAME/.bashrc \
  && rm -rf /var/lib/apt/lists/*

ENV DEBIAN_FRONTEND=
ENV AMENT_CPPCHECK_ALLOW_SLOW_VERSIONS=1

###########################################
#  Full image
###########################################
FROM dev AS full

ENV DEBIAN_FRONTEND=noninteractive

# ROS desktop complet
RUN apt-get update && apt-get install -y --no-install-recommends \
  ros-humble-desktop \
  && rm -rf /var/lib/apt/lists/*

ENV LD_LIBRARY_PATH=/opt/ros/humble/opt/rviz_ogre_vendor/lib:/opt/ros/humble/lib/x86_64-linux-gnu:/opt/ros/humble/lib

###########################################
#  Full + Gazebo Classic 11
###########################################

RUN add-apt-repository ppa:openrobotics/gazebo11-gz-cli && \
    apt-get update && apt-get install -y --no-install-recommends \
      gazebo11 \
      libgazebo11-dev \
    && rm -rf /var/lib/apt/lists/*

# CMAKE_PREFIX_PATH sans variable indéfinie
ENV CMAKE_PREFIX_PATH=/usr/share/gazebo-11/cmake

# Packages ROS supplémentaires
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-humble-navigation2 \
    ros-humble-nav2-bringup \
    ros-humble-slam-toolbox \
    ros-humble-ros2-control \
    ros-humble-ros2-controllers \
    ros-humble-robot-localization \
    ros-humble-moveit \
    ros-humble-topic-based-ros2-control \
    ros-humble-tf2-geometry-msgs \
    ros-humble-nav-msgs \
    ros-humble-std-srvs \
    ros-humble-joint-state-publisher \
    ros-humble-joint-state-publisher-gui \
    ros-humble-xacro \
    ros-humble-camera-info-manager \
    ros-humble-imu-tools \
    && rm -rf /var/lib/apt/lists/*

# Mise à jour rosdep
RUN rosdep update

# Clonage des packages Gazebo
WORKDIR /home/ros/ros2_ws/src/gazebo
RUN git clone -b ros2 https://github.com/ros-simulation/gazebo_ros_pkgs.git && \
    git clone -b humble https://github.com/ros-controls/gazebo_ros2_control.git

# Clonage micro-ROS
WORKDIR /home/ros/ros2_ws/src/uros
RUN git clone -b humble https://github.com/micro-ROS/micro-ROS-Agent.git && \
    git clone -b humble https://github.com/micro-ROS/micro_ros_msgs.git

# Compilation — 1 package à la fois, 4 threads max par package
WORKDIR /home/ros/ros2_ws
RUN . /opt/ros/humble/setup.sh && \
    MAKEFLAGS="-j4" colcon build \
        --symlink-install \
        --executor sequential \
        --parallel-workers 1 \
        --cmake-args -DCMAKE_BUILD_TYPE=Release

# Permissions
RUN chown -R ros:ros /home/ros/ros2_ws && \
    usermod -aG dialout ros

# Sourcing du workspace et Gazebo dans .bashrc
RUN echo "if [ -f /home/ros/ros2_ws/install/setup.bash ]; then source /home/ros/ros2_ws/install/setup.bash; fi" >> /home/ros/.bashrc && \
    echo "if [ -f /usr/share/gazebo/setup.sh ]; then source /usr/share/gazebo/setup.sh; fi" >> /home/ros/.bashrc && \
    echo 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' >> /home/ros/.bashrc

# Copie et permissions du script de setup
COPY .devcontainer/setup.sh /home/ros/setup.sh
RUN chmod +x /home/ros/setup.sh && \
    chown ros:ros /home/ros/setup.sh

ENV DEBIAN_FRONTEND=

# Démarrer en tant qu'utilisateur ros
USER ros
CMD ["bash"]
