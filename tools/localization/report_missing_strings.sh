#!/bin/bash
SRCROOT=WunderLINQ

for lang in `ls -1 $SRCROOT/|grep .lproj|grep -v Base|cut -d'.' -f1`
do
	touch $lang.log

	echo "######## Missing strings in $lang.lproj/Localizable.strings ########" |tee -a $lang.log
	for key in `diff <(./tools/localization/strings-json.sh $SRCROOT/Base.lproj/Localizable.strings) <(./tools/localization/strings-json.sh $SRCROOT/$lang.lproj/Localizable.strings)|grep \< | cut -d' ' -f2`
	do
		grep $key WunderLINQ/Base.lproj/Localizable.strings|tee -a $lang.log
	done

	echo "######## Missing strings in $lang.lproj/InfoPlist.strings ########" |tee -a $lang.log
        for key in `diff <(./tools/localization/strings-json.sh $SRCROOT/Base.lproj/InfoPlist.strings) <(./tools/localization/strings-json.sh $SRCROOT/$lang.lproj/InfoPlist.strings)|grep \< | cut -d' ' -f2`
        do
             grep $key WunderLINQ/Base.lproj/InfoPlist.strings|tee -a $lang.log
        done

	for file in `ls -1 WunderLINQ/InAppSettings.bundle/en.lproj/*.strings | cut -d'/' -f4`
	do
        	echo "######## Missing strings in $lang.lproj/$file ########" |tee -a $lang.log
        	for key in `diff <(./tools/localization/strings-json.sh $SRCROOT/InAppSettings.bundle/en.lproj/$file) <(./tools/localization/strings-json.sh $SRCROOT/InAppSettings.bundle/$lang.lproj/$file)|grep \< | cut -d' ' -f2`
        	do
                	grep $key WunderLINQ/InAppSettings.bundle/en.lproj/$file|tee -a $lang.log
        	done
	done
done
