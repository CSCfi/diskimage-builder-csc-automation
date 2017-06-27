#!/bin/bash --login
DIB_RELEASE="stretch"
IMAGE_NAME="Debian-stretch-server-amd64"
CLOUD_INIT_DEFAULT_USER_NAME="cloud-user"
ELEMENTS="vm cloud-init-cfg debian"
PACKAGES="vim,ntp,software-properties-common,debian-keyring,apt-utils"

export DIB_RELEASE
export CLOUD_INIT_DEFAULT_USER_NAME

source $(dirname $0)/image_create.sh