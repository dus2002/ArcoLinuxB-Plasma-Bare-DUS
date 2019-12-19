#!/bin/bash
#set -e
##################################################################################################################
# Author	:	Erik Dubois
# Website	:	https://www.erikdubois.be
# Website	:	https://www.arcolinux.info
# Website	:	https://www.arcolinux.com
# Website	:	https://www.arcolinuxd.com
# Website	:	https://www.arcolinuxb.com
# Website	:	https://www.arcolinuxiso.com
# Website	:	https://www.arcolinuxforum.com
##################################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
##################################################################################################################
buildFolder="$HOME/arcolinuxb-build"
outFolder="$HOME/ArcoLinuxB-Out"
WorkFolder="$HOME/ArcoLinuxWork"

#Setting variables
#Let us change the name"
#First letter of desktop small

desktop="plasma-min"

#build.sh
oldname1="iso_name=arcolinux"
newname1="iso_name=arcolinuxb-$desktop"

oldname2='iso_label="arcolinux'
newname2='iso_label="alb-'$desktop

#os-release
oldname3='NAME="ArcoLinux"'
newname3='NAME=ArcoLinuxB-'$desktop

oldname4='ID=ArcoLinux'
newname4='ID=ArcoLinuxB-'$desktop

#lsb-release
oldname5='DISTRIB_ID=ArcoLinux'
newname5='DISTRIB_ID=ArcoLinuxB-'$desktop

oldname6='DISTRIB_DESCRIPTION="ArcoLinux"'
newname6='DISTRIB_DESCRIPTION=ArcoLinuxB-'$desktop

#hostname
oldname7='ArcoLinux'
newname7='ArcoLinuxB-'$desktop

#hosts
oldname8='ArcoLinux'
newname8='ArcoLinuxB-'$desktop

echo
echo "################################################################## "
tput setaf 2;echo "Phase 1 : clean up and download the latest ArcoLinux-iso from github";tput sgr0
echo "################################################################## "
echo
echo "Deleting the work folder if one exists"
[ -d $WorkFolder ] && rm -rf $WorkFolder
echo "Deleting the build folder if one exists - takes some time"
[ -d $buildFolder ] && sudo rm -rf $buildFolder
echo "Git cloning files and folder to work folder"
git clone https://github.com/arcolinux/arcolinux-iso.git $WorkFolder

echo
echo "################################################################## "
tput setaf 2;echo "Phase 2 : Getting the latest versions for some important files";tput sgr0
echo "################################################################## "
echo
echo "Removing the old files from work folder"
rm $WorkFolder/archiso/packages.x86_64
rm $WorkFolder/archiso/mkinitcpio.conf
rm $WorkFolder/archiso/pacman.conf
rm $WorkFolder/archiso/pacman.conf.work_dir
rm $WorkFolder/archiso/airootfs/root/customize_airootfs.sh
rm $WorkFolder/archiso/build.sh
echo "Copying the new files"
cp -f ../archiso/packages.x86_64 $WorkFolder/archiso/packages.x86_64
cp -f ../archiso/mkinitcpio.conf $WorkFolder/archiso/mkinitcpio.conf
cp -f ../archiso/pacman.conf $WorkFolder/archiso/pacman.conf
cp -f ../archiso/pacman.conf.work_dir $WorkFolder/archiso/pacman.conf.work_dir
cp -f ../archiso/airootfs/root/customize_airootfs.sh $WorkFolder/archiso/airootfs/root/customize_airootfs.sh
cp -f ../archiso/build.sh $WorkFolder/archiso/build.sh

echo "Removing old files/folders from /etc/skel"
rm -rf $WorkFolder/archiso/airootfs/etc/skel/.* 2> /dev/null

echo "getting .bashrc from arcolinux-root"
wget https://raw.githubusercontent.com/arcolinux/arcolinux-root/master/etc/skel/.bashrc-latest -O $WorkFolder/archiso/airootfs/etc/skel/.bashrc

echo
echo "################################################################## "
tput setaf 2;echo "Phase 3 : Renaming the ArcoLinux iso";tput sgr0
echo "################################################################## "
echo
echo "Renaming to "$newname1
echo "Renaming to "$newname2
echo
sed -i 's/'$oldname1'/'$newname1'/g' $WorkFolder/archiso/build.sh
sed -i 's/'$oldname2'/'$newname2'/g' $WorkFolder/archiso/build.sh
sed -i 's/'$oldname3'/'$newname3'/g' $WorkFolder/archiso/airootfs/etc/os-release
sed -i 's/'$oldname4'/'$newname4'/g' $WorkFolder/archiso/airootfs/etc/os-release
sed -i 's/'$oldname5'/'$newname5'/g' $WorkFolder/archiso/airootfs/etc/lsb-release
sed -i 's/'$oldname6'/'$newname6'/g' $WorkFolder/archiso/airootfs/etc/lsb-release
sed -i 's/'$oldname7'/'$newname7'/g' $WorkFolder/archiso/airootfs/etc/hostname
sed -i 's/'$oldname8'/'$newname8'/g' $WorkFolder/archiso/airootfs/etc/hosts

echo
echo "################################################################## "
tput setaf 2;echo "Phase 4 : Checking if archiso is installed";tput sgr0
echo "################################################################## "
echo

package="archiso"

#----------------------------------------------------------------------------------

#checking if application is already installed or else install with aur helpers
if pacman -Qi $package &> /dev/null; then

		echo "################################################################"
		echo "################## "$package" is already installed"
		echo "################################################################"

else

	#checking which helper is installed
	if pacman -Qi yay &> /dev/null; then

		echo "################################################################"
		echo "######### Installing with yay"
		echo "################################################################"
		yay -S --noconfirm $package

	elif pacman -Qi trizen &> /dev/null; then

		echo "################################################################"
		echo "######### Installing with trizen"
		echo "################################################################"
		trizen -S --noconfirm --needed --noedit $package

	fi

	# Just checking if installation was successful
	if pacman -Qi $package &> /dev/null; then

		echo "################################################################"
		echo "#########  "$package" has been installed"
		echo "################################################################"

	else

		echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		echo "!!!!!!!!!  "$package" has NOT been installed"
		echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		exit 1
	fi

fi

echo
echo "################################################################## "
tput setaf 2;echo "Phase 5 : Moving files to build folder";tput sgr0
echo "################################################################## "
echo

echo "Copying files and folder to build folder as root"
sudo mkdir $buildFolder
sudo cp -r $WorkFolder/* $buildFolder

sudo chmod 750 ~/arcolinuxb-build/archiso/airootfs/etc/sudoers.d
sudo chmod 750 ~/arcolinuxb-build/archiso/airootfs/etc/polkit-1/rules.d
sudo chgrp polkitd ~/arcolinuxb-build/archiso/airootfs/etc/polkit-1/rules.d

cd $buildFolder/archiso


echo
echo "################################################################## "
tput setaf 2;echo "Phase 6 : Cleaning the cache";tput sgr0
echo "################################################################## "
echo

#yes | sudo pacman -Scc

echo
echo "################################################################## "
tput setaf 2;echo "Phase 7 : Building the iso";tput sgr0
echo "################################################################## "
echo

sudo bash ./build.sh -v

echo
echo "################################################################## "
tput setaf 2;echo "Phase 8 : Moving the iso to out folder";tput sgr0
echo "################################################################## "
echo

[ -d $outFolder ] || mkdir $outFolder
cp $buildFolder/archiso/out/arcolinuxb* $outFolder

echo
echo "################################################################## "
tput setaf 2;echo "Phase 9 : Making sure we start with a clean slate next time";tput sgr0
echo "################################################################## "
echo
echo "Deleting the work folder if one exists - takes some time"
[ -d $WorkFolder ] && sudo rm -rf $WorkFolder
