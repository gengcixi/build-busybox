#!/bin/sh

topdir=$(pwd)
busybox_tar=busybox-1.35.0.tar.bz2
busybox_src=busybox-1.35.0
busybox_path=${topdir}/busybox-1.35.0
busybox_obj=${topdir}/obj/busybox
busybox_dist=${topdir}/dist/busybox
ramdisk_out=${busybox_obj}/_install
ramdisk_bin=${busybox_dist}/ramdisk.img

tar xf ${busybox_tar}
if [ $? -eq 0 ];then
	cp linux_arm64_defconfig ${busybox_src}/configs/
fi
if [ -d ${busybox_obj} ];then
	rm -rf ${busybox_obj}
	rm -rf ${busybox_dist}
fi
mkdir -p ${busybox_obj} ${busybox_dist}
cd ${busybox_obj}

make KBUILD_SRC=${busybox_path} -f ${busybox_path}/Makefile ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- linux_arm64_defconfig
#make KBUILD_SRC=${busybox_path} -f ${busybox_path}/Makefile ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- menuconfig
make KBUILD_SRC=${busybox_path} -f ${busybox_path}/Makefile ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-
make KBUILD_SRC=${busybox_path} -f ${busybox_path}/Makefile ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- install
cd ${topdir}
#if [ -d ${ramdisk_out} ];then
#	rm -rf ${ramdisk_out}
#fi
#mkdir -p ${ramdisk_out}
#cp ${busybox_obj}/_install/* ${ramdisk_out}/ -raf

cd ${ramdisk_out}
mkdir -pv  dev etc/init.d home  mnt proc root sys tmp  var opt root
cd ${ramdisk_out}/dev 

fakeroot mknod console c 5 1 
fakeroot mknod null c 1 3 

cd ${ramdisk_out}
cat >>etc/fstab << EOF
proc	/proc		proc	defaults	0	0
sysfs	/sys		sysfs	defaults	0	0
none	/dev/pts	devpts	mode=0622	0	0
tmpfs	/dev/shm	tmpfs	defaults	0	0
EOF

cat >>etc/group << EOF
root:x:0:
EOF

cat >>etc/inittab << EOF
::sysinit:/etc/init.d/rcS
#::respawn:-/bin/sh
::respawn:-/bin/login
tty2::askfirst:-/bin/sh
::ctrlaltdel:/bin/umount -a -r
EOF

cat >>etc/passwd << EOF
root:x:0:0:root:/root:/bin/sh
EOF

cat >>etc/profile << EOF
# /etc/profile: system-wide .profile file for the Bourne shells
echo
echo -n "Processing /etc/profile... "
# no-op
echo "Done"
echo
/bin/hostname sprd
USER="`id -un`"
LOGNAME=$USER
HOSTNAME='/bin/hostname'
PS1='[\u@\h \W]#'
EOF

cat >>etc/shadow << EOF
root:/Z4vSfch3M0EI:0:0:99999:7:::
EOF

cat >>etc/init.d/rcS << EOF
#! /bin/sh
/bin/mount -n -t ramfs ramfs /var
/bin/mount -n -t ramfs ramfs /tmp
/bin/mount -n -t sysfs none /sys
/bin/mount -n -t ramfs none /dev
/bin/mkdir /var/tmp
/bin/mkdir /var/modules
/bin/mkdir /var/run
/bin/mkdir /var/log
/bin/mkdir -p /dev/pts
/bin/mkdir -p /dev/shm
/sbin/mdev -s
/bin/mount -a
echo /sbin/mdev > /proc/sys/kernel/hotplug
mknod dev/tty0 c 4 0
mknod dev/tty1 c 4 1
mknod dev/tty2 c 4 2
mknod dev/tty3 c 4 3
mknod dev/tty4 c 4 4
EOF

chmod a+x etc/init.d/rcS

ln -sf init bin/busybox
cd ${topdir}
FAKEROOTDONTTRYCHOWN=1 fakeroot ./make_ext4fs -l 8M ${ramdist_out} ${ramdisk_bin}

