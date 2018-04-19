#!/bin/sh
STEP=5
ICON=/usr/share/icons/Adwaita/32x32/status/display-brightness-symbolic.symbolic.png

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
  brightness=$(echo "($(xbacklight) + 0.5)/1" | bc)
  bar=$(getbar $brightness)
  pad=$(getpadding $brightness)
  dunstify -i "$ICON" -t 2000 -r 2594 -u normal " $bar$pad$brightness%"
}

up(){
  xbacklight -inc $STEP
}

down(){
  xbacklight -dec $STEP
}

case $1 in
up)
  up
  notify;;
down)
  down
  notify;;
notify)
  notify;;
esac
