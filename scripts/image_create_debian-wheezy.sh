DIB_RELEASE="wheezy"
IMAGE_NAME="Debian-wheezy-server-amd64"
CLOUD_INIT_DEFAULT_USER_NAME="debian"
ELEMENTS="vm cloud-init-cfg debian"
PACKAGES="vim,ntp"

export DIB_RELEASE
export CLOUD_INIT_DEFAULT_USER_NAME

. image_create.sh
