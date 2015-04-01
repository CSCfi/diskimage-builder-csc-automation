#!/bin/bash --login
# Create cloud image, push it to OpenStack and create test instance
DIB_LOCAL_IMAGE=""
DIB_OPTIONS="--no-tmpfs --qemu-img-options compat=0.10"
IMAGE_NAME="CentOS-6.6"
IMAGE_SIZE="10"
IMAGE_FORMAT="qcow2"
IMAGE_IS_PUBLIC="True"
IMAGE_KEEP_COUNT="5"
TMP_IMAGE_NAME="_tmp_$IMAGE_NAME"
TEST_INSTANCE_NAME="_test_$IMAGE_NAME"
TEST_FLAVOR="tiny"
TEST_NET_ID="63b53b45-3e3f-454c-8a27-d1bfae422c11"
TEST_FIP="192.168.99.99"
TEST_PING_COUNT="5"
TEST_PING_INTERVAL="5"
ELEMENTS="vm cloud-init-cfg centos6"
PACKAGES="vim,ntp"

#export DIB_LOCAL_IMAGE

function cleanup() {
	rm -rf ${IMAGE_NAME}.*
	# delete any orphaned temporary images
	for id in $(glance image-list | grep "$TMP_IMAGE_NAME" | awk '{print $2}')
	do
		glance image-delete $id &>/dev/null || true
	done
	# delete any orphaned test instance
	for id in $(nova list | grep "$TEST_INSTANCE_NAME" | awk '{print $2}')
	do
		nova delete $id &>/dev/null || true
	done
}

function image_create() {
	# create cloud image with diskimage-builder
	disk-image-create $DIB_OPTIONS -o "$IMAGE_NAME" \
	--image-size $IMAGE_SIZE -p $PACKAGES $ELEMENTS
}

function image_test() {
	echo "Creating test image $TMP_IMAGE_NAME"
	# create new temporary image
	glance image-create --name "$TMP_IMAGE_NAME" --container-format bare \
	--disk-format $IMAGE_FORMAT --is-public False --progress \
	--file "${IMAGE_NAME}.${IMAGE_FORMAT}"
	echo "Creating test instance $TEST_INSTANCE_NAME"
	# create new test instance
	nova boot --flavor $TEST_FLAVOR --image "$TMP_IMAGE_NAME" \
	--nic net-id=$TEST_NET_ID --poll "$TEST_INSTANCE_NAME"
	echo "Assigning floating IP $TEST_FIP to $TEST_INSTANCE_NAME"
	# assign floating IP to test instance
	nova floating-ip-associate "$TEST_INSTANCE_NAME" $TEST_FIP
	ping -qA -c$TEST_PING_COUNT -i$TEST_PING_INTERVAL $TEST_FIP
}

function image_deploy() {
	# set older versions non-public
	images=($(glance image-list --owner "$OS_TENANT_ID" --name "$IMAGE_NAME" \
	| grep "$IMAGE_NAME" | awk -F'|' '{print $2}'))
	images=${images:-}

	for image in ${images[@]}; do
		echo "Setting non-public: $image"
			glance image-update --is-public False "$image"
	done

	# rename new image
	glance image-update --name "$IMAGE_NAME" \
	--property description="All packages of this image where updated on $(date +%F)" \
	--is-public $IMAGE_IS_PUBLIC "$TMP_IMAGE_NAME"
}

function delete_old_image_versions() {
	images=($(glance image-list --sort-key created_at --sort-dir desc \
	--owner "$OS_TENANT_ID" --name "$IMAGE_NAME" | grep "$IMAGE_NAME" \
	| awk -F'|' '{print $2}'))
	images=${images:-}

	for delete in ${images[@]:$IMAGE_KEEP_COUNT}; do
		echo "Deleting image: $delete"
		glance image-delete $delete
	done
}

set -eu
trap cleanup ERR EXIT

image_create
image_test
image_deploy
delete_old_image_versions

