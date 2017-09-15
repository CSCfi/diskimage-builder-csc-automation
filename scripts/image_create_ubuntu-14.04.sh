#!/bin/bash --login
DIB_RELEASE="trusty"
IMAGE_NAME="Ubuntu-14.04"
CLOUD_INIT_DEFAULT_USER_NAME="cloud-user"
ELEMENTS="vm cloud-init-cfg ubuntu"
PACKAGES="vim,ntp"
IMAGE_VISIBILITY="public"

export DIB_RELEASE
export CLOUD_INIT_DEFAULT_USER_NAME

source $(dirname $0)/image_create.sh
