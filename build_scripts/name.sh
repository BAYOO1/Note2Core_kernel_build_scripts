#!/bin/sh
clear

#navigate to build_scripts directory
cd $1/build_scripts

#read current kernel name from name.txt
NAME=$(head -n 1 $1/build_scripts/name.txt)

#get new kernel name from user input
echo
echo "Current Kernel Name $2"
read  -p "Enter new kernel Name > " newv

#remove the old version.txt file
rm name.txt -f

#write new version.txt file with new version number
echo $newv > name.txt
