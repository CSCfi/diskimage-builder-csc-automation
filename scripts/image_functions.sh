#!/bin/bash -lv
export PYTHONIOENCODING

function cleanup() {
    # make sure IMAGE_NAME is actually defined before running deletion commands
    if [ ! -z "$IMAGE_NAME" ]; then
        echo "Deleting ${IMAGE_NAME}.d folders"
        find . -maxdepth 5 -name "${IMAGE_NAME}.d" -type d -exec rm -rf {} +
        echo "Deleting ${IMAGE_NAME}.qcow2 files"
        find . -maxdepth 5 -name "${IMAGE_NAME}.qcow2" -type f -exec rm -f {} +
        echo "Deleting ${IMAGE_NAME}.raw files"
        find . -maxdepth 5 -name "${IMAGE_NAME}.raw" -type f -exec rm -f {} +
    fi
    # delete any orphaned temporary images using image_id
    echo "Deleting old images from OS"
    for id in $(glance image-list | grep "$TMP_IMAGE_NAME" | awk '{print $2}')
    do
        glance image-delete "$id" &>/dev/null || true
    done
    # delete any orphaned test instance using instance_id
    echo "Deleting orphaned test instance using instance_id"
    for id in $(nova list | grep "$TEST_INSTANCE_NAME" | awk '{print $2}')
    do
        nova delete "$id" &>/dev/null || true
    done
}

function image_create() {
	# create cloud image with diskimage-builder
	TMP_DIR=~/temp disk-image-create $DIB_OPTIONS -o "$IMAGE_NAME" \
	    -p "$PACKAGES" -t "$IMAGE_FORMAT" $ELEMENTS
}

function image_download() {
    curl -L -o ${IMAGE_NAME}.qcow2 "$1"
    if [ "$IMAGE_FORMAT" != "qcow2" ]; then
        qemu-img convert -f qcow2 -O ${IMAGE_FORMAT} ${IMAGE_NAME}.qcow2 ${IMAGE_NAME}.${IMAGE_FORMAT}
    fi
}

function image_test() {
    echo "Creating test image $TMP_IMAGE_NAME"
    # create new temporary image
    if [ -z "${OS_DISTRO_PROPERTY:-}" ]; then
        OS_DISTRO_PROPERTY=""
    fi
    glance image-create --name "$TMP_IMAGE_NAME" --container-format bare \
        --disk-format "$IMAGE_FORMAT" --visibility private --progress \
        --file "${IMAGE_NAME}.${IMAGE_FORMAT}" \
        --property os_distro="$OS_DISTRO_PROPERTY"
    echo "Creating test instance $TEST_INSTANCE_NAME"
    # create new test instance
    nova boot --flavor "$TEST_FLAVOR" --image "$TMP_IMAGE_NAME"\
        --nic net-id="$TEST_NET_ID" --poll "$TEST_INSTANCE_NAME"
    # assign floating IP to test instance for cPouta
    if [[ -v  "${TEST_FIP+x}" ]]; then
        echo "Assigning floating IP $TEST_FIP to $TEST_INSTANCE_NAME"
        nova floating-ip-associate "$TEST_INSTANCE_NAME" "$TEST_FIP"
        ping -qA -c"$TEST_PING_COUNT" -i"$TEST_PING_INTERVAL" "$TEST_FIP"
    fi
}

function image_deploy() {
    # set older versions non-public or skip if a new image
    images=($(glance image-list --property owner="$OS_TENANT_ID" --property\
        name="$IMAGE_NAME" | grep "$IMAGE_NAME" | awk -F'| ' '{print $2}'))
    images=${images:-}
    if [[ "${images:-}" ]]; then
        for image in ${images[@]}; do
            echo "Setting non-public: $image"
            glance image-update  --visibility private $image
        done
    fi
    # rename new image
    echo "Renaming $TMP_IMAGE_NAME to $IMAGE_NAME"
    glance image-update --name "$IMAGE_NAME" \
        --property description="All packages of this image were updated on $(date +%F). To find out which user to login with: ssh in as root." \
        --visibility "$IMAGE_VISIBILITY" \
        $(glance image-list | grep "$TMP_IMAGE_NAME" | cut -d '|' -f2)
}

function delete_old_image_versions() {

    OSIDCHARS=$(echo $OS_PROJECT_ID|wc -c)
    if [ "$OSIDCHARS" -lt 20 ]; then
        # For some of our old projects OS_PROJECT_ID is the same as project name
        # In that case we want to use the name
        OS_REAL_TENANT_ID=$OS_PROJECT_NAME
    else
        # When OS_PROJECT_ID is long, we want to use that
        OS_REAL_TENANT_ID=$OS_PROJECT_ID
    fi

    images=($(glance image-list --sort-key created_at --sort-dir desc\
        --property owner="$OS_REAL_TENANT_ID" --property name="$IMAGE_NAME"\
        | grep "$IMAGE_NAME" | awk -F'|' '{print $2}'))
    images=${images:-}

    for delete in "${images[@]:$IMAGE_KEEP_COUNT}"; do
        echo "Deleting image: $delete"
        glance image-delete "$delete"
    done
}
