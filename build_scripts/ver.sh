#!/bin/sh
clear

cd $1/build_scripts
VER=$(head -n 1 $1/build_scripts/version.txt)
echo
echo "Current Kernel Version $2"
read  -p "Enter new version number > " newv
rm version.txt -f
echo $newv > version.txt
