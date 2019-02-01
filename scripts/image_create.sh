#!/bin/bash -lv
# Create cloud image, push it to OpenStack and create test instance

echo "=== "$(date):u

# Expiting the file location to be:
# /SOME/PATH/diskimage-builder-scripts.${openstack_environment}/image_${openstack_environment}_constants.sh
openstack_environment="$( echo $(dirname $0) | sed 's/^.*diskimage-builder-scripts\.//g' |cut -d '/' -f 1)"
echo $openstack_environment
source_file="$(dirname $0)/image_${openstack_environment}_constants.sh"
if [ -f $source_file ]; then
  echo "Using source file: ${source_file}"
  source $source_file
else
  echo $source_file does not exist
  exit 34
fi

source $(dirname $0)/image_functions.sh

set -eu
trap cleanup ERR EXIT

echo $CLOUD_INIT_DEFAULT_USER_NAME
image_create
image_test
image_deploy
delete_old_image_versions
