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
	icon=""
	color="#0F0"
	bgr="#000"
	if [[ $status == 'Discharging' ]]; then
		color="#FFF"
		if [[ $percent < 20 ]]; then
			icon=""
			bgr="#900"
		elif [[ $percent < 40 ]]; then
			icon =""
		else
			icon =""
		fi;
	elif [[ $status == 'Full' ]]; then
		color="#af0"
		icon=""
	fi;
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
