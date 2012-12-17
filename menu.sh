#!/bin/sh

#create working directory variable - automatic - will detect whatever directory you are currently in
PLACE=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

#menu options and what we do with them
while true; do
    VER=$(head -n 1 $PLACE/build_scripts/version.txt)
    NAME=$(head -n 1 $PLACE/build_scripts/name.txt)
    MODE=$(head -n 1 $PLACE/build_scripts/mode.txt)
    clear
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo "~~~$NAME kernel Autobuilder v7.2~~~"
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo "Build version			v$VER"
    echo "Kernel Name			$NAME"
    echo "Operational mode for compile	$MODE"
    echo
    echo "Working directory = $PLACE"
    echo 
    echo "OPTION			FUNCTION"
    echo
    echo "  D			Create the standard t0_04_defconfig"
    echo "  N			Create the $NAME defconfig"
    echo "  L			Create the $NAME LTE defconfig"
    echo
    echo "  X			Configure your kernel with xconfig"
    echo "  V			Change kernel build version"
    echo "  M			Change Kernel name"
    echo "  F			Flip compile mode between NORMAL and LTE"
    echo
    echo "  S			Compile STD kernel 		(1.6ghz fsync on) $MODE"
    echo "  O			Compile OC kernel 		(1.8ghz fsync on) $MODE"
    echo "  E			Compile EX kernel		(1.8ghz fsync off) $MODE"
    echo "  A			Compile AS Kernel		(1.9+ghz fsync off) $MODE"
    echo
    echo "  B			Bug-finding compile"
    echo
    echo "  C			Make Clean and mrproper the /source "
    echo
    echo "  Q			Quit"
    echo
    read  -p "Choose > " choice
    case $choice in

# now we determine what option was selected, and run the build.sh script, passing the relevant
# parameters to determine the functions it executes.
# Parameter 1=Function  $PLACE=automatic working directory detection
	[Dd]* ) $PLACE/build_scripts/build.sh DF $PLACE;;
	[Nn]* ) $PLACE/build_scripts/build.sh HC $PLACE $NAME;;
	[Ll]* ) $PLACE/build_scripts/build.sh LT $PLACE $NAME;;
	[Xx]* ) $PLACE/build_scripts/build.sh XC $PLACE $MODE $NAME;;
	[Ss]* ) $PLACE/build_scripts/build.sh STD $PLACE $MODE $VER $NAME;;
	[Oo]* ) $PLACE/build_scripts/build.sh OC $PLACE $MODE $VER $NAME;;
	[Ee]* ) $PLACE/build_scripts/build.sh EX $PLACE $MODE $VER $NAME;;
	[Aa]* ) $PLACE/build_scripts/build.sh AS $PLACE $MODE $VER $NAME;;
	[Bb]* ) $PLACE/build_scripts/build.sh DBG $PLACE $MODE;;
	[Cc]* ) $PLACE/build_scripts/build.sh MC $PLACE;;
	[Ff]* ) if [ "$MODE" = "NORMAL" ]; then MODE="LTE"; echo "LTE">$PLACE/build_scripts/mode.txt;else MODE="NORMAL"; echo "NORMAL">$PLACE/build_scripts/mode.txt; fi;;
	[Vv]* ) $PLACE/build_scripts/ver.sh $PLACE $VER;;
	[Mm]* ) $PLACE/build_scripts/name.sh $PLACE $NAME;;
        [Qq]* ) exit;;
        * ) echo ".";;
    esac
done
