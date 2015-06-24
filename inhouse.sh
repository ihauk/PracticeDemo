#!/bin/bash

WORKSPACE="SelfieDemo.xcodeproj"
SCHEME="SelfDemo"

MIX_INFO="MIX/Misc/Info.plist"

CERTIFICATE="iPhone Distribution: Chengdu Pinguo Technology Co., Ltd."

echo '修改 Bundle Identifier'
#/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.pinguo.inhouse.mix" $MIX_INFO

echo '打包'
xcodebuild -project $WORKSPACE -scheme $SCHEME -configuration Debug -sdk iphoneos clean build CODE_SIGN_IDENTITY="$CERTIFICATE" PROVISIONING_PROFILE="" GCC_PREPROCESSOR_DEFINITIONS='$(inherited) INHOUSE=1'

#if [ $? != 0 ]
#then
#    exit $?
#fi
#
#xcrun -sdk iphoneos PackageApplication -v $1 -o $2
#
#if [ $? != 0 ]
#then
#    exit $?
#fi
#
#echo '恢复 Bundle Identifier'
#/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.vstudio.MIX" $MIX_INFO
