#!/bin/bash --login
DISTRO_URL="https://repo.almalinux.org/almalinux/9/cloud/x86_64/images"
DOWNLOAD_URL="$DISTRO_URL/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2"
IMAGE_NAME="AlmaLinux-9"
OS_DISTRO_PROPERTY="almalinux"
IMAGE_VISIBILITY="public"

source $(dirname $0)/image_dl_test_deploy.sh "$DOWNLOAD_URL"
