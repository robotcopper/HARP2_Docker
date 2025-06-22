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

# Check if "ubuntu" user exists, delete it if it does, then create the desired user
RUN if getent passwd ubuntu > /dev/null 2>&1; then \
        userdel -r ubuntu && \
        echo "Deleted existing ubuntu user"; \
    fi && \
    groupadd --gid $USER_GID $USERNAME && \
    useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME && \
    echo "Created new user $USERNAME"

# Add sudo support for the non-root user
RUN apt-get update && apt-get install -y sudo \
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
  && chmod 0440 /etc/sudoers.d/$USERNAME \
  && rm -rf /var/lib/apt/lists/*

# Set up autocompletion for user
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
# Install the full release
RUN apt-get update && apt-get install -y --no-install-recommends \
  ros-humble-desktop \
  && rm -rf /var/lib/apt/lists/*
ENV DEBIAN_FRONTEND=
ENV LD_LIBRARY_PATH=/opt/ros/humble/opt/rviz_ogre_vendor/lib:/opt/ros/humble/lib/x86_64-linux-gnu:/opt/ros/humble/lib

###########################################
#  Full+Gazebo Classic image
###########################################
FROM full AS gazebo

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
        sudo \
        lsb-release \
        software-properties-common

# Installer les dépendances de DART
RUN apt-get update && apt-get install -y --no-install-recommends \
    cmake \
    build-essential \
    libassimp-dev \
    libccd-dev \
    libfcl-dev \
    libbullet-dev \
    libboost-all-dev \
    libeigen3-dev \
    libtinyxml2-dev

WORKDIR /opt
RUN git clone --branch release-6.13 https://github.com/dartsim/dart.git

WORKDIR /opt/dart
RUN mkdir build && cd build && \
    cmake .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_SHARED_LIBS=ON \
      -DDART_BUILD_GUI_OSG=OFF \
      -DDART_BUILD_DARTPY=OFF && \
    make -j$(nproc) && make install

RUN rm -rf /opt/dart

# 1. Install dependencies for Gazebo Classic from source
RUN apt-get update && apt-get install -y --no-install-recommends \
    cmake \
    build-essential \
    libprotobuf-dev \
    libprotoc-dev \
    protobuf-compiler \
    libqt5core5a \
    libqt5gui5 \
    libqt5widgets5 \
    qtbase5-dev \
    libqwt-qt5-dev \
    libtinyxml2-dev \
    libgts-dev \
    libboost-all-dev \
    libeigen3-dev \
    libfreeimage-dev \
    libogre-1.9-dev \
    libtbb-dev \
    libyaml-cpp-dev \
    libsdformat9-dev \
    libignition-math6-dev \
    libignition-common-dev \
    libignition-fuel-tools-dev \
    libopenal-dev \
    libsimbody-dev \
    libtar-dev \
    libsdformat9-9 \
    doxygen \
    libignition-msgs5-dev \
    libignition-transport8-dev \
    libignition-common3-dev \
    libignition-fuel-tools4-dev \
    git \
    wget \
    curl \
    ruby \
    && rm -rf /var/lib/apt/lists/*
    
# Télécharger et installer sdformat 9.8.0
RUN cd /tmp && \
    wget http://osrf-distributions.s3.amazonaws.com/sdformat/releases/sdformat-9.8.0.tar.bz2 && \
    tar -xjf sdformat-9.8.0.tar.bz2 && \
    cd sdformat-9.8.0 && \
    mkdir build && cd build && \
    cmake .. && \
    make -j$(nproc) && \
    make install && \
    ldconfig
    
# 2. Build and install Gazebo Classic 11
RUN cd /opt && \
    git clone https://github.com/osrf/gazebo.git -b gazebo11 && \
    cd gazebo && \
    mkdir build && cd build && \
    cmake .. 

RUN cd /opt/gazebo/build && \
    make -j7
    
RUN cd /opt/gazebo/build && \
    make install VERBOSE=1


# 1. Install dependencies and ROS keys
RUN apt update && apt install -y curl gnupg2 lsb-release && \
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | apt-key add - && \
    echo "deb http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2.list && \
    apt update && \
    rosdep update

# 2. Create workspace and clone packages
USER ros

WORKDIR /home/ros/ros2_ws/src/gazebo
RUN git clone -b ros2 https://github.com/ros-simulation/gazebo_ros_pkgs.git && \
    git clone -b humble https://github.com/ros-controls/gazebo_ros2_control.git

WORKDIR /home/ros/ros2_ws/src/uros
RUN git clone -b humble https://github.com/micro-ROS/micro-ROS-Agent.git && \
    git clone -b humble https://github.com/micro-ROS/micro_ros_msgs.git

# 3. Install ros packages
USER root
RUN apt update && apt install -y --no-install-recommends \
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
  && rm -rf /var/lib/apt/lists/*

# Copier le script
COPY .devcontainer/setup.sh /home/ros/setup.sh
RUN chmod +x /home/ros/setup.sh

# L'exécuter une seule fois
RUN bash /home/ros/setup.sh && rm /home/ros/setup.sh

ENV DEBIAN_FRONTEND=
