firewall --enabled --service=ssh
repo --name="repo0" --baseurl=http://mirrors.kernel.org/centos/6/os/x86_64
repo --name="repo1" --baseurl=http://mirrors.kernel.org/centos/6/updates/x86_64
repo --name="repo2" --baseurl=http://mirrors.kernel.org/fedora-epel/6/x86_64

auth --useshadow --enablemd5
keyboard us
lang en_US.UTF-8
selinux --enforcing
logging --level=info
poweroff
services --disabled="avahi-daemon,iscsi,iscsid,firstboot,kdump" --enabled="network,sshd,rsyslog,tuned"
timezone --isUtc UTC
network  --bootproto=dhcp --device=eth0 --onboot=on
bootloader --append="console=ttyS0,115200n8 console=tty0" --location=mbr --driveorder="sda" --timeout=1
zerombr
clearpart --all
part / --fstype="ext4" --size=1024

%post
echo "RUN_FIRSTBOOT=NO" > /etc/sysconfig/firstboot
cat <<EOL >> /etc/rc.local
if [ ! -d /root/.ssh ] ; then
    mkdir -p /root/.ssh
    chmod 0700 /root/.ssh
    restorecon /root/.ssh
fi
EOL

cat <<EOL >> /etc/ssh/sshd_config
UseDNS no
PermitRootLogin without-password
EOL

# bz705572
ln -s /boot/grub/grub.conf /etc/grub.conf

# bz688608
sed -i 's|\(^PasswordAuthentication \)yes|\1no|' /etc/ssh/sshd_config

# allow sudo powers to cloud-user
echo -e 'cloud-user\tALL=(ALL)\tNOPASSWD: ALL' >> /etc/sudoers

# bz983611
echo "NOZEROCONF=yes" >> /etc/sysconfig/network

# set virtual-guest as default profile for tuned
echo "virtual-guest" > /etc/tune-profiles/active-profile

#bz 1011013
# set eth0 to recover from dhcp errors
cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << EOF
DEVICE="eth0"
BOOTPROTO="dhcp"
ONBOOT="yes"
TYPE="Ethernet"
USERCTL="yes"
PEERDNS="yes"
IPV6INIT="no"
PERSISTENT_DHCLIENT="1"
EOF

#bz912801
# prevent udev rules from remapping nics
touch /etc/udev/rules.d/75-persistent-net-generator.rules

#setup getty on ttyS0
echo "ttyS0" >> /etc/securetty
cat <<EOF > /etc/init/ttyS0.conf
start on stopped rc RUNLEVEL=[2345]
stop on starting runlevel [016]
respawn
instance /dev/ttyS0
exec /sbin/agetty /dev/ttyS0 115200 vt100-nav
EOF

# clean up installation logs"
yum clean all
rm -rf /var/log/yum.log
rm -rf /var/lib/yum/*
rm -rf /root/install.log
rm -rf /root/install.log.syslog
rm -rf /root/anaconda-ks.cfg
rm -rf /var/log/anaconda*
%end

%packages --nobase
acpid
attr
audit
authconfig
basesystem
bash
cloud-init
dracut-modules-growroot
coreutils
cpio
cronie
device-mapper
dhclient
dracut
e2fsprogs
efibootmgr
filesystem
glibc
grub
heat-cfntools
initscripts
iproute
iptables
iptables-ipv6
iputils
kbd
kernel
kpartx
ncurses
net-tools
nfs-utils
openssh-clients
openssh-server
parted
passwd
policycoreutils
procps
rootfiles
rpm
rsync
rsyslog
selinux-policy
selinux-policy-targeted
sendmail
setup
shadow-utils
sudo
syslinux
tar
tuned
util-linux-ng
vim-minimal
yum
yum-metadata-parser
-*-firmware
-NetworkManager
-b43-openfwwf
-biosdevname
-fprintd
-fprintd-pam
-gtk2
-libfprint
-mcelog
-plymouth
-redhat-support-tool
-system-config-*
-wireless-tools
%end

