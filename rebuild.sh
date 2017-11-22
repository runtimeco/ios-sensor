#!/bin/sh

cd ios-sensor/iotivity
ln -s out/ios ios
tools/darwin/build-ios.sh
tools/darwin/mkfwk_ios.sh 
