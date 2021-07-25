#!/bin/bash

last_available=$(curl -s https://github.com/bacardi55/gtl/releases | grep "<a href=\"/bacardi55/gtl/releases/download/" | grep "amd64" | sort -ir | head -n 1 | egrep -o '"[^ ]+"' | head -n 1 | sed 's/"//g')
echo "Last available = ${last_available}"

if [ -z "$last_available" ]
then
	echo "Empty response form GitHub!"
	exit
fi

last_installed=$(ls | egrep "(gtl).*(amd64)" | sort -ir | head -n 1 | sed 's/amd64//g' | sed 's/[a-z_]*//g')
echo "Last installed = ${last_installed}"

if [ -z "$last_installed" ]
then
	echo "No version installed."
	exit
fi

if [[ "$last_available" == *"$last_installed"* ]]; then
	echo "No new version available."
	exit
fi

url="https://github.com/${last_available}"
filename=$(basename $url)
echo "Installing a new version from $url"

wget "$url" && chmod +x "$filename"

rm ~/.local/bin/gtl 

ln -s "$PWD"/"$filename" ~/.local/bin/gtl
