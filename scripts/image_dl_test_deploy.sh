#!/bin/bash
# Download cloud image, push it to glance and create test instance

source $(dirname $0)/image_constants.sh
source $(dirname $0)/image_functions.sh
#HACK for k8s. Fix before adding more download+upload style images.
OS_DISTRO_PROPERTY="fedora-atomic"
IMAGE_NAME="Fedora-Atomic-25"

set -eu
trap cleanup ERR EXIT

image_download "$1"
image_test
image_deploy
delete_old_image_versions
#FIXME delete_old_image_versions doesn't catch .qcow2?
