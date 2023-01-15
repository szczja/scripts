#!/bin/bash
# Mastodon digest, read last post from all followed accounts by ACCOUNT_NUM account
# - Storing auth key in pass command
# - Use curl command to access Mastodon API
# - use jq command for parsing JSON

AUTH=`pass mastodon`	# Set up by web preferences 
ACCOUNT_NUM=151263	# Possible to obtain by https://mastodon.online/api/v2/search

COL_PURPLE='\033[0;35m'
COL_GRAY='\033[1;30m'
COL_NO='\033[0m'

# temp files using in this script
if [ ! -d "/tmp" ];then
[[ ! -d "$HOME/.tmp" ]] && mkdir -p "$HOME/.tmp"
	TMPCONTENT=$(mktemp ~/.tmp/mastodondigest.XXXXXX)
	TMPHEADER=$(mktemp ~/.tmp/mastodondigest.XXXXXX)
	TMPRESULT=$(mktemp ~/.tmp/mastodondigest.XXXXXX)
else
	TMPCONTENT=$(mktemp /tmp/mastodondigest.XXXXXX)
	TMPHEADER=$(mktemp /tmp/mastodondigest.XXXXXX)
	TMPRESULT=$(mktemp /tmp/mastodondigest.XXXXXX)
fi

# get content via curl at $1
function get_content() {
	# appending output to the same file every time
	curl "$1" -s -H 'Authorization: Bearer $AUTH' \
		--output >(cat >> $TMPCONTENT) \
		--dump-header $TMPHEADER
}

# extract link from curl header in $1
function get_link_from_header() {
	# We are looking for:
	# link: <https://mastodon.online/api/v1/accounts/151263/following?limit=1&max_id=5029556>; rel="next"
	# in the header (pagination mechanism) 
	LNEXT_LINK=$(echo $1 | grep -E -o '(link: )(<)(https:\/\/.+)(>; rel="next")')
	LNEXT_LINK=$(echo $LNEXT_LINK | grep -E -o '(https:\/\/.+)(>)')
	LNEXT_LINK=${LNEXT_LINK/>/}
	echo -en $LNEXT_LINK
}

# get last status of account id as $1
function get_last_status() {
	# start from an empty content file
	echo "" > $TMPCONTENT
	get_content "https://mastodon.online/api/v1/accounts/$1/statuses?limit=1&exclude_replies=true&exclude_reblogs=true"
	LD=$(jq --raw-output '.[].created_at' <<< cat $TMPCONTENT)
	LA=$(jq --raw-output '.[].account.username' <<< cat $TMPCONTENT)
	LC=$(jq --raw-output '.[].content' <<< cat $TMPCONTENT)
	# remove all html tags from a content 
	LC=$(echo "$LC" | sed 's/<[^>]*>//g')
	LC=$(echo "$LC" | sed 's/|//g')
	echo -e "${COL_PURPLE}@$LD${COL_NO} | ${COL_GRAY}$LA${COL_NO} | $LC"
}

# starting link
NEXT_LINK="https://mastodon.online/api/v1/accounts/$ACCOUNT_NUM/following"

# while next link is not empty in the responded header 
while [ -n "$NEXT_LINK" ]; do
	# content is appending to a tmp file
	get_content $NEXT_LINK
	NEXT_LINK=$(get_link_from_header "$(<$TMPHEADER)")
	echo -n "."
done

# print last status for every account id in the content
for LACC in $(jq -r '.[].id' <<< cat $TMPCONTENT); do
	echo -e $(get_last_status $LACC) >> $TMPRESULT
	echo -n "."
done
echo ""

sort -h -r $TMPRESULT | fold -s | less -R
