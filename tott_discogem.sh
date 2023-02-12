# DiscoGem top of the tops
# gemini://discogem.gmi.bacardi55.io/

FILE="tott_discogem.dat"

# read content of a Gemini url passed as $1
function read_gemini() {
	DOMAIN=$(echo "$1" | awk -F/ '{print $3}')
        OUTPUT=$(timeout 3 openssl s_client -crlf -quiet -connect "$DOMAIN:1965" <<< $1 2>/dev/null)
        echo -en $OUTPUT
}

# iterate over capsules of the day listed in $1 to a $FILE
function iterate_cotd() {
	echo "" > $FILE
	LINK=""

	# iterate through capsule of the day links
	while read -r LINK; do
		PLINK=$(echo $LINK | sed 's/=> //')
		COTD=$(read_gemini "gemini://discogem.gmi.bacardi55.io$PLINK")
		DLINK=""
		AVGSIZE=0
		EMPTY=0
		echo -n "." >&2							# to show a progress

		# iterate through one day links
		while read -r DLINK; do
			PDLINK=$(echo $DLINK | sed 's/=> //')
			if [[ "$PDLINK" != "../" ]];then			# to avoid ../ link
				CAPSULE=""
				SIZE=0
				CAPSULE=$(read_gemini $PDLINK)
				SIZE=${#CAPSULE}
				if [ $SIZE -gt "30" ]; then			# simplified way to determine 51 Not found and so on
					let AVGSIZE=$AVGSIZE+$SIZE
				else
					let EMPTY=$EMPTY+1
				fi
			fi
		done < <(echo -en $COTD | grep -Po "=> \S+/")			# / at the end to avoid *.gmi
		NOTEMPTY=5
		let NOTEMPTY-=$EMPTY
		let AVGSIZE/=$NOTEMPTY
		echo -e "$AVGSIZE\tchars\t$EMPTY\tempty capsules\t$PLINK" >> $FILE

	done < <(echo -en $1 | grep -Po "=> /capsules-of-the-day-([0-9]|-)+/")	# through /capsules-of-the-day-2023-02-05/ pattern
}

# print summary of a $FILE
function print_summary() {
	echo "# DiscoGem top of the tops"
	echo "## The biggest index pages day:"
	cat $FILE | sort -h -r | head -n 3
	echo "## The smallest index pages day:"
	cat $FILE | sort -h | head -n 3
	echo "## The most useless day:"
	cat $FILE | sort -h -r -k 3 | head -n 3
}

#main

PAGE=$(read_gemini "gemini://discogem.gmi.bacardi55.io/")

echo -e $(iterate_cotd "$PAGE")
sed -i '/^\s*$/d' $FILE								# dirty hack to remove empty lines in file, there must be a bug somewhere

print_summary
