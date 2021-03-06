#!/bin/bash
set -e

# parse command line arguments

shared=false
cuda=false

for key in "$@"; do
    case $key in
        --shared)
        shared=true
        ;;
        --cuda)
        cuda=true
        ;;
    esac
done

# install requirements
pacman -Syu --noconfirm --needed \
  base-devel \
  pacman-contrib \
  cmake \
  git \
  unzip \
  mlocate \
  python \
  python-numpy \
  wget

if $shared; then
    pacman -S --noconfirm --needed \
      gcc7 \
      java-environment=8 \
      libarchive \
      protobuf \
      unzip \
      zip
    export BAZEL_VERSION=${BAZEL_VERSION:-`cat ./tensorflow_cc/Dockerfiles/BAZEL_VERSION`}
    bazel_installer=bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh
    wget -P /tmp https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/${bazel_installer}
    chmod +x /tmp/${bazel_installer}
    /tmp/${bazel_installer}
    rm /tmp/${bazel_installer}
fi
if $cuda; then
    pacman -S --noconfirm --needed \
      cuda \
      cudnn
fi

paccache -rfk0

# when building TF with Intel MKL support, `locate` database needs to exist
updatedb

# build and install tensorflow_cc
./tensorflow_cc/Dockerfiles/install-common.sh "$@"
