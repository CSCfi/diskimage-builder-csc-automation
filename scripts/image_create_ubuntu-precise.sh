DIB_RELEASE="precise"
IMAGE_NAME="Ubuntu-precise-server-amd64"
CLOUD_INIT_DEFAULT_USER_NAME="ubuntu"
ELEMENTS="vm cloud-init-cfg ubuntu"
PACKAGES="vim,ntp"

export DIB_RELEASE
export CLOUD_INIT_DEFAULT_USER_NAME

. image_create.sh
