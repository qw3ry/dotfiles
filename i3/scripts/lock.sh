#!/usr/bin/env bash

icon=$(dirname $0)"/lock-icon.png"
tmpbg='/tmp/screen.png'

(( $# )) && { icon=$1; }

scrot "$tmpbg"
convert "$tmpbg" -scale 5% -scale 2000% "$tmpbg"

if [[ -f $icon ]]
then
  # lockscreen image info
  iconRes=$(file $icon | grep -o '[0-9]* x [0-9]*')
  iconResX=$(echo $iconRes | cut -d' ' -f 1)
  iconResY=$(echo $iconRes | cut -d' ' -f 3)

  screenResolutions=$(xrandr --query | grep ' connected' | sed 's/primary //' | cut -f3 -d' ')
  for resolution in $screenResolutions
  do
    # monitor position/offset
    resolutionX=$(echo $resolution | cut -d'x' -f 1)                   # x pos
    resolutionY=$(echo $resolution | cut -d'x' -f 2 | cut -d'+' -f 1)  # y pos
    offsetX=$(echo $resolution | cut -d'x' -f 2 | cut -d'+' -f 2) # x offset
    offsetY=$(echo $resolution | cut -d'x' -f 2 | cut -d'+' -f 3) # y offset
    placementX=$(($offsetX + $resolutionX / 2 - $iconResX / 2))
    placementY=$(($offsetY + $resolutionY / 2 - $iconResY / 2))

    convert "$tmpbg" "$icon" -geometry +$placementX+$placementY -composite -matte "$tmpbg"
  done
fi
# dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Stop
# i3lock  -I 10 -d -e -u -n -i /tmp/screen.png
wrong1=ff000077
wrong2=ff000022
inside=00000040
black=000000ff
ring=cc990088
key=224400ff
back=aa0000aa

colorargs="--insidecolor=$inside --ringcolor=$ring --bshlcolor=$back --keyhlcolor=$key --linecolor=$black --ringvercolor=$inside --ringwrongcolor=$wrong1 --insidevercolor=$inside --insidewrongcolor=$wrong2"

i3lock -e -i "$tmpbg" -k --timesize 20 --datestr "%d.%m.%Y" --radius 250 --indicator --separatorcolor=$inside $colorargs

exit 0
