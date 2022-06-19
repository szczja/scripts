#!/bin/bash
# Summary a water status of plants in Astrobotany plant ring

PLANT_RING=(5d129edfe438478d8ec5a0e57c69a505 06206c2d3c1a408da14fcee89d04f87f dafd7db795e145dcbd052e5a83e869d7 d0263448b84d4238a21f8c450009172d)

if [ ! -d "/tmp" ];then
[[ ! -d "$HOME/.tmp" ]] && mkdir -p "$HOME/.tmp"
        tmpfile=$(mktemp ~/.tmp/fingerclub.XXXXXX.gmi)
else
        tmpfile=$(mktemp /tmp/fingerclub.XXXXXX.gmi)
fi

status=""
newline=false

for i in "${PLANT_RING[@]}"
do
	url="gemini://astrobotany.mozz.us/public/$i/m1"
	output=$(openssl s_client -crlf -quiet -connect "astrobotany.mozz.us:1965" <<< $url)
	if [ $newline = true ]
	then
		status+="\n"
	fi
	status+=$i
	status+=":"
	status+=$(echo -e $output | grep -Eo 'name : "(.)+"')
	status+=":"
	status+=$(echo -e $output | grep -Eo 'water(.)+%' | grep -Eo '[0-9]+%')
	newline=true
done

echo -en $status | awk -F ':' '{printf "=> gemini://astrobotany.mozz.us/public/%s/m1 %s %s\n",$1,$4,$3}' | sort -k 3 > $tmpfile

date=$(date)
sed -i "1s/^/#Astrobotany ring - $date\n/" $tmpfile

amfora $tmpfile && rm -f $tmpfile
