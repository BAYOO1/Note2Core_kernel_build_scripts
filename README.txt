How to build you own Note2Core Galaxy Note2 kernel

First, you need a linux computer (or a linux VM), with "git", "g++" and "libncurses" installed
Secondly, you need a cross compiler toolchain.  The standard Google NDK 4.4.3 GCC is recommended


Now, firstly you need to "git clone" a number of repositories from github, and lay them out in the
following process

--------------------------------------------------------------------------------------------

Stage 1)

Create a working folder anywhere on your system, preferably on your desktop.  The name of the folder does
not matter.  In this example we will call it KBUILD.  Now open a terminal, navigate to your new folder and run 

"git clone https://github.com/glewarne/Note2Core_kernel_build_scripts.git"

This will craete a folder called "Note2Core_kernel_build_scripts".  Open this folder, and move all the contents
into the original folder (KBUILD), so it looks like this

>KBUILD
>>build_scripts
>>output
>>menu.sh

and delete the now empty folder from the git clone

--------------------------------------------------------------------------------------------
Stage 2)

In terminal again, within your KBUILD folder run

"git clone https://github.com/glewarne/GT-N7105_ramdisk.git"
and then
"git clone https://github.com/glewarne/GT-N7100_ramdisk.git"

As before, there will be two new folders.  Now, make a new folder in your KBUILD directory called "ramdiscs", and within 
the new "ramdiscs" folder another 2 folders, called "initramfs_n7100" and "initramfs_n7105"  Now copy the contents of the folders
created when you ran the last two "git clone" commands into their respective ramdiscs>initramfs_n710x folder, and delete the now
empty directories from the "git clone" commands,

Your folder structure should now look like this

>KBUILD
>>build_scripts
>>output
>>ramdiscs
>>>>initramfs_n7100
>>>>initramfs_n7105
>>menu.sh

--------------------------------------------------------------------------------------------
Stage 3)

In terminal, in your KBUILD folder, now run this command

"git clone https://github.com/glewarne/Note2Core_v2_GT_N710x_Kernel.git"

This will take a while, depending on your connection speed.  Once complete, simply rename the new folder "source"

Your folder structure should now look like this

>KBUILD
>>build_scripts
>>output
>>ramdiscs
>>>>initramfs_n7100
>>>>initramfs_n7105
>>source
>>menu.sh

--------------------------------------------------------------------------------------------
Stage 4)

You are nearly ready!  Now all you have to do is edit the Makefile in the source folder to point to the location of your
downloaded toolchain.

Edit from this:  CROSS_COMPILE	?= ../toolchain/arm-eabi-4.4.3/bin/arm-eabi-

to this: CROSS_COMPILE	?= LOCATION-OF-YOUR-TOOLCHAIN-BIN-FOLDER/arm-eabi-   
(arm-eabi- may be different depending on the toolchain you have decided to use)

--------------------------------------------------------------------------------------------
Stage 5)

Now, you should be ready to compile!

Run the menu,sh script from a root (or sudo) terminal

"./menu.sh"

The menu is reasonably self explanatory, and if you compile sucessfully your kernel .zip and .tar will end up in the relevant
subdirectory in the KBUILD/output folder

Happy compiling!