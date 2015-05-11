#!/bin/bash --login
# Create cloud image, push it to OpenStack and create test instance

. image_constants.sh
. image_functions.sh

set -eu
trap cleanup ERR EXIT

echo $CLOUD_INIT_DEFAULT_USER_NAME
image_create
image_test
image_deploy
delete_old_image_versions
