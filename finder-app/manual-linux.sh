#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.1.10
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    # TODO: Add your kernel build steps here
    echo "cleanup for kernel build"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper;
    echo "build device config"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig;
    echo "build kernel"
    make -j4 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} all;
    echo "build kernel modules"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules;
    echo "build the devicetree"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} dtbs;
fi

echo "Adding the Image in outdir"
cp ${OUTDIR}/linux-stable/arch/arm64/boot/Image ${OUTDIR}/

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
echo "Create necessary base directories: ${OUTDIR}"
mkdir -p ${OUTDIR}/rootfs;
mkdir -p ${OUTDIR}/rootfs/home;
mkdir -p ${OUTDIR}/rootfs/bin;
mkdir -p ${OUTDIR}/rootfs/sbin;
mkdir -p ${OUTDIR}/rootfs/etc;
mkdir -p ${OUTDIR}/rootfs/dev;
mkdir -p ${OUTDIR}/rootfs/proc;
mkdir -p ${OUTDIR}/rootfs/sys;
mkdir -p ${OUTDIR}/rootfs/lib64;
mkdir -p ${OUTDIR}/rootfs/lib;
mkdir -p ${OUTDIR}/rootfs/lib/modules;
mkdir -p ${OUTDIR}/rootfs/lib/modules/${KERNEL_VERSION};
mkdir -p ${OUTDIR}/rootfs/tmp;
mkdir -p ${OUTDIR}/rootfs/usr;
mkdir -p ${OUTDIR}/rootfs/usr/lib;
mkdir -p ${OUTDIR}/rootfs/usr/bin;
mkdir -p ${OUTDIR}/rootfs/usr/sbin;
mkdir -p ${OUTDIR}/rootfs/var;
mkdir -p ${OUTDIR}/rootfs/var/log;

echo "Created rootfs"

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
else
    cd busybox
fi

# TODO: Make and install busybox
echo "Make and install busybox"
cd ${OUTDIR}/busybox
make distclean;
make defconfig;
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE};
make CONFIG_PREFIX=../rootfs ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install;

cd ${OUTDIR}/rootfs
echo "make busybox binary setuid root to ensure all configured applets will work properly"
chmod u+s bin/busybox

echo "Library dependencies"
${CROSS_COMPILE}readelf -a bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a bin/busybox | grep "Shared library"

# TODO: Add library dependencies to rootfs
echo "Add library dependencies to rootfs"
LIB_SRC=/home/gerhard/compiler-toolchains/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib
LIB64_SRC=/home/gerhard/compiler-toolchains/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64
cp ${LIB_SRC}/ld-linux-aarch64.so.1 lib/
cp ${LIB64_SRC}/ld-2.33.so lib64/

cp ${LIB64_SRC}/libm.so.6 lib64/
cp ${LIB64_SRC}/libm-2.33.so lib64/

cp ${LIB64_SRC}/libresolv.so.2 lib64/
cp ${LIB64_SRC}/libresolv-2.33.so lib64/

cp ${LIB64_SRC}/libc.so.6 lib64/
cp ${LIB64_SRC}/libc-2.33.so lib64/

cp /home/gerhard/compiler-toolchains/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/lib64/libgcc_s.so.1 lib64/
cp /home/gerhard/compiler-toolchains/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/lib64/libstdc++.so.6 lib64/
cp /home/gerhard/compiler-toolchains/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/lib64/libstdc++.so.6.0.28 lib64/

# TODO: Make device nodes
echo "Make device nodes"
sudo mknod -m 666 ${OUTDIR}/rootfs/null c 1 3
sudo mknod -m 666 ${OUTDIR}/rootfs/console c 5 1

# TODO: Clean and build the writer utility
echo "Clean and build the writer utility"
cd ${FINDER_APP_DIR}
make clean
#make
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE};

# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
echo "Copy the finder related scripts and executables to the /home directory"
cp -r ../conf ${OUTDIR}/rootfs/home/
cp ${FINDER_APP_DIR}/finder.sh ${OUTDIR}/rootfs/home/
cp ${FINDER_APP_DIR}/finder-test.sh ${OUTDIR}/rootfs/home/
cp ${FINDER_APP_DIR}/writer ${OUTDIR}/rootfs/home/
cp ${FINDER_APP_DIR}/autorun-qemu.sh ${OUTDIR}/rootfs/home/

# TODO: Chown the root directory
sudo chown root:root ${OUTDIR}/rootfs/

# TODO: Create initramfs.cpio.gz
echo "Create initramfs.cpio.gz"
cd "$OUTDIR/rootfs"
find . | cpio -H newc -ov --owner root:root > ${OUTDIR}/initramfs.cpio
gzip -f ${OUTDIR}/initramfs.cpio