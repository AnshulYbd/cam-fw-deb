#!/bin/bash
if [ $# -eq 0 ]
  then
    echo "No arguments supplied. version number needed"
    exit
fi

Version=$1

PROJECT_ROOT=`pwd`
#echo $PROJECT_ROOT
CAM_ROOT=$PROJECT_ROOT/FW_APP_CAM
CAM_FW_ROOT=$CAM_ROOT/firmware
DEB_ROOT_PATH=$CAM_FW_ROOT/BirdDog_CAM_FW
BIRDDOG_PLATFORM_FILES_PATH=$DEB_ROOT_PATH/birddog-platform-files
DEB_SOURCE_PATH=$PROJECT_ROOT/BirdDog_CAM_$Version
DPKG_SCRIPT_PATH=$DEB_SOURCE_PATH/DEBIAN

#echo $DEB_SOURCE_PATH
echo "cloning gits $CAM_FW_ROOT  "

git clone git@github.com:BirdDog-Australia/FW_APP_CAM.git --branch main 
cd $CAM_ROOT && git pull origin main && cd -
#echo `pwd`
git clone git@github.com:BirdDog-Australia/New_WEBUI.git --branch NDI-5 && git pull
cd $PROJECT_ROOT/New_WEBUI && git pull origin NDI-5 && cd -

echo "cloned all repositories"
#Edit version info

cp $PROJECT_ROOT/build_sil2_webui_api_rapp.sh $CAM_FW_ROOT
cd $CAM_FW_ROOT  
#echo `pwd`

source build_sil2_webui_api_rapp.sh $Version sil2 webui api rapp


mv $CAM_FW_ROOT/BirdDog_CAM_$Version.fw $PROJECT_ROOT

echo "Done building firmware at $PROJECT_ROOT/BirdDog_CAM_$Version.fw"

if [ $2 == "dpkgon" ];then
    echo "Building debian package is ON"
    #run build_sil2_webui_api_rapp.sh $Version sil2 webui api rapp
    #To create debian package
    #copy all $\BirdDog_CAM_FW\birddog-platform-files
    
    mkdir -p $DEB_SOURCE_PATH && cp -rf $BIRDDOG_PLATFORM_FILES_PATH/* $_
    cp -r $PROJECT_ROOT/DEBIAN $DEB_SOURCE_PATH
    echo "Preparing  debian file system."
    echo "Package: BirdDog-Firmware" > $DEB_SOURCE_PATH/DEBIAN/control
    echo "Version: $Version" >>$DEB_SOURCE_PATH/DEBIAN/control
    echo "Section: frimware" >>$DEB_SOURCE_PATH/DEBIAN/control
    echo "Priority: optional" >>$DEB_SOURCE_PATH/DEBIAN/control
    echo "Architecture: armhf" >>$DEB_SOURCE_PATH/DEBIAN/control
    echo "Maintainer: Anshul Yadav (anshuly@birddog.tv)" >>$DEB_SOURCE_PATH/DEBIAN/control
    echo "Description: This is Bird dog camera firmware." >>$DEB_SOURCE_PATH/DEBIAN/control    
       
    #create and copy all temp mcu bin and etc
    mkdir -p $DEB_SOURCE_PATH/tmp && cp -f $DEB_ROOT_PATH/external/* $_
    
    cd $DEB_ROOT_PATH
    chmod 0755 $DPKG_SCRIPT_PATH/preinst
    chmod 0755 $DPKG_SCRIPT_PATH/postinst
    chmod 0755 $DPKG_SCRIPT_PATH/control
    
    dpkg-deb --build $DEB_SOURCE_PATH
    
    echo "Done building  debian-package at $DEB_SOURCE_PATH.deb"
    rm -rf $DEB_SOURCE_PATH
fi

echo "Finished all successfully"


