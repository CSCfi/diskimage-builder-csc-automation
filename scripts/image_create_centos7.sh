#!/bin/bash
IMAGE_NAME="CentOS-7.0"
CLOUD_INIT_DEFAULT_USER_NAME="cloud-user"
ELEMENTS="vm cloud-init-cfg centos7"
PACKAGES="vim,ntp,deltarpm"

export CLOUD_INIT_DEFAULT_USER_NAME

source $(dirname $0)/image_create.sh
