#!/bin/bash
DIB_RELEASE="vivid"
IMAGE_NAME="Ubuntu-15.04"
CLOUD_INIT_DEFAULT_USER_NAME="cloud-user"
ELEMENTS="vm cloud-init-cfg ubuntu"
PACKAGES="vim,ntp"

export DIB_RELEASE
export CLOUD_INIT_DEFAULT_USER_NAME

source $(dirname $0)/image_create.sh
