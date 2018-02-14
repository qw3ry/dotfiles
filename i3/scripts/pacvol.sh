#!/bin/sh
# PulseAudio Volume Control Script
#   2010-05-20 - Gary Hetzel <garyhetzel@gmail.com>
#
#   BUG:    Currently doesn't get information for the specified sink,
#           but rather just uses the first sink it finds in list-sinks
#           Need to fix this for systems with multiple sinks
#

SINK=0
STEP=3
MAXVOL=65537 # let's just assume this is the same all over
MUTED=0
#MAXVOL=`pacmd list-sinks | grep "volume steps" | cut -d: -f2 | tr -d "[:space:]"`

MUTED=`pacmd list-sinks 0 | grep muted | cut -d ' ' -f 2`
#VOLPERC=`pactl list sinks | awk '/Volume: 0:/ {print substr($3, 1, index($3, "%") - 1)}' | head -n1`
VOLPERC=`pactl list sinks | awk '/Volume: front-left:/ {print substr($5, 1, index($5, "%") - 1)}'`
SKIPOVERCHECK=

repeat_n_times(){
  val=$(seq -s "$1" $(($2+1)) | sed 's/[0-9]//g')
  echo "${val}"
}

getbar(){
  width=25
  bar_size=$((($width * $1)/100))
  bar=$(repeat_n_times "─" $bar_size)
  space=$(repeat_n_times " " $((width - $bar_size)))
  echo "$bar$space"
}

geticon(){
  if [ "$1" = "yes" ]; then
    echo "/usr/share/icons/Adwaita/64x64/status/audio-volume-muted-symbolic.symbolic.png"
  elif [ "$2" -lt 33 ]; then
    echo "/usr/share/icons/Adwaita/64x64/status/audio-volume-low-symbolic.symbolic.png"
  elif [ "$2" -lt 66 ]; then
    echo "/usr/share/icons/Adwaita/64x64/status/audio-volume-medium-symbolic.symbolic.png"
  else
    echo "/usr/share/icons/Adwaita/64x64/status/audio-volume-high-symbolic.symbolic.png"
  fi
}

getpadding(){
  if [ "$1" -lt 10 ]; then
    echo "   "
  elif [ "$1" -lt 100 ]; then
    echo "  "
  else
    echo " "
  fi
}

notify(){
  bar=$(getbar $1)
  icon=$(geticon $2 $1)
  pad=$(getpadding $1)
  dunstify -i "$icon" -t 2000 -r 2593 -u normal " $bar$pad$1%"
}

display(){
  if [ "$MUTED" = "yes" ]; then
    echo " ${VOLPERC}%"
  elif [ "$VOLPERC" -lt 33 ]; then
    echo " ${VOLPERC}%"
  elif [ "$VOLPERC" -lt 66 ]; then
    echo " ${VOLPERC}%"
  else
    echo " ${VOLPERC}%"
  fi
}

up(){
	VOLSTEP="$(( $VOLPERC+$STEP ))";
}

down(){
	VOLSTEP="$(( $VOLPERC-$STEP ))";
	SKIPOVERCHECK=1
}

max(){
	pacmd set-sink-volume $SINK $MAXVOL > /dev/null
}

min(){
	pacmd set-sink-volume $SINK 0 > /dev/null
}

overmax(){
	SKIPOVERCHECK=1
	if [ $VOLPERC -lt 100 ]; then
		max;
		exit 0;
	fi
	up
}

mute(){
	pacmd set-sink-mute $SINK 1 > /dev/null
  notify $VOLPERC "yes"
}

unmute(){
	pacmd set-sink-mute $SINK 0 > /dev/null
  notify $VOLPERC "no"
}

toggle(){
	M=`pacmd list-sinks | grep "muted" | cut -d: -f2 | tr -d "[:space:]"`
	if [ $M == "no" ]; then
		mute;
	else
		unmute;
	fi
}

case "$BLOCK_BUTTON" in
  1|2|3)
	# get the current mouse position
	pavucontrol &
  echo "T"
esac

case $1 in
up)
	up;;
down)
	down;;
max)
	max
  notify 100 $MUTED
	exit 0;;
min)
	min
  notify 0 $MUTED
	exit 0;;
overmax)
	overmax;;
toggle)
	toggle
	exit 0;;
mute)
	mute;
	exit 0;;
unmute)
	unmute;
	exit 0;;
display)
	display;
	exit 0;;
notify)
  notify $VOLPERC $MUTED
  exit 0;;
*)
	echo "Usage: `basename $0` [up|down|min|max|overmax|toggle|mute|unmute|display]"
	exit 1;;
esac

VOLUME="$(( ($MAXVOL/100) * $VOLSTEP ))"

echo "$VOLUME : $OVERMAX"

 if [ -z $SKIPOVERCHECK ]; then
 	if [ $VOLUME -gt $MAXVOL ]; then
 		VOLUME=$MAXVOL
 	elif [ $VOLUME -lt 0 ]; then
 		VOLUME=0
 	fi
 fi

#echo "$VOLUME: $MAXVOL/100 * $VOLPERC+$VOLSTEP"
pacmd set-sink-volume $SINK $VOLUME > /dev/null
# VOLPERC=`pacmd list-sinks | grep "volume" | head -n1 | cut -d: -f3 | cut -d% -f1 | tr -d "[:space:]"`
$($0 notify)
#osd_cat -b percentage -P $VOLPERC --delay=1 --align=center --pos bottom --offset 50 --color=green&
