#!/bin/bash
# Summary a water status of plants in Astrobotany plant ring

PLANT_RING=(
	5d129edfe438478d8ec5a0e57c69a505
	dafd7db795e145dcbd052e5a83e869d7
	d0263448b84d4238a21f8c450009172d
)

# temp file
if [ ! -d "/tmp" ];then
[[ ! -d "$HOME/.tmp" ]] && mkdir -p "$HOME/.tmp"
        tmpfile=$(mktemp ~/.tmp/plantring.XXXXXX.gmi)
else
        tmpfile=$(mktemp /tmp/plantring.XXXXXX.gmi)
fi

status=""
newline=false

for i in "${PLANT_RING[@]}"
do
	# get url content
	url="gemini://astrobotany.mozz.us/public/$i/m1"
	output=$(openssl s_client -crlf -quiet -connect "astrobotany.mozz.us:1965" <<< $url 2>/dev/null)
	if [ $newline = true ]
	then
		status+="\n"
	fi
	status+=$i
	status+=":"
	# regexp fit name
	status+=$(echo -e $output | grep -Eo 'name : "(.)+"')
	status+=":"
	# regexp fit water and bonus, it should be fixed
	status+=$(echo -e $output | grep -Eo 'water :(.)+{14}[0-9]+%' | grep -Eo '[0-9]+%')
	newline=true
done

# format output to gemtex, and sort by water status in column 3rd
echo -en $status | awk -F ':' '{printf "=> gemini://astrobotany.mozz.us/app/visit/%s %s %s\n",$1,$4,$3}' | sort -V -k 3 > $tmpfile

# header with probe time
date=$(date)
sed -i "1s/^/#Astrobotany ring - $date\n\n/" $tmpfile

# amfora as gemini browser of choice
amfora $tmpfile && rm -f $tmpfile
