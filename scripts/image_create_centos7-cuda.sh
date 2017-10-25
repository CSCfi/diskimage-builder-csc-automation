#!/bin/bash -lv
DISTRO_NAME="centos7"
IMAGE_NAME="CentOS-7-Cuda"
CLOUD_INIT_DEFAULT_USER_NAME="cloud-user"
ELEMENTS="vm cloud-init-cfg centos7 nvidia-cuda"
PACKAGES="vim,ntp,deltarpm,cuda"
IMAGE_VISIBILITY="public"
CLOUD_INIT_CRON_UPDATES_FILE="/tmp/.nope"

export CLOUD_INIT_DEFAULT_USER_NAME
export CLOUD_INIT_CRON_UPDATES_FILE

source $(dirname $0)/image_create.sh

