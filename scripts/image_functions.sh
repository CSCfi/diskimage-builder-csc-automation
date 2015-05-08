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
	TMP_DIR=~/temp disk-image-create $DIB_OPTIONS -o "$IMAGE_NAME" \
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
	--nic net-id=$TEST_NET_ID --security-groups=$SECURITY_GROUPS --poll "$TEST_INSTANCE_NAME" \
        --key-name $TEST_KEY_NAME
	echo "Assigning floating IP $TEST_FIP to $TEST_INSTANCE_NAME"
	# assign floating IP to test instance
	nova floating-ip-associate "$TEST_INSTANCE_NAME" $TEST_FIP
	ping -qA -c$TEST_PING_COUNT -i$TEST_PING_INTERVAL $TEST_FIP

	if [ "$(type -t image_test_extra)" = function ]
	then
		# Entry point for extra image verification
		image_test_extra
	fi
}

function image_deploy() {
	# set older versions non-public
	images=($(glance image-list --owner "$OS_TENANT_ID" --name "$IMAGE_NAME" \
	| grep "$IMAGE_NAME" | awk -F'|' '{print $2}'))
	images=${images:-}

	for image in ${images[@]}; do
		IMG_NAME=`glance image-show $image | grep name | awk '{ print $4 }'`
		echo "Setting non-public: $image"
		if [[ $IMG_NAME != *"{DEPRECATED}-"* ]]
                then
			glance image-update --is-public False "$image" --name "{DEPRECATED}-$IMG_NAME"
		else
			glance image-update --is-public False "$image"
		fi
	done
	# rename new image
	glance image-update --name "$IMAGE_NAME" \
	--property description="All packages of this image where updated on $(date +%F)" \
	--is-public $IMAGE_IS_PUBLIC "$TMP_IMAGE_NAME"
}

function delete_old_image_versions() {
	images=($(glance image-list --sort-key created_at --sort-dir desc \
	--owner "$OS_TENANT_ID" --name "{DEPRECATED}-$IMAGE_NAME" | grep "$IMAGE_NAME" \
	| awk -F'|' '{print $2}'))
	images=${images:-}

	for delete in ${images[@]:$IMAGE_KEEP_COUNT}; do
		echo "Deleting image: $delete"
		glance image-delete $delete
	done
}
