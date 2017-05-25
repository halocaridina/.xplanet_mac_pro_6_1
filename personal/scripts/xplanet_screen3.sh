#!/bin/bash

SWITCH=$1

################################################################################
# DEFINITIONS
################################################################################
source /Users/srsantos/.xplanet/personal/definitions2
################################################################################

################################################################################
# PRINT COMMAND LINE SWITCHES
################################################################################
if [[ ${SWITCH} == 'help' ]]; then
	echo "Options for this script:"
	echo "  'start'	- starts Xplanet in fork mode"
	echo "  'stop'	- stops all running instances of XPlanet"
	echo "  'earth'	- updates the monthly Earth map"
	echo "  'clouds'	- updates the cloud map"
	echo "  'quake'	- updates the quake marker"
	echo "  'iss' - updates the satellites marker"
	echo "  'storm'	- updates the storm marker"
	echo "  'volcano'	- updates the volcano marker"
	echo "  'label'	- downloads TotalMarker's label in case required to debug"
	echo "		    and also creates a custom label marker"
	echo "  'help'	- prints out this list"
	echo ""
fi
################################################################################

################################################################################
# START XPLANET
################################################################################
#if [[ ${SWITCH} == 'start' ]]; then
#	/usr/local/bin/xplanet \
#		-searchdir=${XPLANET_HOME} \
#		-config=config \
#		-projection=${XPLANET_PROJECTION} \
#		-longitude=${XPLANET_LONGITUDE} \
#		-labelpos=+5-5 \
#		-date_format="%D at %r" \
#		-color=green2 \
#		-fork \
#		-font=/Users/srsantos/Library/Fonts/PragmataPro.ttf \
#		-fontsize=13 \
#		-background=stars.jpg
#	echo "$(date): Xplanet Started"
#fi
################################################################################

################################################################################
# START XPLANET (ALTERNATIVE WITH ISS CENTERED)
################################################################################
if [[ ${SWITCH} == 'start' ]]; then
SCREEN=$2
SCREEN_TEMP=XPLANET_GEOMETRY${SCREEN}
SCREEN_GEO=${!SCREEN_TEMP}
OUTPUT=Screen${SCREEN}-${SCREEN_GEO}-$(date +"%Y%m%d.%H.%M.%S").png
	/usr/local/bin/xplanet \
		-searchdir=${XPLANET_HOME} \
		-config=config_screen_jupiter \
		-labelpos=-5-5 \
		-date_format="%D at %r" \
		-color=green2 \
		-font=/Users/srsantos/Library/Fonts/PragmataPro.ttf \
		-fontsize=13 \
		-geometry=${SCREEN_GEO} \
		-body europa \
		-longitude 180 \
		-radius 3 \
		-center +450+350 \
		-output=/Users/srsantos/.xplanet/personal/output/display${SCREEN}-${SCREEN_GEO}/${OUTPUT} \
		-num_times=1 

	find /Users/srsantos/.xplanet/personal/output/display${SCREEN}-${SCREEN_GEO}/ -mtime +1h -delete
	rm ~/Pictures/XplanetDesktop${SCREEN}/*.png
	ln -s /Users/srsantos/.xplanet/personal/output/display${SCREEN}-${SCREEN_GEO}/${OUTPUT} ~/Pictures/XplanetDesktop${SCREEN}/${OUTPUT}

	echo "$(date): Xplanet ran for display ${SCREEN}"
fi

################################################################################
# STOP XPLANET
################################################################################
if [[ ${SWITCH} == 'stop' ]]; then
	kill $(ps aux | grep '[x]planet' | awk '{print $2}')
	echo "$(date): Xplanet Stopped"
fi
################################################################################

################################################################################
# UPDATE EARTH LAND MAP
################################################################################
if [[ ${SWITCH} == 'earth' ]]; then
	MONTH=$(date +%m)
	LAND_FILE="${EARTH_MAP_PRE}.2004$MONTH.3x21600x10800.jpg" && sleep 60
	unlink ${XPLANET_HOME}/images/earth.jpg
	ln -s ${XPLANET_PERSONAL}/images/$LAND_FILE ${XPLANET_HOME}/images/earth.jpg
	echo "$(date): Earth Map Updated"
fi
################################################################################

################################################################################
# GET LATEST CLOUD MAP
################################################################################
if [[ ${SWITCH} == 'clouds' ]]; then
	REMOTEFILE=${CLOUD_MAP}
#	TEMP="-u ${CLOUD_USER}:${CLOUD_PWD} -z ${XPLANET_TEMP}/${REMOTEFILE}.old -R -o ${XPLANET_TEMP}/${REMOTEFILE} ${CLOUD_URL}/${REMOTEFILE}"
# for redirected cloud images, add the "-L" option to curl switched
	TEMP="-z ${XPLANET_TEMP}/${REMOTEFILE}.old -R -L -o ${XPLANET_TEMP}/${REMOTEFILE} ${CLOUD_URL}/${REMOTEFILE}" && sleep 60
	curl $TEMP
	if [[ -a ${XPLANET_TEMP}/${REMOTEFILE} ]]; then
		cp ${XPLANET_TEMP}/${REMOTEFILE} ${XPLANET_HOME}/images/${REMOTEFILE}
		mv ${XPLANET_TEMP}/${REMOTEFILE} ${XPLANET_TEMP}/${REMOTEFILE}.old
		echo "$(date): Cloud Map Updated"
	else
		echo "$(date): Cloud Map Not Downloaded"
	fi
fi
################################################################################

################################################################################
# GET UPDATED MARKERS FROM TOTALMARKER
################################################################################
if [[ ${SWITCH} == 'quake' ]]; then
	REMOTEFILE="quake"
	TEMP="-z ${XPLANET_TEMP}/${REMOTEFILE}.old -R -o ${XPLANET_TEMP}/${REMOTEFILE} ${TOTALMARKER_URL}/${REMOTEFILE}" && sleep 60
	curl $TEMP
	if [[ -a ${XPLANET_TEMP}/${REMOTEFILE} ]]; then
		${SCRIPT_QUAKE} ${QUAKE_MIN} ${XPLANET_TEMP}/${REMOTEFILE} ${XPLANET_HOME}/markers/${REMOTEFILE}
		mv ${XPLANET_TEMP}/${REMOTEFILE} ${XPLANET_TEMP}/${REMOTEFILE}.old
		echo "$(date): Quake Marker Updated"
	else
		echo "$(date): Quake Marker Not Downloaded"
	fi
fi

if [[ ${SWITCH} == 'iss' ]]; then
	REMOTEFILE="iss.tle"
	TEMP="-z ${XPLANET_TEMP}/${REMOTEFILE}.old -R -o ${XPLANET_TEMP}/${REMOTEFILE} ${TOTALMARKER_URL}/${REMOTEFILE}" && sleep 60
	curl $TEMP
	if [[ -a ${XPLANET_TEMP}/${REMOTEFILE} ]]; then
		cp ${XPLANET_TEMP}/${REMOTEFILE} ${XPLANET_HOME}/satellites/${REMOTEFILE}
		mv ${XPLANET_TEMP}/${REMOTEFILE} ${XPLANET_TEMP}/${REMOTEFILE}.old
		echo "$(date): ISS Marker Updated"
	else
		echo "$(date): ISS Marker Not Downloaded"
	fi
fi

if [[ ${SWITCH} == 'storm' ]]; then
	REMOTEFILE="storm"
	TEMP="-z ${XPLANET_TEMP}/${REMOTEFILE}.old -R -o ${XPLANET_TEMP}/${REMOTEFILE} ${TOTALMARKER_URL}/${REMOTEFILE}" && sleep 60
	curl $TEMP
	if [[ -a ${XPLANET_TEMP}/${REMOTEFILE} ]]; then
		curl -R -o ${XPLANET_HOME}/arcs/${REMOTEFILE} ${TOTALMARKER_URL}/arcs/${REMOTEFILE}
		cp ${XPLANET_TEMP}/${REMOTEFILE} ${XPLANET_HOME}/markers/${REMOTEFILE}
		mv ${XPLANET_TEMP}/${REMOTEFILE} ${XPLANET_TEMP}/${REMOTEFILE}.old
		echo "$(date): Storm Marker Updated"
	else
		echo "$(date): Storm Marker Not Downloaded"
	fi
fi

if [[ ${SWITCH} == 'volcano' ]]; then
	REMOTEFILE="volcano"
	TEMP="-z ${XPLANET_TEMP}/${REMOTEFILE}.old -R -o ${XPLANET_TEMP}/${REMOTEFILE} ${TOTALMARKER_URL}/${REMOTEFILE}" && sleep 60
	curl $TEMP
	if [[ -a ${XPLANET_TEMP}/${REMOTEFILE} ]]; then
		cp ${XPLANET_TEMP}/${REMOTEFILE} ${XPLANET_HOME}/markers/${REMOTEFILE}
		mv ${XPLANET_TEMP}/${REMOTEFILE} ${XPLANET_TEMP}/${REMOTEFILE}.old
		echo "$(date): Volcano Marker Updated"
	else
		echo "$(date): Volcano Marker Not Downloaded"
	fi
fi

if [[ ${SWITCH} == 'label' ]]; then
	REMOTEFILE="updatelabel"
	TEMP="-z ${XPLANET_TEMP}/${REMOTEFILE}.old -R -o ${XPLANET_TEMP}/${REMOTEFILE} ${TOTALMARKER_URL}/${REMOTEFILE}"
	curl $TEMP
	if [[ -a ${XPLANET_TEMP}/${REMOTEFILE} ]]; then
		cp ${XPLANET_TEMP}/${REMOTEFILE} ${XPLANET_HOME}/markers/${REMOTEFILE}
		mv ${XPLANET_TEMP}/${REMOTEFILE} ${XPLANET_TEMP}/${REMOTEFILE}.old
		echo "$(date): Label Marker Updated"
	else
		echo "$(date): Label Marker Not Downloaded"
	fi

	# UPDATE PERSONAL LABELS
	${SCRIPT_LABEL} ${XPLANET_HOME}/ ${XPLANET_TEMP}/ label ${CLOUD_MAP} quake storm volcano
fi
################################################################################
