#!/bin/bash
# Water a Astrobotany plant

PLANT_RING=(
	5d129edfe438478d8ec5a0e57c69a505
	dafd7db795e145dcbd052e5a83e869d7
	d0263448b84d4238a21f8c450009172d
)

# cert and key for Astrobotany
sslcert=~/.local/share/amfora/certs/astrobotany/cert.pem
sslkey=~/.local/share/amfora/certs/astrobotany/key.pem

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
echo -en $status | awk -F ':' '{printf "gemini://astrobotany.mozz.us/app/visit/%s/water %s\n",$1,$4}' | sort -V -k 2 | awk '{printf "%s\n",$1}' > $tmpfile

# the most wiling plant
url=$(cat $tmpfile | head -n 1)

# connect to the /water URL for the plant
output=$(openssl s_client -crlf -cert $sslcert -key $sslkey -quiet -connect "astrobotany.mozz.us:1965" <<< $url 2>/dev/null)

# parse a response, we are awaiting 30 status for rederiction
pattern="^30 (.)*$"
if [[ $output =~ $pattern ]]
then
	# get the second field, and strip the non-print characters
	url=$(echo $output | cut -d' ' -f 2 | tr -dc '[:print:]')
	newurl="gemini://astrobotany.mozz.us"
	newurl+=$url
	
	# connect to the final plant URL
	output=$(openssl s_client -crlf -cert $sslcert -key $sslkey -quiet -connect "astrobotany.mozz.us:1965" <<< $newurl 2>/dev/null)

	# regexp fit name
 	status=$(echo -e $output | grep -Eo 'name : "(.)+"')
 	status+=":"
 	# regexp fit water and bonus, it should be fixed
 	status+=$(echo -e $output | grep -Eo 'water :(.)+{14}[0-9]+%' | grep -Eo '[0-9]+%')
	echo $status
fi
