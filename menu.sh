#!/bin/sh

#create working directory variable - automatic - will detect whatever directory you extract the
#source package too
PLACE=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
MODE="NORMAL"

$PLACE/build_scripts/flip.sh EX $PLACE $MODE
VER=$(head -n 1 $PLACE/build_scripts/version.txt)


#menu options and what we do with them
while true; do
    VER=$(head -n 1 $PLACE/build_scripts/version.txt)
    clear
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo "~~~Note2Core kernel Autobuilder v6.2~~~"
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo "Build version v$VER"
    echo "Operational mode for compile - $MODE"
    echo
    echo "Working directory = $PLACE"
    echo 
    echo "OPTION			FUNCTION"
    echo
    echo "  D			Create the standard t0_04_defconfig"
    echo "  N			Create the Note2Core defconfig"
    echo "  L			Create the Note2Core LTE defconfig"
    echo "  X			Configure your kernel with xconfig"
    echo
    echo "  S			Compile STD kernel 		(1.6ghz fsync on) $MODE"
    echo "  O			Compile OC kernel 		(1.8ghz fsync on) $MODE"
    echo "  E			Compile EX kernel		(1.8ghz fsync off) $MODE"
    echo "  B			Bug-finding compile"
    echo
    echo "  C			Make Clean the source "
    echo
    echo 
    echo "  F			Flip compile mode between NORMAL and LTE"
    echo "  V			Change kernel version number"
    echo
    echo "  Q			Quit"
    echo
    read  -p "Choose > " choice
    case $choice in

# now we determine what option was selected, and run the build.sh script, passing the relevant
# parameters to determine the functions it executes.
# Parameter 1=Function  $PLACE=automatic working directory detection
	[Dd]* ) $PLACE/build_scripts/build.sh DF $PLACE;;
	[Nn]* ) $PLACE/build_scripts/build.sh HC $PLACE;;
	[Ll]* ) $PLACE/build_scripts/build.sh LT $PLACE;;
	[Xx]* ) $PLACE/build_scripts/build.sh XC $PLACE $MODE;;
	
	[Ss]* ) $PLACE/build_scripts/build.sh STD $PLACE $MODE $VER;;
	[Oo]* ) $PLACE/build_scripts/build.sh OC $PLACE $MODE $VER;;
	[Ee]* ) $PLACE/build_scripts/build.sh EX $PLACE $MODE $VER;;
	[Bb]* ) $PLACE/build_scripts/build.sh DBG $PLACE $MODE;;
	

	[Cc]* ) $PLACE/build_scripts/build.sh MC $PLACE;;
	[Ff]* ) if [ "$MODE" = "NORMAL" ]; then MODE="LTE" ;else MODE="NORMAL"; fi;;
	[Vv]* ) $PLACE/build_scripts/ver.sh $PLACE $VER;;
        [Qq]* ) exit;;
        * ) echo "Please answer d,p,x,o,s,d,m or q.";;
    esac
done
