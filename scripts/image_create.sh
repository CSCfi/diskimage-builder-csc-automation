#!/bin/bash -lv
# Create cloud image, push it to OpenStack and create test instance

echo "=== "$(date)

if [[ $(dirname $0) =~ scripts.cpouta/scripts$ ]] ; then
    source $(dirname $0)/image_cpouta_constants.sh
else
    source $(dirname $0)/image_epouta_constants.sh
fi

source $(dirname $0)/image_functions.sh

set -eu
trap cleanup ERR EXIT

echo $CLOUD_INIT_DEFAULT_USER_NAME
image_create
image_test
image_deploy
delete_old_image_versions
