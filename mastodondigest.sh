#!/bin/bash
# Mastodon digest, read last post from all followed accounts by ACCOUNT_NUM account
# - Storing auth key in pass command
# - Use curl command to access Mastodon API
# - use jq command for parsing JSON
# - amfora as a gemtext renderer

AUTH=`pass mastodon`	# Set up by web preferences 
ACCOUNT_NUM=151263	# Possible to obtain by https://mastodon.online/api/v2/search

# temp files using in this script
if [ ! -d "/tmp" ];then
[[ ! -d "$HOME/.tmp" ]] && mkdir -p "$HOME/.tmp"
	TMPCONTENT=$(mktemp ~/.tmp/mastodondigest.XXXXXX)
	TMPHEADER=$(mktemp ~/.tmp/mastodondigest.XXXXXX)
	TMPRESULT=$(mktemp --suffix=".gmi" ~/.tmp/mastodondigest.XXXXXX)
else
	TMPCONTENT=$(mktemp /tmp/mastodondigest.XXXXXX)
	TMPHEADER=$(mktemp /tmp/mastodondigest.XXXXXX)
	TMPRESULT=$(mktemp --suffix=".gmi" /tmp/mastodondigest.XXXXXX)
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
	# extract urls
	LL=$(echo "$LC" | grep -Eo "<a href=\"(http|https|gopher|finger|gemini)://[a-zA-Z0-9./?=_%:-]+" | sed 's/<a href=\"//g' | sort -u | awk '{print "=> "$0}')
	# remove all html tags from a content 
	LC=$(echo "$LC" | sed 's/<[^>]*>//g')
	LC=$(echo "$LC" | sed 's/|//g')
	# account without any toots will give an empty results	
	if [ -z "$LA" ]; then
    		echo -e "\u200b"
	else
		# gemtext paragraph, and a \u200b (ZERO WIDTH SPACE) char before the content (to avoid treating special gemtext characters as gemtext)
		echo -e "\n## $LD | $LA\n\u200b$LC\n$LL\n\n"
	fi
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
DATE=$(date)
echo -e "# mastodondigest.sh - $DATE" >> $TMPRESULT
# sort by last_status_at date given by mastodon API
for LACC in $(jq 'sort_by(.last_status_at)' <<< cat $TMPCONTENT | jq -r '.[].id'); do
	echo -e "$(get_last_status $LACC)" >> $TMPRESULT
	echo -n "."
done
echo ""

amfora $TMPRESULT
