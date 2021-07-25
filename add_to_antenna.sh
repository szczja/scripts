#!/bin/bash

FEED_URL="szczezuja.space/gemlog/atom.xml"

ANTENNA_DOMAIN="warmedal.se"
ANTENNA_URL="gemini://${ANTENNA_DOMAIN}/~antenna/submit?${FEED_URL}"
ANTENNA_DOMAIN="${ANTENNA_DOMAIN}:1965"

timeout 5 openssl s_client -crlf -quiet -connect $ANTENNA_DOMAIN <<< $ANTENNA_URL
