#!/bin/bash

TOPDIR=$(cd `dirname $0`;pwd)
echo ${TOPDIR}
ROOTFS=rootfs-$1
    
cd  ${ROOTFS} 
ln linuxrc init
mkdir -pv  dev etc/init.d home  mnt proc root sys tmp  var opt root

sudo mknod dev/console c 5 1
sudo mknod dev/null c 1 3
# write etc/fstab 
echo "proc /proc proc defaults 0 0">etc/fstab
echo "sysfs /sys sysfs defaults 0 0">>etc/fstab
echo "none /dev/pts devpts mode=0622 0 0">>etc/fstab
echo "tmpfs /dev/shm tmpfs defaults 0 0">>etc/fstab

echo "root:x:0:">etc/group
echo "root:x:0:0:root:/root:/bin/sh">etc/passwd
echo "root:/Z4vSfch3M0EI:0:0:99999:7:::">etc/shadow

# write etc/inittab
echo "::sysinit:/etc/init.d/rcS">etc/inittab
echo "#::respawn:-/bin/sh">>etc/inittab
echo "::respawn:-/bin/login">>etc/inittab
echo "::askfirst:-/bin/sh">>etc/inittab
echo "::ctrlaltdel:/bin/umount -a -r">>etc/inittab

# writre etc/profile
echo "# /etc/profile: system-wide .profile file for the Bourne shells">>etc/profile
echo "echo -n \"Processing /etc/profile... \"">>etc/profile
echo "# no-op">>etc/profile
echo "echo \"Done\"">>etc/profile
echo "/bin/hostname unisoc">>etc/profile
echo "USER=\"\`id -un\`\"">>etc/profile
echo "LOGNAME=\$USER">>etc/profile
echo "HOSTNAME='/bin/hostname'">>etc/profile
echo "PS1='[\u@\h \W]#'">>etc/profile

# write etc/init.d/rcS
echo "#! /bin/sh">etc/init.d/rcS
echo "/bin/mount -n -t ramfs ramfs /var">>etc/init.d/rcS
echo "/bin/mount -n -t ramfs ramfs /tmp">>etc/init.d/rcS
echo "/bin/mount -n -t sysfs none /sys">>etc/init.d/rcS
echo "/bin/mount -n -t ramfs none /dev">>etc/init.d/rcS
echo "/bin/mkdir /var/tmp">>etc/init.d/rcS
echo "/bin/mkdir /var/modules">>etc/init.d/rcS
echo "/bin/mkdir /var/run">>etc/init.d/rcS
echo "/bin/mkdir /var/log">>etc/init.d/rcS
echo "/bin/mkdir -p /dev/pts">>etc/init.d/rcS
echo "/bin/mkdir -p /dev/shm">>etc/init.d/rcS
echo "/sbin/mdev -s">>etc/init.d/rcS
echo "/bin/mount -a">>etc/init.d/rcS
echo "echo /sbin/mdev > /proc/sys/kernel/hotplug">>etc/init.d/rcS
echo "mknod dev/console c 5 1">>etc/init.d/rcS
echo "mknod dev/null c 1 3">>etc/init.d/rcS
echo "mknod dev/tty0 c 4 0">>etc/init.d/rcS
echo "mknod dev/tty1 c 4 1">>etc/init.d/rcS
echo "mknod dev/tty2 c 4 2">>etc/init.d/rcS
echo "mknod dev/tty3 c 4 3">>etc/init.d/rcS
echo "mknod dev/tty4 c 4 4">>etc/init.d/rcS
echo "#######配置网络################################">>etc/init.d/rcS
echo "#/sbin/ifconfig lo 127.0.0.1 netmask 255.0.0.0">>etc/init.d/rcS
echo "#/sbin/ifconfig eth0 192.168.8.8">>etc/init.d/rcS
echo "#/sbin/ifconfig eth0 netmask 255.255.255.0">>etc/init.d/rcS
echo "#/sbin/route add default gw 192.168.1.1 eth0">>etc/init.d/rcS
echo "#/sbin/ifconfig eth1 192.168.1.71 netmask 255.255.255.0">>etc/init.d/rcS
echo "#/sbin/route add default gw 192.168.1.1 eth1">>etc/init.d/rcS
chmod a+x etc/init.d/rcS
