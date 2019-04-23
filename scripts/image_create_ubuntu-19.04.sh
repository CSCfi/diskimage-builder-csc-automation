#!/bin/bash --login
UBUNTU_URL="http://cloud-images.ubuntu.com/disco/current/"
DOWNLOAD_URL="$UBUNTU_URL/disco-server-cloudimg-amd64.img"
IMAGE_NAME="Ubuntu-19.04"
OS_DISTRO_PROPERTY="ubuntu"
IMAGE_VISIBILITY="public"

source $(dirname $0)/image_dl_test_deploy.sh "$DOWNLOAD_URL"
