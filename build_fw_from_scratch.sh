#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo $SCRIPT_DIR
cd $SCRIPT_DIR

git clone git@github.com:AnshulYbd/cam-fw-deb.git
cd ./cam-fw-deb
git pull origin main
cd cam-fw-deb
source buildfw.sh $1 $2
echo "Finished."
cd $SCRIPT_DIR