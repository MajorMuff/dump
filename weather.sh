#!/bin/bash

# weather script for https://github.com/Alexays/Waybar/discussions/2255

# Display options for the location name and icon
showWeatherLocation=true
showWeatherIcon=true

# We want to store the currently selected location somewhere. If this file doesn't exist we create it. Using the tmp dir ensures the location is reset to the default on reboot
tmpFile=/tmp/weather.tmp
[[ ! -f $tmpFile ]] &&  echo 0 > $tmpFile

function weather {
	local locations arrLocations currLocationId currLocationName currWeather weatherStr

	locations="New York, London, Amsterdam, Sydney" # Comma separated so we can use location names with spaces
 
	IFS="," read -r -a arrLocations <<< "$(echo "$locations" | sed -E 's/,  */,/g' | sed -E 's/ /_/g')" # Replace spaces in location names with underscores for curl. Get rid of spaces after commas
	
	currLocationId=$(<$tmpFile)

	if [ "$1" = "--next" ]; then # Running script with --next option increments location ID and shows next in line. Revert to first at end of cities array
		((currLocationId=currLocationId+1))
		if [ $currLocationId -ge ${#arrLocations[@]} ]; then
			currLocationId=0
		fi
		echo $currLocationId > $tmpFile
	fi

	weatherStr=""

	currLocationName="${arrLocations[currLocationId]}"
	currWeather=$(curl -s "https://wttr.in/$currLocationName?format=1")

	if [ "$showWeatherLocation" = true ]; then
		currLocationName="${arrLocations[currLocationId]//_/ }"
		weatherStr+=$(echo "$currLocationName: " | sed 's/_/ /g')
	fi

	weatherStr+=$(echo "$currWeather" | awk '{print $2}')

	if [ "$showWeatherIcon" = true ]; then
		weatherStr+=$(echo "$currWeather" | awk '{print " " $1}')
	fi
	
	printf "%s" "$weatherStr"
	
}

weather "$@"
