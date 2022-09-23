#!/bin/bash
# Download cloud image, push it to glance and create test instance

echo "=== "$(date)

# Expecting the file location to be:
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

set -Eeu
trap cleanup EXIT
trap err_handler ERR

image_download "$1"
image_test
image_deploy
delete_old_image_versions
