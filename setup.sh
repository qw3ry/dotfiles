#!/bin/bash

HOME_DIR=$(cd ~; pwd)
REPO_DIR="$(dirname "$(readlink -f $0)")"

mkdir -p $HOME_DIR/.config/dunst
mv $HOME_DIR/.config/dunst/dunstrc $HOME_DIR/.config/dunst/dunstrc.bak
ln -s "$REPO_DIR/dunstrc" $HOME_DIR/.config/dunst/dunstrc

mv $HOME_DIR/.config/i3 $HOME_DIR/.config/i3.bak
ln -s "$REPO_DIR/i3config" $HOME_DIR/.config/i3

