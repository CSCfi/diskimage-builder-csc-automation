#!/bin/bash
REL_VERSION=$(curl -Ls https://download.fedoraproject.org/pub/alt/atomic/stable/ |grep -Eo 'Fedora-Atomic-25-[0-9\.]*'|sort -r|head -1)
TMP_IMAGE_NAME="$REL_VERSION"
IMAGE_NAME="$REL_VERSION.x86_64"
IMAGE_FORMAT="qcow2"
DOWNLOAD_URL="https://download.fedoraproject.org/pub/alt/atomic/stable/$REL_VERSION/CloudImages/x86_64/images/$IMAGE_NAME.$IMAGE_FORMAT"

source $(dirname $0)/image_dl_test_deploy.sh "$DOWNLOAD_URL"
