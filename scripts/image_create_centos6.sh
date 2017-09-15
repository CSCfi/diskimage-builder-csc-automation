#!/bin/bash --login
IMAGE_NAME="CentOS-6"
CLOUD_INIT_DEFAULT_USER_NAME="cloud-user"
ELEMENTS="vm cloud-init-cfg centos"
PACKAGES="vim,ntp,deltarpm"
IMAGE_VISIBILITY="public"

export CLOUD_INIT_DEFAULT_USER_NAME

source $(dirname $0)/image_create.sh
