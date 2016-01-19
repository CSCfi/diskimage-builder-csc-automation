IMAGE_NAME="ScientificLinux-6.6"
CLOUD_INIT_DEFAULT_USER_NAME="cloud-user"
ELEMENTS="vm cloud-init-cfg scientific6"
PACKAGES="vim,ntp,deltarpm"

export CLOUD_INIT_DEFAULT_USER_NAME

export DIB_LOCAL_IMAGE=""

. image_create.sh

