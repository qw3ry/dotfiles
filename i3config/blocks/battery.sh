#!/bin/sh

function append_text {
	[[ -n $full_text ]] && delimiter=" - " || delimiter=""
	full_text="$full_text$delimiter<span foreground=\"$3\" background=\"$4\">$1 $2%</span>"
	short_text="$short_text$delimiter<span foreground=\"$3\" background=\"$4\">$1</span>"
}

function battery_status {
	num=$1
	acpi=$(acpi -b | grep "Battery $num:")
	percent=$(echo $acpi | cut -d' ' -f4 | cut -d'%' -f1)
	status=$(echo $acpi | cut -d' ' -f3 | cut -d',' -f1)
	bgr="#000"
	icon="dummy"
	color="#fff"
	case $status in
		Discharging)
			color="#FFF"
        	        icon=""
               		if [[ $percent -lt 20 ]]; then
                        	icon=""
                        	bgr="#900"
                	elif [[ $percent -lt 40 ]]; then
                	        icon=""
				color="#fa0"
                	elif [[ $percent -lt 60 ]]; then
				icon=""
				color="#ff7"
                	elif [[ $percent -lt 80 ]]; then
				icon=""
	                fi;
			;;
		Charging)
			icon=""
                	color="#0F0"
			;;
		Full|Unknown)
	                color="#af0"
                	icon=""
			;;
		*)
			icon="Status=$status"
			color="#000"
			bgr="#f11"
			;;
	esac
	append_text $icon $percent $color $bgr
}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
batteries="$(acpi -b | cut -d' ' -f2 | cut -d':' -f1)"
short_text=
full_text=

for bat in $batteries; do
	battery_status $bat
done;

echo "$full_text"
echo "$short_text"
