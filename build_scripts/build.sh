#!/bin/sh
clear

# $1 = variables passed from menu.sh , and is used to control what functions of this script
# are executed   .....eg EX,OC,STD, DBG etc etc

# $2 = auto generated directory location for all files in the kitchen, generated from menu.sh

# $3 = normal / lte mode passed from menu,sh

# $4 is version string passed from menu,sh

# $5 is kernel name string passed from menu.sh









# Running defconfig to create the default kernel configuration, then exit to menu
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
  rm .config_LTE -f
  rm .config_NORMAL -f
  cp .config .config_NORMAL
  cp .config .config_LTE
  echo
  echo "Done"
  sleep 3
  exit
fi


# Running defconfig to create the non-LTE configuration, then exit to menu
if [ "$1" = "HC" ]; then
  echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  echo ~~~~~~~~~~~~~~~RUNNING $3 CONFIG~~~~~~~~~~~~~~~
  echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  echo
  echo "Running in $3 mode"
  echo
  echo "Moving to source directory $2/source"
  echo
  #$3 is used here as veriable for name
  cd $2/source >/dev/null
  echo Creating $3_defconfig
  make $3_defconfig
  rm .config_NORMAL -f
  cp .config .config_NORMAL
  echo
  echo "Done"
  sleep 3
  exit
fi

# Running defconfig to create the LTE configuration, then exit to menu
if [ "$1" = "LT" ]; then
  echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  echo ~~~~~~~~~~~~~RUNNING $3 LTE CONFIG~~~~~~~~~~~~~
  echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  echo
  echo "Running in $3 mode"
  echo
  echo "Moving to source directory $2/source"
  echo
  #$3 is used here as veriable for name
  cd $2/source >/dev/null
  echo Creating $3_LTE_defconfig
  make $3_lte_defconfig
  rm .config_LTE -f
  cp .config .config_LTE
  echo
  echo "Done"
  sleep 3
  exit
fi

# check the configs are present
if [ -e "$2/source/.config_LTE" ]; then
	ER="OK"
else
	echo
	echo "Missing LTE config, run option L from the menu"
	ERR="ERR"
fi
if [ -e "$2/source/.config_NORMAL" ]; then
	ER="OK"
else
	echo
	echo "Missing NORMAL config, run option N from the menu"
	ERR="ERR"
fi
if [ "$ERR" = "ERR" ]; then
	echo
	echo "press any key to return to the menu"
	read e
	exit
fi


# MAKE CLEAN the source, then exit to menu
if [ "$1" = "MC" ]; then
  echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  echo ~~~~~~~~~~~~~~~~~~~RUNNING MAKE CLEAN~~~~~~~~~~~~~~~~~
  echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  echo
  echo -n "Running Make Clean in the $2/source directory		"
  echo
  cd $2/source >/dev/null
  make clean -j3 >/dev/null
  make mrproper >/dev/null
  echo
  echo "Done"
  sleep 3
  exit
fi




# Running XCONFIG to create the kernel configuration, then exit to menu
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
  
  # first delete whatever the current.config might be, copy the required .config_xxx to .config
  # run xconfig, then replace all copies of .config_xxx with the new version
  
  # $4 is name here
  if [ "$3" = "NORMAL" ]; then
    rm .config -f
    cp .config_NORMAL .config
    rm .config_NORMAL
    rm $2/source/arch/arm/configs/$4_defconfig -f
    make xconfig -j3 -silent >/dev/null
    cp .config .config_NORMAL
    cp .config $2/source/arch/arm/configs/$4_defconfig
  else #lte
    rm .config -f
    cp .config_LTE .config
    rm .config_LTE -f
    rm $2/source/arch/arm/configs/$4_lte_defconfig -f
    make xconfig -j3 -silent >/dev/null
    cp .config .config_LTE
    cp .config $2/source/arch/arm/configs/$4_lte_defconfig
  fi
  exit
fi

# DEBUG build - compile in this window, one object at a time, pause at the end, then exit to menu
if [ "$1" = "DBG" ]; then
  echo "Building kernel in this window with a pause at the end to check build errors"
  echo "Running in $3 mode"
  echo
  cd $2/source >/dev/null
  #flip to the correct .config NORMAL or LTE
  rm .config -f
  cp .config_$3 .config
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

# check the configs are present again
if [ -e "$2/source/.config_LTE" ]; then
	ER="OK"
else
	echo
	echo "Missing LTE config, run option L from the menu"
	ERR="ERR"
fi
if [ -e "$2/source/.config_NORMAL" ]; then
	ER="OK"
else
	echo
	echo "Missing NORMAL config, run option N from the menu"
	ERR="ERR"
fi
if [ "$ERR" = "ERR" ]; then
	echo
	echo "press any key to return to the menu"
	read e
	exit
fi


# Main section to compile the kernel , when either E,O,or S are pressed in menu.sh
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo ~~~~~~~~~~~~~~~~BUILDING THE $1 KERNEL~~~~~~~~~~~~~~~~
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo "Running in $3 mode"
echo "Verion - v$4"
echo

# Remove any existing zImage, initramfs and flash files in the relevant output directory
rm $2/zImage -f  >/dev/null

if [ "$3" = "NORMAL" ]; then
  rm $2/output/kernel_out_$1/7100/*.tar -f >/dev/null 
  rm $2/output/kernel_out_$1/7100/*.zip -f >/dev/null 
  rm $2/output/kernel_out_$1/7100/*.img -f >/dev/null 
  rm -rf $2/ramdiscs/initramfs  >/dev/null
else #lte
  rm $2/output/kernel_out_$1/7105/*.tar -f >/dev/null
  rm $2/output/kernel_out_$1/7105/*.zip -f >/dev/null
  rm $2/output/kernel_out_$1/7105/*.img -f >/dev/null
  rm -rf $2/ramdiscs/initramfs5  >/dev/null
fi

# Move to the source directory
echo "Moving to source directory $2/source"
echo
cd $2/source >/dev/null

#flip to the correct .config NORMAL or LTE
rm .config -f
cp .config_$3 .config
echo "Using .config							$3"

# set fsync and 1.8ghz conditions in the .config depending on what kernel has been selected
# to build.  We replace the lines in the .config using "sed" as they cannot be set using
# the "export" command
echo -n "Set Fsync function						"
if [ "$1" = "EX" -o "$1" = "AS" ]; then
    sed -ir 's/.*CONFIG_FSYNC_OFF.*/CONFIG_FSYNC_OFF=y/g' .config
    echo "Disabled"
else #OC or STD
    sed -ir 's/.*CONFIG_FSYNC_OFF.*/# CONFIG_FSYNC_OFF is not set/g' .config
    echo "Enabled"
fi

echo -n "Set MAX CPU							"
if [ "$1" = "EX" -o "$1" = "OC" -o "$1" = "AS" ]; then
    if [ "$1" = "OC" ]; then
	sed -ir 's/.*CONFIG_OC_EIGHTEEN.*/CONFIG_OC_EIGHTEEN=y/g' .config
	sed -ir 's/.*CONFIG_OC_NINETEEN.*/# CONFIG_OC_NINETEEN is not set/g' .config
	sed -ir 's/.*CONFIG_OC_SIXTEEN.*/# CONFIG_OC_SIXTEEN is not set/g' .config
	echo "1.8ghz"
    fi
    if [ "$1" = "EX" ]; then
	sed -ir 's/.*CONFIG_OC_EIGHTEEN.*/CONFIG_OC_EIGHTEEN=y/g' .config
	sed -ir 's/.*CONFIG_OC_NINETEEN.*/# CONFIG_OC_NINETEEN is not set/g' .config
	sed -ir 's/.*CONFIG_OC_SIXTEEN.*/# CONFIG_OC_SIXTEEN is not set/g' .config
	echo "1.8ghz"
    fi
    if [ "$1" = "AS" ]; then
	sed -ir 's/.*CONFIG_OC_NINETEEN.*/CONFIG_OC_NINETEEN=y/g' .config
	sed -ir 's/.*CONFIG_OC_EIGHTEEN.*/# CONFIG_OC_EIGHTEEN is not set/g' .config
	sed -ir 's/.*CONFIG_OC_SIXTEEN.*/# CONFIG_OC_SIXTEEN is not set/g' .config
	echo "1.9ghz"
    fi
else #STD
    sed -ir 's/.*CONFIG_OC_EIGHTEEN.*/# CONFIG_OC_EIGHTEEN is not set/g' .config
    sed -ir 's/.*CONFIG_OC_NINETEEN.*/# CONFIG_OC_NINETEEN is not set/g' .config
    sed -ir 's/.*CONFIG_OC_SIXTEEN.*/CONFIG_OC_SIXTEEN=y/g' .config
    echo "1.6ghz"
fi

# Create a working copy of the initramfs
echo -n "Create a working copy of the initramfs				"
if [ "$3" = "NORMAL" ]; then
  mkdir -p $2/ramdiscs/initramfs >/dev/null
  rm -rf $2/ramdiscs/initramfs/*  >/dev/null
  cp -R $2/ramdiscs/initramfs_n7100/* $2/ramdiscs/initramfs  >/dev/null
  chmod -R g-w $2/ramdiscs/initramfs/*  >/dev/null
  echo "done"
else #lte
  mkdir -p $2/ramdiscs/initramfs5 >/dev/null
  rm -rf $2/ramdiscs/initramfs5/*  >/dev/null
  cp -R $2/ramdiscs/initramfs_n7105/* $2/ramdiscs/initramfs5  >/dev/null
  chmod -R g-w $2/ramdiscs/initramfs5/*  >/dev/null
  echo "done"
fi


# Enable FIPS mode, required otherwise the kernel will not boot
# also set custom kernel version string
export USE_SEC_FIPS_MODE=true
if [ "$3" = "NORMAL" ]; then
  export LOCALVERSION="-'$5'-v'$4'_'$1'" #eg -$5_v1.05_EX
else #lte
  export LOCALVERSION="-'$5'-v'$4'_'$1'_'$3'" #eg -$5_v1.05_EX_LTE
fi

# Run the compile
echo -n "Compiling kernel						"
xterm -e make -j5
echo "done"

# Copy modules to working initramfs
echo "Copy compiled modules and make ramdisk cpio			"
echo
if [ "$3" = "NORMAL" ]; then
  find -name '*.ko' -exec cp -av {} $2/ramdiscs/initramfs/lib/modules/ \;  >/dev/null
else #lte
  find -name '*.ko' -exec cp -av {} $2/ramdiscs/initramfs5/lib/modules/ \;  >/dev/null
fi

# build the initramfs .cpio's
if [ "$3" = "NORMAL" ]; then
  cd $2/ramdiscs/initramfs
  find | cpio -H newc -o > $2/ramdiscs/initramfs/initramfs.cpio
  ls -lh initramfs.cpio >/dev/null
  gzip -9 initramfs.cpio >/dev/null
  sleep 2
else #lte
  cd $2/ramdiscs/initramfs5
  find | cpio -H newc -o > $2/ramdiscs/initramfs5/initramfs5.cpio
  ls -lh initramfs5.cpio >/dev/null
  gzip -9 initramfs5.cpio >/dev/null
  sleep 2
fi
echo

# Recompile just the zImage
echo -n "Re-Compiling zImage						"
cd $2/source  >/dev/null
nice make -j5 zImage >/dev/null
echo "done"

# Create the boot.img with the zImage and initramfs ramdisk cpio archive
echo -n "Create the boot.img						"
cp $2/source/arch/arm/boot/zImage $2/zImage  >/dev/null
if [ "$3" = "NORMAL" ]; then
    $2/build_scripts/mkbootimg --kernel $2/zImage --ramdisk $2/ramdiscs/initramfs/initramfs.cpio.gz --board smdk4x12 --base 0x10000000 --pagesize 2048 --ramdiskaddr 0x11000000 -o $2/output/kernel_out_$1/7100/boot.img >/dev/null
else #lte
    $2/build_scripts/mkbootimg --kernel $2/zImage --ramdisk $2/ramdiscs/initramfs5/initramfs5.cpio.gz --board smdk4x12 --base 0x10000000 --pagesize 2048 --ramdiskaddr 0x11000000 -o $2/output/kernel_out_$1/7105/boot.img >/dev/null
fi
echo "done"

# Build the finished CWM zip and ODIN tar archives
echo -n "Make flash files						"
if [ "$3" = "NORMAL" ]; then
  cd $2/output/kernel_out_$1/7100 >/dev/null
  zip -r $5_7100_v$4_$1.zip * >/dev/null
  tar -H ustar -cvf $5_7100_v$4_$1.tar boot.img >/dev/null
  md5sum -t $5_7100_v$4_$1.tar >> $5_7100_v$4_$1.tar >/dev/null
  rm  $2/upload/7100/CWM-ZIPS/$5_7100_v$4_$1.zip -f
  rm  $2/upload/7100/ODIN-TAR/$5_7100_v$4_$1.tar -f
  cp $5_7100_v$4_$1.zip $2/upload/7100/CWM-ZIPS/
  cp $5_7100_v$4_$1.tar $2/upload/7100/ODIN-TAR/
else #lte
  cd $2/output/kernel_out_$1/7105 >/dev/null
  zip -r $5_7105_v$4_$1.zip * >/dev/null
  tar -H ustar -cvf $5_7105_v$4_$1.tar boot.img >/dev/null
  md5sum -t $5_7105_v$4_$1.tar >> $5_7105_v$4_$1.tar >/dev/null
  rm $2/upload/7105/CWM-ZIPS/$5_7105_v$4_$1.zip -f
  rm $2/upload/7105/ODIN-TAR/$5_7105_v$4_$1.tar -f
  cp $5_7105_v$4_$1.zip $2/upload/7105/CWM-ZIPS/
  cp $5_7105_v$4_$1.tar $2/upload/7105/ODIN-TAR/
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

