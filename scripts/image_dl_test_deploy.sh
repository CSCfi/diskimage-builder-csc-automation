#!/bin/bash
# Download cloud image, push it to glance and create test instance

source $(dirname $0)/image_cpouta_constants.sh
source $(dirname $0)/image_functions.sh

set -eu
trap cleanup ERR EXIT

image_download "$1"
image_test
image_deploy
delete_old_image_versions
