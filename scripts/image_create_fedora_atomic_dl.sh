#!/bin/bash --login
ATOMIC_URL="https://download.fedoraproject.org/pub/alt/atomic/stable"
REL_VERSION=$(curl -Ls $ATOMIC_URL |grep -Eo 'Fedora-Atomic-25-[0-9\.]*'|sort -r|head -1)
DOWNLOAD_URL="$ATOMIC_URL/$REL_VERSION/CloudImages/x86_64/images/$REL_VERSION.x86_64.qcow2"
IMAGE_NAME="Fedora-Atomic-25"
OS_DISTRO_PROPERTY="fedora-atomic"

source $(dirname $0)/image_dl_test_deploy.sh "$DOWNLOAD_URL"

