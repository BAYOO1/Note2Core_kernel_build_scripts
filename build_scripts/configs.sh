#!/bin/sh

#change the defconfig file names
cd $1/source/arch/arm/configs
cp $2_defconfig $3_defconfig
cp $2_lte_defconfig $3_lte_defconfig
rm $2_defconfig -f
rm $2_lte_defconfig -f 
