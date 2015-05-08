IMAGE_NAME="CentOS-7-server-x86_64"
CLOUD_INIT_DEFAULT_USER_NAME="centos"
ELEMENTS="vm cloud-init-cfg centos7"
PACKAGES="vim,ntp,deltarpm"

export CLOUD_INIT_DEFAULT_USER_NAME

. image_create.sh
