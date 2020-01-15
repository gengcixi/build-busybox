#!/bin/bash

TOPDIR=$(cd `dirname $0`;pwd)
# check return error
check_err()
{
        if [ $? -ne 0 ]; then
                echo -e "\033[31m FAIL: $* \033[0m" >&2
                return_val=1
                return
        else
                echo -e "\033[33m PASS: $* \033[0m" >&2
                return_val=0
        fi
}
build_busybox()
{
	echo ${ROOTFS}
	cd busybox-1.31.1
	cp ../unisoc_defconfig configs/
	make unisoc_defconfig
	make
	check_err "make busybox"

	if [ ${return_val} -eq 0 ]; then
		make install
		check_err "install busybox"
	fi
	mv ./_install ../${ROOTFS}
}
clean_busybox()
{
	echo -e "\033[33m clean up busybox \033[0m"
	cd ${TOPDIR}
	rm -rf busybox-1.31.1
	git checkout busybox-1.31.1
}


if [ $# -eq 1 ]; then
	export ROOTFS=rootfs-$1
	if [ -d "${ROOTFS}" ];then
	    rm -rf ${ROOTFS}
	fi
	if [ $1=arm ];then
	    ARCH=arm
	    CROSS_COMPILE=arm-linux-gnueabi-
	elif [ $1=arm64 ];then
	    ARCH=arm64
	    CROSS_COMPILE=aarch64-linux-gnu-
	fi
	build_busybox
	clean_busybox
fi


cd ${TOPDIR}
bash ${TOPDIR}/config.sh $1
