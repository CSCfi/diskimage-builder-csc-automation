#!/bin/bash --login
DISTRO_URL="https://cloud.centos.org/centos/8-stream/x86_64/images"
DOWNLOAD_URL="$DISTRO_URL/CentOS-Stream-GenericCloud-8-latest.x86_64.qcow2"
IMAGE_NAME="CentOS-8-Stream"
OS_DISTRO_PROPERTY="centos"
IMAGE_VISIBILITY="public"

source $(dirname $0)/image_dl_test_deploy.sh "$DOWNLOAD_URL"
