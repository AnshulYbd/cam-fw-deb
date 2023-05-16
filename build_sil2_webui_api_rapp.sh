#!/bin/bash
if [ $# -eq 0 ]
  then
    echo "No arguments supplied. version number needed"
    exit
fi

#!/bin/bash
#only need to modify revision mumber in this single line
BIRDDOG_FIRMWARE_VERSION_NUM=$1 
#Update PWD
HELP_INFO_PRINTED="false";
set -e

echo "
## make sure we have checked in all required paramaters!
## e.g. the command can be:
## ./birddog-generate-update.sh sil2 webui api rapp finder comms
## sil2:    enable sil2 features 
## webui:	WebUI
## api:  	RESTAPI
## rapp:	Linux main app
## finder:	individual NDI source finder app
## comms:	individual Comms embedded apps
## we can leave any parameter empty if we don't need to update the corresponding component.
"
for var in "$@"
do  
	echo "Script argument contains $var"
	if 	[ $var == "help" ] 	|| \
		[ $var == "-help" ] || \
		[ $var == "h" ] 	|| \
		[ $var == "-h" ]; then
		HELP_INFO_PRINTED=true
		break
	fi
done	  

if [ "true" == $HELP_INFO_PRINTED ]; then
	echo "please recheck the command information, exited without changing anything"
	exit 
fi

WORK_DIR=`pwd`
echo "Our working directory is $WORK_DIR"

#Check If Production
for var in "$@"
do  
	if [ "prd" = "$var" ] ; then
		exit 0
		break								
	fi							
done	

#Check If LTS generation
gen_lts_fw=false
for var in "$@"
do  
	if [ "lts" = "$var" ] ; then
		gen_lts_fw=true
		break								
	fi							
done
rm -rf $WORK_DIR/MCU-Update/*		
if [ "$gen_lts_fw" = true ] ; then
    cp -rf $WORK_DIR/../MCU-FWs/LTS/* $WORK_DIR/MCU-Update
else
    cp -rf $WORK_DIR/../MCU-FWs/NEW/* $WORK_DIR/MCU-Update
fi

#Check If update WebUI
for var in "$@"
do  
	if [ "webui" = "$var" ] ; then
		echo "update latest webUI"
		cp -rf ../../New_WEBUI/WEB_UI/birddog-web-ui/* 													./BirdDog_CAM_FW/birddog-platform-files/srv/birddog-web-ui/
		cp -rf ../../New_WEBUI/WEB_UI/cmd_32/birddog-web-ui/birddog-web-ui 								        ./BirdDog_CAM_FW/birddog-platform-files/bin/
		cp -rf ../../New_WEBUI/WEB_UI/etc/*												./BirdDog_CAM_FW/birddog-platform-files/etc/


		break								
	fi							
done							
#Check If update RESTAPI							
for var in "$@"							
do  							
	if [ "api" = "$var" ] ; then							
		echo "update latest api"							
		cp -rf ../../New_WEBUI/API_SERVER/BirdDogSrvr/* 												./BirdDog_CAM_FW/birddog-platform-files/bin/BirdDogSrvr/
		break
	fi
done
#Update Finder
for var in "$@"
do  
	if [ "finder" = "$var" ] ; then
		echo "update latest finder"
		cp -rf ../../NDISrcFinder/sdk_2016_4/ndi_src_find_app/ndi_src_find_app/Debug/ndi_src_find_app 	./BirdDog_CAM_FW/birddog-platform-files/bin/
		cp -rf ../../NDISrcFinder/rootfs/bin/* 															./BirdDog_CAM_FW/birddog-platform-files/bin/
		cp -rf ../../NDISrcFinder/rootfs/etc/* 															./BirdDog_CAM_FW/birddog-platform-files/etc/
		break
	fi
done
#Update Comms Return App
for var in "$@"
do  
	if [ "commsret" = "$var" ] ; then
		echo "update latest commsret"
		cp -rf ../../bdg_headset_speaker/Debug/bdg_headset_speaker 										./BirdDog_CAM_FW/birddog-platform-files/bin/
		break
	fi
done
#Update Debug Main App
for var in "$@"
do  
	if [ "dapp" = "$var" ] ; then
		echo "update latest Debug Linus App"										
		cp ../CamApp/CamApp/Debug/CamApp 																./BirdDog_CAM_FW/birddog-platform-files/bin/ 
		break
	fi
done
	
#Update Debug Main App
for var in "$@"
do  
	if [ "rapp" = "$var" ] ; then
		echo "update latest Release Linus App"										
		cp ../CamApp/CamApp/Release/CamApp 																./BirdDog_CAM_FW/birddog-platform-files/bin/ 
		break
	fi
done	

#Update Sil2 config file
echo '{"Silicon2":"false","Srt":"false","Hx":"false","Rtsp":"false","Rtmp":"false","Disable":"false","Dante":"false","IsInterlaceModeSupported": false, "ScreenSaverRawH264Path": "/etc/ndi_screen_saver_h264_raw_iframe.h264"}' > ./BirdDog_CAM_FW/birddog-platform-files/etc/Config.json
for var in "$@"
do  
	if [ "sil2" = "$var" ] ; then
		echo "update Sil2 config file to TRUE"										
		echo '{"Silicon2":"true","Srt":"true","Hx":"true","Rtsp":"true","Rtmp":"true","Disable":"true","Dante":"false","IsInterlaceModeSupported": false, "ScreenSaverRawH264Path": "/etc/ndi_screen_saver_h264_raw_iframe.h264"}' > ./BirdDog_CAM_FW/birddog-platform-files/etc/Config.json
		break
	fi
done

##rm -rf *.fw
rm -rf *.zip
rm -rf ProFW
rm -rf ./BirdDog_CAM_FW/birddog-platform-files/etc/MCU-Update		
rm -rf ./BirdDog_CAM_FW/birddog-platform-files/etc/birddog-hardware-version
rm -rf tmp
cp -rf ./MCU-Update ./BirdDog_CAM_FW/birddog-platform-files/etc/MCU-Update	

#Change Dir to BirdDog_FW
cd $WORK_DIR/BirdDog_CAM_FW
echo -n "$BIRDDOG_FIRMWARE_VERSION_NUM" > 																./birddog-platform-files/etc/birddog-firmware-version-common

tar -zcf bdup.fw birddog-platform-files/* external/* z7020/* z7030/* bdup.sh CleanUser.sh.x CheckMCUVersion.sh && openssl enc -e -aes256 -k kjlhsdfkn9873948579345kjhiskjdf98734jhf9834h9f -in bdup.fw -out bdpff && rm bdup.fw
tar -zcf ../"BirdDog_CAM_$BIRDDOG_FIRMWARE_VERSION_NUM.fw" bdpff birddog-update.sh update GetMCUVersion
rm bdpff
echo "BirdDog firmware revision $BIRDDOG_FIRMWARE_VERSION_NUM is generated successfully for BirdDog CAM"

#Gen Production FW
for var in "$@"
do  
	if [ "pro" = "$var" ] ; then
		cd $WORK_DIR/BirdDog_CAM_FW
		echo "Gen Production FW"
		DIR="../ProFW"
		if [ ! -d "$DIR" ]; then
			mkdir ../ProFW
		fi
			while read line; do 
				echo $line  > tmp
				tr -d '\r\n' < tmp > ./birddog-platform-files/etc/birddog-hardware-version	
				BOARD_CODED_HW_DIR="./birddog-platform-files/etc/birddog-hardware-version"
				BOARD_CODED_HW=`cat ${BOARD_CODED_HW_DIR}`
				tar -zcf bdup.fw birddog-platform-files/* external/* z7020/* z7030/* bdup.sh CleanUser.sh.x CheckMCUVersion.sh && openssl enc -e -aes256 -k kjlhsdfkn9873948579345kjhiskjdf98734jhf9834h9f -in bdup.fw -out bdpff && rm bdup.fw
				tar -zcf ../ProFW/"$BOARD_CODED_HW $BIRDDOG_FIRMWARE_VERSION_NUM.fw" bdpff birddog-update.sh update GetMCUVersion
				echo "BirdDog Gen Production FW for $line"
				rm -rf ./birddog-platform-files/etc/birddog-hardware-version
				rm bdpff
			done < ../HWID.txt
		break
	fi
done	

rm -rf ./birddog-platform-files/etc/birddog-hardware-version
rm -rf tmp

#Gen CameraFirmwarePackag
for var in "$@"
do  
	if [ "exp" = "$var" ] ; then
		echo "Gen CameraFirmwarePackag"	
		cd $WORK_DIR	
			DIR="ProFW"
			if [ -d "$DIR" ]; then
				echo "CameraFirmwarePackag With PRO"
				tar -zcf "CameraFirmwarePackage_$BIRDDOG_FIRMWARE_VERSION_NUM.zip" "BirdDog_CAM_$BIRDDOG_FIRMWARE_VERSION_NUM.fw" HiSil/* MCU-Update/* ProFW/* ReleaseNotes.txt
			else
				echo "CameraFirmwarePackag Without PRO"
				tar -zcf "CameraFirmwarePackage_$BIRDDOG_FIRMWARE_VERSION_NUM.zip" "BirdDog_CAM_$BIRDDOG_FIRMWARE_VERSION_NUM.fw" HiSil/* MCU-Update/* ReleaseNotes.txt
			fi
		break
	fi
done