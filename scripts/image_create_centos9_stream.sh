#!/bin/bash --login
DISTRO_URL="https://cloud.centos.org/centos/9-stream/x86_64/images/"
DISTRO_NAME=$(curl -s "$DISTRO_URL?C=M;O=D" | grep -oE "*CentOS-Stream-GenericCloud-9-[0-9]{8}.[0-9]{1}.x86_64.qcow2*" | head -n 1)
DOWNLOAD_URL="$DISTRO_URL$DISTRO_NAME"
IMAGE_NAME="CentOS-9-Stream"
OS_DISTRO_PROPERTY="centos"
IMAGE_VISIBILITY="public"

source $(dirname $0)/image_dl_test_deploy.sh "$DOWNLOAD_URL"
