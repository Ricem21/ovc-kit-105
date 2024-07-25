#!/bin/bash

set -e
VERSION="2.0"
APP="omni.usd_explorer"

FAT_PACKAGE=$(find ../_build -name \*.zip)

cp $FAT_PACKAGE fat-pack.zip


sudo docker build --build-arg OVC_KIT=$APP.ovc.kit \
    --build-arg FAT_PACK=./fat-pack.zip . -t $APP:$VERSION
~

