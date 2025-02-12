################################################################################
# Download O3DE debian package
################################################################################
FROM alpine AS o3de_deb

ARG O3DE_MAJOR_VERSION
ARG O3DE_MINOR_VERSION
ARG O3DE_PATCH_VERSION

ENV O3DE_DEB=o3de_${O3DE_MAJOR_VERSION}${O3DE_MINOR_VERSION}_${O3DE_PATCH_VERSION}.deb
ADD https://o3debinaries.org/main/Latest/Linux/$O3DE_DEB /tmp/$O3DE_DEB

################################################################################
# Get o3de-extras repository
################################################################################
FROM alpine AS o3de_extras

ARG O3DE_MAJOR_VERSION
ARG O3DE_MINOR_VERSION
ARG O3DE_PATCH_VERSION

RUN apk add \
    git \
    git-lfs

ENV O3DE_EXTRAS_TAG=${O3DE_MAJOR_VERSION}${O3DE_MINOR_VERSION}.${O3DE_PATCH_VERSION}
RUN git clone --single-branch --no-tags -b ${O3DE_EXTRAS_TAG} https://github.com/o3de/o3de-extras.git /opt/o3de-extras &&\
    git -C /opt/o3de-extras lfs install && \
    git -C /opt/o3de-extras lfs pull && \
    chmod -R a+w /opt/o3de-extras
################################################################################
# Base image
################################################################################
FROM amd64/ros:humble AS dev

ARG O3DE_MAJOR_VERSION
ARG O3DE_MINOR_VERSION
ARG O3DE_PATCH_VERSION

ENV O3DE_VERSION=${O3DE_MAJOR_VERSION}.${O3DE_MINOR_VERSION}.${O3DE_PATCH_VERSION}

# Install extra dependencies required by O3DE
# See: https://www.docs.o3de.org/docs/welcome-guide/requirements/#linux
RUN apt-get update && apt-get install --no-install-recommends -y \
    cmake \
    clang \
    ninja-build \
    libevdev-dev \
    libfontconfig1-dev \
    libglu1-mesa-dev \
    libpcre2-16-0 \
    libstdc++-12-dev \
    libunwind-dev \
    libvulkan1 \
    libxcb-icccm4-dev \
    libxcb-image0-dev \
    libxcb-keysyms1-dev \
    libxcb-render-util0-dev \
    libxcb-xfixes0-dev \
    libxcb-xinerama0 \
    libxcb-xinput0 \
    libxcb-xinput-dev \
    libxcb-xkb-dev \
    libxkbcommon-dev \
    libxkbcommon-x11-dev \
    mesa-common-dev \
    zlib1g-dev \
    libzstd-dev \
    tix

################################################################################
# Install O3DE Engine
################################################################################
ENV O3DE_DEB=o3de_${O3DE_MAJOR_VERSION}${O3DE_MINOR_VERSION}_${O3DE_PATCH_VERSION}.deb
COPY --link --from=o3de_deb /tmp/${O3DE_DEB} /tmp/${O3DE_DEB}

RUN apt-get install -y /tmp/${O3DE_DEB} && \
    chmod -R a+w /opt/O3DE/${O3DE_VERSION} && \
    rm /tmp/${O3DE_DEB}

################################################################################
# Install extra ROS packages
################################################################################

# Required for rviz2
# RUN apt-get install -y libogre-1.12-dev

RUN apt-get install --no-install-recommends -y \
    ros-humble-ackermann-msgs \
    ros-humble-control-toolbox \
    ros-humble-gazebo-msgs \
    ros-humble-nav-msgs \
    # ros-humble-rivz2 \
    ros-humble-teleop-twist-keyboard \
    ros-humble-xacro

################################################################################
# Create dev user
################################################################################
ARG USERNAME
ARG USERID
ARG GROUPID
ARG BASHRC_APPEND

RUN groupadd --gid $GROUPID $USERNAME && \
    useradd --uid $USERID --gid $GROUPID -s "/bin/bash" --create-home $USERNAME && \
    apt-get install -y sudo && \
    echo "${USERNAME} ALL=NOPASSWD: ALL" > /etc/sudoers.d/${USERNAME} && \
    chmod 0440 /etc/sudoers.d/${USERNAME}

RUN echo "export PS1='\[\033[01;36m\](docker)\[\033[00m\] \[\033[01;32m\]\u@${NAME}\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '" >> /home/${USERNAME}/.bashrc && \
    echo "alias ll='ls --color=auto -alFNh'" >> /home/${USERNAME}/.bashrc && \
    echo "alias ls='ls --color=auto -Nh'" >> /home/${USERNAME}/.bashrc

# Check if the directory /opt/ros/ exists, and if it does, append the command to .bashrc
RUN if [ -d /opt/ros/ ]; then \
    echo "source /opt/ros/$(ls /opt/ros/)/setup.bash" >> /home/${USERNAME}/.bashrc; \
    fi

# Check if /usr/share/colcon_argcomplete/ is installed, and if it does, append the arg complete command to .bashrc
RUN if [ -d /usr/share/colcon_argcomplete/ ]; then \
    echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> /home/${USERNAME}/.bashrc; \
    fi

# If BASHRC_APPEND is set, append it to .bashrc
RUN if [ -n "${BASHRC_APPEND}" ]; then \
    echo "${BASHRC_APPEND}" >> /home/${USERNAME}/.bashrc; \
    fi


################################################################################
# Copy o3de-extras
################################################################################
COPY --from=o3de_extras /opt/o3de-extras /opt/o3de-extras

################################################################################
# Register engine and gems
################################################################################
USER ${USERNAME}
WORKDIR /opt/O3DE/${O3DE_VERSION}
ENV O3DE_ROOT=/opt/O3DE/${O3DE_VERSION}

RUN python/get_python.sh
RUN scripts/o3de.sh register --this-engine && \
    scripts/o3de.sh register --all-gems-path /opt/o3de-extras/Gems && \
    scripts/o3de.sh register --all-templates-path /opt/o3de-extras/Templates && \
    scripts/o3de.sh register --all-projects-path /opt/o3de-extras/Projects

WORKDIR /home/${USERNAME}

# NVIDIA Container Toolkit
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all

# ROS2
ENV ROS_LOCALHOST_ONLY=1
ENV ROS_DOMAIN_ID=42

CMD ["/bin/bash"]
