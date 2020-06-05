# Copyright (c) 2018, ARM Limited.
# SPDX-License-Identifier: Apache-2.0

FROM ubuntu:bionic

## Create user for building buildroot
RUN useradd -m -s /bin/bash developer
WORKDIR /home/developer

## Set timezone
RUN echo 'Etc/UTC' > /etc/timezone && \
    ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    apt-get update && apt-get install -q -y tzdata && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y lsb-core vim tree

## ROS
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' && \
    apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

## Install development tools
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git git-core \
    wget \
    curl \
    g++ make gawk libncurses5-dev wget python unzip bc cpio rsync \
    bash-completion \
    python-rosdep python-rosinstall-generator python-wstool python-rosinstall \
    python-pip

RUN pip install empy

RUN rosdep init && rosdep update
RUN mkdir -p ros_pi/ros_catkin_ws && cd ros_pi/ros_catkin_ws && \
    rosinstall_generator ros_comm --rosdistro melodic --deps --tar > melodic-ros_comm.rosinstall && \
    wstool init -j8 src melodic-ros_comm.rosinstall
COPY ros_melodic_pi.patch /home/developer/ros_pi
WORKDIR /home/developer/ros_pi/ros_catkin_ws/
RUN patch -p1 < ../ros_melodic_pi.patch

## Build buildroot
USER developer:developer
WORKDIR /home/developer
COPY buildroot-2020.02.1.tar.gz ./
RUN tar zxvf buildroot-2020.02.1.tar.gz
WORKDIR buildroot-2020.02.1

COPY rpi3-aarch64-buildroot-config .config
RUN make toolchain
ENV PATH=/home/developer/buildroot-2020.02.1/output/host/bin/:$PATH

## LIBS for building ROS
#
#  console_bridge
#
USER root
WORKDIR /home/developer/cb_ws
RUN git clone https://github.com/ros/console_bridge
RUN mkdir build && cd build
RUN cmake -DCMAKE_INSTALL_PREFIX=../install ../console_bridge
RUN make && make install && \
    cp -a /home/developer/cb_ws/install/include/* /home/developer/buildroot-2020.02.1/output/host/aarch64-buildroot-linux-gnu/sysroot/usr/include/ && \
    cp -a /home/developer/cb_ws/install/lib/* /home/developer/buildroot-2020.02.1/output/host/aarch64-buildroot-linux-gnu/sysroot/usr/lib/
#
#  poco
#
WORKDIR /home/developer/poco_ws
RUN git clone -b master https://github.com/pocoproject/poco.git
RUN cd poco && ./configure --prefix=/home/developer/poco_ws/install
RUN make && make install && \
    cp -a /home/developer/poco_ws/install/include/* /home/developer/buildroot-2020.02.1/output/host/aarch64-buildroot-linux-gnu/sysroot/usr/include/ && \
    cp -a /home/developer/poco_ws/install/lib/* /home/developer/buildroot-2020.02.1/output/host/aarch64-buildroot-linux-gnu/sysroot/usr/lib/ && \
    cp -a /home/developer/poco_ws/install/bin/* /home/developer/buildroot-2020.02.1/output/host/aarch64-buildroot-linux-gnu/sysroot/usr/bin
#
#  boost
#
WORKDIR /home/developer/boost_ws
RUN wget https://dl.bintray.com/boostorg/release/1.65.1/source/boost_1_65_1.tar.bz2 && \
    tar --bzip2 -xf boost_1_65_1.tar.bz2
RUN cd boost_1_65_1 && ./bootstrap.sh --prefix=../install
RUN sed -i '12s/using gcc/using gcc : arm : aarch64-linux-gcc/g' project-config.jam
RUN ./b2 install
RUN cp -a /usr/local/lib/libboost_* /home/developer/buildroot-2020.02.1/output/host/aarch64-buildroot-linux-gnu/sysroot/usr/lib/ && \
    cp -a /usr/local/include/boost /home/developer/buildroot-2020.02.1/output/host/aarch64-buildroot-linux-gnu/sysroot/usr/include/


## Build ROS
COPY ros_melodic_toolchain_cmake.cmake /home/developer/ros_pi/toolchain.cmake
WORKDIR /home/developer/ros_pi/ros_catkin_ws/
RUN ./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_TOOLCHAIN_FILE=/home/developer/ros_pi/toolchain.cmake

