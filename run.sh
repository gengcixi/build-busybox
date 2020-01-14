#!/bin/bash

TOPDIR=$(cd `dirname $0`;pwd)
echo ${TOPDIR}


ROOTFS=rootfs-$1
if [ -d ${ROOTFS} ];then
    rm -rf ${ROOTFS}
fi

if [ $1=arm ];then 
    ARCH=arm
    CROSS_COMPILE=arm-linux-gnueabi-
elif [ $1=arm64 ];then
    ARCH=arm64
    CROSS_COMPILE=aarch64-linux-gnu-
fi

if [ -d busybox ];then
    rm -rf busybox 
fi


cd busybox-1.30.0

cp ../unisoc_defconfig configs/
make unisoc_defconfig
make 
make install
mv ./_install ../${ROOTFS}

cd ${TOPDIR}

./config.sh $1
