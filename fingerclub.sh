#!/bin/bash
# Inspired on Lace by Drew/uoou/Friendo
# gemini://friendo.monster/log/lace.gmi

ESC=$(echo -e "\033")
RED="[31m"
CLUB=(warsaw@graph.no szczezuja@szczezuja.space alex@flounder.online phlog@1436.ninja)

if [ ! -d "/tmp" ];then
[[ ! -d "$HOME/.tmp" ]] && mkdir -p "$HOME/.tmp"
	tmpfile=$(mktemp ~/.tmp/fingerclub.XXXXXX)
else
	tmpfile=$(mktemp /tmp/fingerclub.XXXXXX)
fi

for i in "${CLUB[@]}"
do
	echo -n $ESC$RED >> $tmpfile
	echo "### $i$ESC" >> $tmpfile
	finger $i >> $tmpfile
	echo -e "\n\n" >> $tmpfile
done

# header with finger time
date=$(date)
sed -i "1s/^/$ESC$RED# Finger club - $date$ESC\n\n/" $tmpfile

less -RisW $tmpfile && rm -f $tmpfile
