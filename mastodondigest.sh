#!/bin/bash
# Mastodon digest, read last post from all followed accounts by ACCOUNT_NUM account
# - Storing auth key in pass command
# - Use curl command to access Mastodon API
# - use jq command for parsing JSON

AUTH=`pass mastodon`	# Set up by web preferences 
ACCOUNT_NUM=151263	# Possible to obtain by https://mastodon.online/api/v2/search

# temp files using in this script
if [ ! -d "/tmp" ];then
[[ ! -d "$HOME/.tmp" ]] && mkdir -p "$HOME/.tmp"
	TMPCONTENT=$(mktemp ~/.tmp/mastodondigest.XXXXXX)
	TMPHEADER=$(mktemp ~/.tmp/mastodondigest.XXXXXX)
else
	TMPCONTENT=$(mktemp /tmp/mastodondigest.XXXXXX)
	TMPHEADER=$(mktemp /tmp/mastodondigest.XXXXXX)
fi

# get content via curl at $1
function get_content() {
	curl "$1" -H 'Authorization: Bearer $AUTH' \
		# appending output to the same file every time
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

# starting link
NEXT_LINK="https://mastodon.online/api/v1/accounts/$ACCOUNT_NUM/following"

# while next link is not empty in the responded header 
while [ -n "$NEXT_LINK" ]; do
	get_content $NEXT_LINK
	NEXT_LINK=$(get_link_from_header "$(<$TMPHEADER)")

	echo $NEXT_LINK
done

jq --raw-output '.[].acct' <<< cat $TMPCONTENT | less
