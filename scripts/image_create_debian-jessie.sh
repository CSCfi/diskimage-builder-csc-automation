#!/bin/bash
DIB_RELEASE="jessie"
IMAGE_NAME="Debian-jessie-server-amd64"
CLOUD_INIT_DEFAULT_USER_NAME="cloud-user"
ELEMENTS="vm cloud-init-cfg debian"
PACKAGES="vim,ntp"

export DIB_RELEASE
export CLOUD_INIT_DEFAULT_USER_NAME

source $(dirname $0)/image_create.sh
