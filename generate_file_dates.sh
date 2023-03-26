#!/bin/bash
# Script to parse a GemText file $1 for links and describes links with last commit dates in local Git repository.

if [ -z "$1" ]
then
    echo "Usage:"
    echo "    generate_file_dates.sh filename"
    exit 1
fi

# Function to get git date for a file $1.
function get_date() {
	#Git log line pattern: "Date   YYYY-MM-DD"
	git log -n 1 --date=format:'%Y-%m-%d' "$1" | grep "Date:" | grep -oP "[0-9]+-[0-9]+-[0-9]+"
}

# Exclude ?!.*:// means https:// and other external links.
grep -oP "^\=\>(?!.*://)(.)*$" $1 | while read -r link ; do 
	tokens=( $link )
	linkdate=$(get_date ${tokens[1]})
	cleanlink=$(echo $link | sed -E 's/ ~[0-9]+-[0-9]+-[0-9]+//g')
	if [ "$link" = "$cleanlink ~$linkdate" ]; then
		echo "Not changed: ----- $link"
	else
		echo -e "Changed: ----- $link -----> $cleanlink ~$linkdate"
		# Used | as separator to avoid / mismatch in links. 
		sed -i "s|$link|$cleanlink ~$linkdate|g" $1
	fi
done 



