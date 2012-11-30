#!/bin/sh
clear

#navigate to build_scripts directory
cd $1/build_scripts

#read current kernel build version from version.txt
VER=$(head -n 1 $1/build_scripts/version.txt)

#get new kernel build version from user input
echo
echo "Current Kernel Version $2"
read  -p "Enter new version number > " newv

#remove the old version.txt file
rm version.txt -f

#write new version.txt file with new version number
echo $newv > version.txt
