#!/bin/sh
clear

# $1 = variables passed from menu.sh , and is used to control what functions of this script
# are executed

# $2 = auto generated directory location for all files in the kitchen, generated from menu.sh



# MAKE CLEAN the source, then exit
if [ "$1" = "MC" ]; then
  echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  echo ~~~~~~~~~~~~~~~~~~~RUNNING MAKE CLEAN~~~~~~~~~~~~~~~~~
  echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  echo
  echo -n "Running Make Clean in the $2/source directory		"
  echo
  cd $2/source >/dev/null
  make clean >/dev/null
  make mrproper >/dev/null
  echo
  echo "Done"
  sleep 3
  exit
fi


# Running defconfig to create the default kernel configuration, then exit
if [ "$1" = "DF" ]; then
  echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  echo ~~~~~~~~~~~~~~~~~~~RUNNING DEFCONFIG~~~~~~~~~~~~~~~~~~
  echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  echo
  echo "Moving to source directory $2 /source"
  echo
  cd $2/source >/dev/null
  echo "Creating t0_04_defconfig"
  make t0_04_defconfig
  echo
  echo "Done"
  sleep 3
  exit
fi

# Running defconfig to create the default kernel configuration, then exit
if [ "$1" = "HC" ]; then
  echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  echo ~~~~~~~~~~~~~~~RUNNING NOTE2CORE CONFIG~~~~~~~~~~~~~~~
  echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  echo
  echo "Running in $3 mode"
  echo
  echo "Moving to source directory $2/source"
  echo
  cd $2/source >/dev/null
  echo Creating Note2Core_defconfig
  make note2core_defconfig
  echo
  echo "Done"
  sleep 3
  exit
fi

# Running defconfig to create the default LTE kernel configuration, then exit
if [ "$1" = "LT" ]; then
  echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  echo ~~~~~~~~~~~~~RUNNING NOTE2CORE LTE CONFIG~~~~~~~~~~~~~
  echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  echo
  echo "Running in $3 mode"
  echo
  echo "Moving to source directory $2/source"
  echo
  cd $2/source >/dev/null
  echo Creating Note2Core_LTE_defconfig
  make note2core_lte_defconfig
  echo
  echo "Done"
  sleep 3
  exit
fi


# Running XCONFIG to create the kernel configuration, then exit
if [ "$1" = "XC" ]; then
  echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  echo ~~~~~~~~~~~~~~~~~~~~RUNNING XCONFIG~~~~~~~~~~~~~~~~~~~
  echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  echo
  echo "Running in $3 mode"
  echo
  echo "Moving to source directory $2/source"
  cd $2/source >/dev/null
  echo
  echo Launching xconfig.....
  make xconfig -silent >/dev/null
  if [ "$3" = "LTE" ]; then
    rm .config_LTE_* -f
    rm $2/modified_source_files/arch/arm/configs/note2core_lte_defconfig -f
    cp .config .config_LTE_EX
    cp .config $2/modified_source_files/arch/arm/configs/note2core_lte_defconfig
  fi
  if [ "$3" = "NORMAL" ]; then
    rm .config_NORMAL_* -f
    rm $2/modified_source_files/arch/arm/configs/note2core_defconfig -f
    cp .config .config_NORMAL_EX
    cp .config $2/modified_source_files/arch/arm/configs/note2core_defconfig
  fi
  exit
fi

# DEBUG build - compile in this window, one object at a time, pause at the end, then exit 
if [ "$1" = "DBG" ]; then
  echo "Building kernel in this window with a pause at the end to check build errors"
  echo "Running in $3 mode"
  echo
  cd $2/source
  #force recompile of sync and cpufreq
  cd $2/source >/dev/null
  make
  echo
  echo "Press enter to return to the menu"
  read i
  exit
fi

#######
#######
#      END OF SCRIPT PROCESSING OPTIONS     #
#      NORMALAL COMPILE PROCESSING BELOW    #
#######
#######




# Main section to compile the kernel 
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo ~~~~~~~~~~~~~~~~BUILDING THE $1 KERNEL~~~~~~~~~~~~~~~~
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo "Running in $3 mode"
echo "Verion - v$4"
echo

# Remove any existing zImage, initramfs and flash files in the relevant output directory
rm $2/zImage -f  >/dev/null

if [ "$3" = "NORMAL" ]; then
rm $2/output/kernel_out_$1/7100/*.tar -f >/dev/null >/dev/null
rm $2/output/kernel_out_$1/7100/*.zip -f >/dev/null >/dev/null
rm $2/output/kernel_out_$1/7100/*.img -f >/dev/null >/dev/null
rm -rf $2/ramdiscs/initramfs  >/dev/null
fi

if [ "$3" = "LTE" ]; then
rm $2/output/kernel_out_$1/7105/*.tar -f >/dev/null >/dev/null
rm $2/output/kernel_out_$1/7105/*.zip -f >/dev/null >/dev/null
rm $2/output/kernel_out_$1/7105/*.img -f >/dev/null >/dev/null
rm -rf $2/ramdiscs/initramfs5  >/dev/null
fi

# Move to the source directory
echo "Moving to source directory $2/source"
echo

cd $2/source >/dev/null

#force recompile of sync and cpufreq
rm arch/arm/mach-exynos/cpufreq-4x12.o -f >/dev/null
rm fs/sync.o -f >/dev/null

echo "Set CPU frequency table to $1					done"

if [ "$1" = "EX" ]; then
    echo "Fsync() filesystem function					disabled"
else
    echo "Fsync() filesystem function				 	enabled"
fi

#flip to the correct .config
rm .config -f >/dev/null
cp .config_$3_$1 .config >/dev/null
echo "Using .config_$3_$1						done"

echo -n "Create a working copy of the initramfs				"
# Copy a working copy of the initramfs
mkdir -p $2/ramdiscs/initramfs >/dev/null
rm -rf $2/ramdiscs/initramfs/*  >/dev/null
mkdir -p $2/ramdiscs/initramfs5 >/dev/null
rm -rf $2/ramdiscs/initramfs5/*  >/dev/null
cp -R $2/ramdiscs/initramfs_n7100/* $2/ramdiscs/initramfs  >/dev/null
cp -R $2/ramdiscs/initramfs_n7105/* $2/ramdiscs/initramfs5  >/dev/null
chmod -R g-w $2/ramdiscs/initramfs/*  >/dev/null
chmod -R g-w $2/ramdiscs/initramfs5/*  >/dev/null
echo "done"


# Enable FIPS mode, required otherwise the kernel will not boot
# also set custom kernel version string
export USE_SEC_FIPS_MODE=true
if [ "$3" = "NORMAL" ]; then
  export LOCALVERSION="-Note2Core-v'$4'_'$1'"
fi
if [ "$3" = "LTE" ]; then
  export LOCALVERSION="-Note2Core-v'$4'_'$1'_'$3'"
fi

# Run the compile
echo -n "Compiling kernel						"
xterm -e nice -n 10 make -j2
echo "done"

# Copy modules to working initramfs
echo "Copy compiled modules and make ramdisk cpio			"
echo
find -name '*.ko' -exec cp -av {} $2/ramdiscs/initramfs/lib/modules/ \;  >/dev/null
find -name '*.ko' -exec cp -av {} $2/ramdiscs/initramfs5/lib/modules/ \;  >/dev/null


if [ "$3" = "NORMAL" ]; then
  cd $2/ramdiscs/initramfs
  find | fakeroot cpio -H newc -o > $2/ramdiscs/initramfs/initramfs.cpio
  ls -lh initramfs.cpio >/dev/null
  gzip -9 initramfs.cpio >/dev/null
  sleep 2
fi

if [ "$3" = "LTE" ]; then
  cd $2/ramdiscs/initramfs5
  find | fakeroot cpio -H newc -o > $2/ramdiscs/initramfs5/initramfs5.cpio
  ls -lh initramfs5.cpio >/dev/null
  gzip -9 initramfs5.cpio >/dev/null
  sleep 2
fi
echo

echo -n "Re-Compiling zImage						"
cd $2/source  >/dev/null
nice -n 10 make -j2 zImage >/dev/null
echo "done"

#create the boot.img with the zImage and initramfs ramdisk cpio archive
echo -n "Create the boot.img						"
cp $2/source/arch/arm/boot/zImage $2/zImage  >/dev/null
if [ "$3" = "NORMAL" ]; then
    $2/build_scripts/mkbootimg --kernel $2/zImage --ramdisk $2/ramdiscs/initramfs/initramfs.cpio.gz --board smdk4x12 --base 0x10000000 --pagesize 2048 --ramdiskaddr 0x11000000 -o $2/output/kernel_out_$1/7100/boot.img >/dev/null
fi
if [ "$3" = "LTE" ]; then
    $2/build_scripts/mkbootimg --kernel $2/zImage --ramdisk $2/ramdiscs/initramfs5/initramfs5.cpio.gz --board smdk4x12 --base 0x10000000 --pagesize 2048 --ramdiskaddr 0x11000000 -o $2/output/kernel_out_$1/7105/boot.img >/dev/null
fi
echo "done"

# Build the finished CWM zip and ODIN tar archives
echo -n "Make flash files						"
if [ "$3" = "NORMAL" ]; then
  cd $2/output/kernel_out_$1/7100 >/dev/null
  zip -r GL_Note2Core_7100_v$4_$1.zip * >/dev/null
  tar -H ustar -cvf GL_Note2Core_7100_v$4_$1.tar boot.img >/dev/null
  md5sum -t GL_Note2Core_7100_v$4_$1.tar >> GL_Note2Core_7100_v$4_$1.tar >/dev/null
fi

if [ "$3" = "LTE" ]; then
  cd $2/output/kernel_out_$1/7105 >/dev/null
  zip -r GL_Note2Core_7105_v$4_$1.zip * >/dev/null
  tar -H ustar -cvf GL_Note2Core_7105_v$4_$1.tar boot.img >/dev/null
  md5sum -t GL_Note2Core_7105_v$4_$1.tar >> GL_Note2Core_7105_v$4_$1.tar >/dev/null
  echo "done"
  echo
fi
echo "done"
echo


# Remove any existing zImage, initramfs and flash files in the relevant output directory
echo "Cleanup..."
rm $2/zImage -f  >/dev/null
rm -rf $2/ramdiscs/initramfs  >/dev/null
rm -rf $2/ramdiscs/initramfs5  >/dev/null



# Nice ending, then exit back to menu
echo ~~~~~~~~~~~~~COMPILE COMPLETE~~~~~~~~~~~~~
echo -n "5.." 
sleep 1
echo -n "4.." 
sleep 1
echo -n "3.." 
sleep 1
echo -n "2.." 
sleep 1
echo -n "1.." 
sleep 1

