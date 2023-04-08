#!/bin/bash

if (( $# == 0 )); then
    echo "Usage: script.sh gophermapfile"
    exit 1
fi

# Articles directory
DIRECTORY="phlog/"

# Start of line before last article in gophermap
PREFIX="Last entry: "

# 1st row, 7th and 6th column of ls
newarticle="$(ls -alt --time-style +%Y-%m-%d $DIRECTORY*.txt | awk 'NR==1{print $7}')"
newdate="$(ls -alt --time-style +%Y-%m-%d $DIRECTORY*.txt | awk 'NR==1{print $6}')"

# 2nd row, 7th and 6th column of ls
oldarticle="$(ls -alt --time-style +%Y-%m-%d $DIRECTORY*.txt | awk 'NR==2{print $7}')"
olddate="$(ls -alt --time-style +%Y-%m-%d $DIRECTORY*.txt | awk 'NR==2{print $6}')"

# Replace filename, and date of last entry in gophermapfile
sed -i "s|$oldarticle|$newarticle|" "$1"
sed -i "s/$PREFIX$olddate/$PREFIX$newdate/" "$1"

newtitle="$(cat $newarticle | head -n 1)"
oldtitle="$(cat $oldarticle | head -n 1)"

# Replace title of last entry in gophermapfile
sed -i "s/$oldtitle/$newtitle/" "$1"
