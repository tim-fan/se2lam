FROM ros:melodic-ros-base-bionic

# USE BASH
SHELL ["/bin/bash", "-c"]

# RUN LINE BELOW TO REMOVE debconf ERRORS (MUST RUN BEFORE ANY apt-get CALLS)
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    apt-utils \
    wget \
    python-catkin-tools

# libg2o install
RUN apt-get install -y libeigen3-dev libsuitesparse-dev
RUN wget https://github.com/RainerKuemmerle/g2o/archive/20160424_git.tar.gz && \
    tar xvf 20160424_git.tar.gz
RUN mkdir -p g2o-20160424_git/build \
    && cd g2o-20160424_git/build \
    && cmake .. \
    && make \
    && make install

# clone this repo into catkin ws and install deps
RUN mkdir -p catkin_ws/src
RUN cd catkin_ws/src && git clone https://github.com/tim-fan/se2lam.git
RUN source /opt/ros/melodic/setup.bash \
    && cd catkin_ws \
    && rosdep update \
    && rosdep install -y -r --from-paths src --ignore-src --rosdistro=melodic -y

# build/install
RUN source /opt/ros/melodic/setup.bash \ 
    && cd catkin_ws/src \
    && catkin_init_workspace \
    && cd .. \
    && catkin config --install -i /opt/ros/melodic/ \
    && catkin build -DCMAKE_BUILD_TYPE=Release

COPY  ./ORBvoc.bin /
COPY ./DatasetRoom /DatasetRoom
RUN mv /DatasetRoom/odo_raw_accu.txt /DatasetRoom/odo_raw.txt