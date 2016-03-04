#!/bin/bash
# Create cloud image, push it to OpenStack and create test instance

source $(dirname $0)/image_constants.sh
source $(dirname $0)/image_functions.sh

set -eu
trap cleanup ERR EXIT

echo $CLOUD_INIT_DEFAULT_USER_NAME
image_create
image_test
image_deploy
delete_old_image_versions
