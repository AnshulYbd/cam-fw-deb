#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo $SCRIPT_DIR
cd $SCRIPT_DIR


echo $3
VAR=$3
if [ -n "$VAR" ]; then
  command="-p bdstum01r21 scp -v -P 9031 $SCRIPT_DIR/cam-fw-deb/BirdDog_CAM_$1.deb root@$VAR:/tmp"
  echo $command
  sshpass $command 
  echo "Copied to remote."

fi

echo "Finished."