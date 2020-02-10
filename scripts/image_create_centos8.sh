#!/bin/bash --login
DISTRO_URL="https://cloud.centos.org/centos/8/x86_64/images/"
DOWNLOAD_URL="$DISTRO_URL/CentOS-8-GenericCloud-8.1.1911-20200113.3.x86_64.qcow2"
IMAGE_NAME="CentOS-8"
OS_DISTRO_PROPERTY="centos"
IMAGE_VISIBILITY="public"

source $(dirname $0)/image_dl_test_deploy.sh "$DOWNLOAD_URL"
