#!/bin/bash --login
IMAGE_NAME="ScientificLinux-7"
CLOUD_INIT_DEFAULT_USER_NAME="cloud-user"
ELEMENTS="vm cloud-init-cfg scientific7"
PACKAGES="vim,ntp,deltarpm"

export CLOUD_INIT_DEFAULT_USER_NAME

export DIB_LOCAL_IMAGE=""

source $(dirname $0)/image_create.sh
