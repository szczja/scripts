#!/bin/bash
# Script to parse a GemText file for links and to describe links with last commit dates in local 
# Git repository. For describing it's using GemSub format. 
# => gemini://gemini.circumlunar.space/docs/companion/subscription.gmi

# Format "^=> URI description$" and URI without ://, only local links
LOCAL_LINK_STRUCTURE="(^\=\>(?!.*://))((.)*$)"
# Format "YYYY-MM-DD" or "~YYYY-MM-DD"
DATE_STRUCTURE="(~*){0,1}[0-9]{4}-[0-9]{2}-[0-9]{2}"

if [ -z "$1" ]
then
    echo "Usage:"
    echo "    generate_file_dates.sh filename"
    exit 1
fi

# Function to get git date for a file $1.
function get_date() {
	#Git log line pattern: "Date   YYYY-MM-DD"
	git log -n 1 --date=format:'%Y-%m-%d' "$1" | grep "Date:" | grep -oP "$DATE_STRUCTURE"
}

# Exclude ?!.*:// means https:// and other external links.
grep -oP "$LOCAL_LINK_STRUCTURE" $1 | while read -r link ; do 
	# Tokens of string separated by space
	tokens=( $link )
	# Second token is a URI
	linkdate=$(get_date ${tokens[1]})
	# We'd like to remove old date
	cleanlink=$(echo $link | sed -E "s/(~*){0,1}$DATE_STRUCTURE//g")
	# Tokens of string separated by space
	tokens=( $cleanlink )
	newlink=""
	for i in "${!tokens[@]}"
	do
		# Space between tokens
		if [[ "$i" -gt "0" ]]; then
			newlink+=" "
		fi
		# Next token
		newlink+="${tokens[i]}"
		# Second token is a URI, after URI we'd like to add new date
		if [ $i = 1 ]; then
			newlink+=" $linkdate"
		fi
	done
	# Compare link and new link
	if [ "$link" = "$newlink" ]; then
		echo "Not changed: ----- $link"
	else
		echo -e "Changed: ----- $link -----> $newlink"
		# Used | as separator to avoid / mismatch in links. 
		sed -i "s|$link|$newlink|g" $1
	fi
done 



