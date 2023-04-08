#!/bin/bash

if (( $# == 0 )); then
    echo "Usage: script.sh gophermapfile"
    exit 1
fi

# Articles directory
DIRECTORY="phlog/"

# Last line before articles list in gophermap
PREFIX="i...\tErr\t1\t1" 

# 1st row, 7th and 6th column of ls *.txt
newarticle="$(ls -alt --time-style +%Y-%m-%d $DIRECTORY*.txt | awk 'NR==1{print $7}')"
newdate="$(ls -alt --time-style +%Y-%m-%d $DIRECTORY*.txt | awk 'NR==1{print $6}')"
newtitle="$(cat $newarticle | head -n 1)"

# Remove subdirectory from path
newarticle="$(echo $newarticle | sed "s|$DIRECTORY||")"

newline="0$newdate - $newtitle\t$newarticle"

# Insert a new line after PREFIX in gophermapfile
sed -i "/$PREFIX/a $newline" "$1"
