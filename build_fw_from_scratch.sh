#!/bin/bash

echo $1
echo $2
echo $3
echo $4

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo $SCRIPT_DIR
cd $SCRIPT_DIR
git clone git@github.com:AnshulYbd/cam-fw-deb.git
cd ./cam-fw-deb
git pull origin main
source buildfw.sh $1 $2 $4

var=$3
if [ -z "$var" ]
then
      echo "$var is empty"
else
    echo "$var is not empty"
fi

CAMIP=$var
echo "Deployment camera IPAddress : $CAMIP"
command="-p bdstum01r21 scp -v -P 9031 $SCRIPT_DIR/cam-fw-deb/BirdDog_CAM_$1-$4.deb root@$CAMIP:/tmp"
#echo $command
sshpass $command 
echo "Copied to remote. $CAMIP"


echo "Finished."