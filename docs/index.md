# Automated Cloud Image Creation with Diskimage-Builder
 
## Introduction

[Diskimage-Builder](https://github.com/openstack/diskimage-builder) is a dedicated
cloud image building toolkit for OpenStack. It is used to create prepared Linux
disk images with updated packages for cloud environments.

 
## Installation

### Redhat/CentOS

Redhat6 support is not available anymore in the upstream repository.
It is available through CSC fork of the upstream repository for CentOS6 and Scientific-Linux6:

[Diskimage-Builder with CentOS6 support](https://github.com/CSC-IT-Center-for-Science/diskimage-builder/tree/centos6)

Likewise Scientific-Linux7 is only available through the CSC fork:

[Diskimage-Builder with Scientific-Linux7 support](https://github.com/CSC-IT-Center-for-Science/diskimage-builder/tree/scientific7)

For installing Diskimage-Builder on CentOS, the EPEL repository is needed to install the package *python-pip*.

```bash
sudo yum install epel-release
```

Create a dedicated user for image building. The home directory of the dedicated user
should have sufficient disk space, for image creation and image download cache.

Set password-less sudo rights for the dedicated user:
 
/etc/sudoers.d/imgbuild:
```
imgbuild        ALL=(ALL)       NOPASSWD: ALL
```

Install software dependencies and clone the GIT repository for Diskimage-Builder
into the home directory of the dedicated user.

```bash
sudo yum install parted qemu-img kpartx git python python-pip
git clone https://github.com/openstack/diskimage-builder.git
cd diskimage-builder
```

To be able to create CentOS6 and Scientific-Linux6 images,
the CSC fork of Diskimage-Builder has to be used:

```bash
git clone https://github.com/CSC-IT-Center-for-Science/diskimage-builder.git
cd diskimage-builder
git checkout centos6
```

Likewise for Scientific-Linux7:

```bash
git clone https://github.com/CSC-IT-Center-for-Science/diskimage-builder.git
cd diskimage-builder
git checkout scientific7
```

Install Diskimage-Builder in the home directory of the imgbuild user:

```bash
pip install --user -r requirements.txt && python setup.py install --user
```

Add binaries path to *PATH* environment in .bash_profile:

```bash
PATH=$PATH:$HOME/bin:~/.local/bin
export PATH
```

Create temporary directory in the dedicated users home directory.
This directory will be passed as *TMP_DIR* environment variable.
Otherwise Diskimage-Builder will use */tmp* for image preparation.

```bash
mkdir temp
```
 
### Ubuntu

```bash
sudo apt-get install parted qemu-utils kpartx git python python-pip
git clone https://github.com/openstack/diskimage-builder.git
cd diskimage-builder
pip install --user -r requirements.txt && python setup.py install --user
```


## Image Creation

Creating an image for OpenStack using the centos7 element to install centos7 on the image:

```bash
disk-image-create --no-tmpfs -o centos7 --image-size 10 vm centos7
```

Creating an image for OpenStack using centos6 element and a localy provided base image:

```bash
DIB_LOCAL_IMAGE=base_image_centos6.qcow2 disk-image-create --no-tmpfs -o centos6 --image-size 10 vm centos6
```

Setting the temporary directory for image preparation:

```bash
TMP_DIR=~/temp disk-image-create --no-tmpfs -o centos7 --image-size 10 vm centos7
```

Defining additional packages to be installed inside the new image:

```bash
disk-image-create --no-tmpfs -o centos7 --image-size 10 vm centos7 -p apache2,mysql-server
```
 
## Important Parameters

Usage:
 
`disk-image-create [OPTIONS]... [ELEMENTS]...`

Options:

| Parameter     | Explanation |
|---------------|-------------|
| --no-tmpfs    | do not use tmpfs (temp in RAM) but use normal disk temp directory  |
| --image-size  | image size in GB for the created image  |
| --image-cache | directory location for cached images (default ~/.cache/image-create)  |
| -a            | set the architecture of the image (default: amd64)  |
| -t            | set the imagetype of the output image file (qcow2,tar) (default: qcow2) |
| -p            | comma separated list of packages to install in the image  |
| -o            | image name of the output image file (default: image)  |
| -x            | turn on tracing  |

 
## Caching

Located per default in *~/.cache/image-create*, disk-image-create caches images and packages here.
Occasionally a faulty image or element can spoil the cache preventing further image creation,
`rm -rf ~/.cache/image-create` works as a remedy.
 

## Elements

Located in *.local/share/Diskimage-Builder/elements*, these elements are used to configure what type of virtual machine is created.
A machine can be composed of several elements.
For pre made elements, documentation can be found in the element folder, in the file *README.md*.

Additional elements can be included by setting the variable *ELEMENTS_PATH* as a colon-separated path list, pointing to directories with additional elements.

Each VM requires an *operating-system* element, such as *centos6* or *ubuntu* and the *vm* element for partition and filesystem setup.
If an element is an *operating-system* element is determined in the file *element-provides* inside the elements folder.


The element folder contains everything needed by the element:

  - download URLs for the images
  - configuration for yum or apt and other programs etc. For additional packages (installed using the *-p* flag)
  - the portability can be enhanced by mapping package names between distros in a *bin/map-packages* file.
 

## Operating-System Elements

| Parameter     | Explanation |
|---------------|-------------|
| vm        | sets up a partitioned disk and boot loader (this is mandatory for cloud images) |
| ubuntu    | create Ubuntu cloud images.   |
| centos6   | create CentOS6 cloud images (only available through CSC fork) |
| scientific6 | create Scientific-Linux6 cloud images (only available through CSC fork) |
| centos7   | create CentOS7 cloud images   |
| scientific7 | create Scientific-Linux7 cloud images (only available through CSC fork) |
| fedora    | create Fedora cloud images    |
| opensuse  | create OpenSUSE cloud images  |


### CentOS 6

In the upstream project of Diskimage-Builder support for CentOS6 has been removed. There are no base images currently available.
To create CentOS6 images, a base image has to be created and then provided to Diskimage-Builder via *DIB_LOCAL_IMAGE* environment.


### Ubuntu

By default Diskimage-Builder builds the trusty Ubuntu version. To change the version, define the following environment:

```bash
export DIB_RELEASE=saucy
```

#### Base Image Creation with KVM

```bash
sudo virt-install -n centos -r 2048 \
-l  http://mirror.centos.org/centos/6/os/x86_64/ \
--graphics vnc --disk path=/mnt/centos-base,size=10 \
-x "ks=http://192.168.122.1/cloud_base_image_centos6.cfg"
```

A kickstart file for installing CentOS6 cloud base image can be found at
`scripts/cloud_base_image_centos6.ks`.


## Automatic Image Deployment on OpenStack

Clone shell scripts and crontab files from GIT repository:

```bash
git clone https://github.com/CSC-IT-Center-for-Science/diskimage-builder-csc-automation.git .
```

### Install OpenStack glance packages

For uploading the cloud images to an OpenStack cloud, the glance client package needs
to be installed.

### Redhat/CentOS

```bash
sudo yum install python-glanceclient
```

### Ubuntu

```bash
apt-get install python-glanceclient
```

### Setup a cronjob to execute the script periodically

```bash
crontab < scripts/crontab
```

A complete *openrc.sh* with credentials for OpenStack is required at `scripts/openrc.sh`.


On Redhat based systems, sudo is configured to require a tty, and must be disabled in
`/etc/sudoers`:

```
#Defaults    requiretty
```
