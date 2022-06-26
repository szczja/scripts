#!/bin/bash
# Set it to $BROWSER environment variable to unify browsing experience 
# in other programs, for eg. to open a link in a proper browser from 
# `toot tui` and so on. This script adds support for gemini, gopher 
# and http links. Script is written open new window in `tmux`.

if [[ "$1" =~ ^gemini.* ]]; then
    tmux new-window /usr/bin/emacs --eval "(elpher-go \"$1\")"
fi

if [[ "$1" =~ ^gopher.* ]]; then
    tmux new-window /usr/bin/emacs --eval "(elpher-go \"$1\")"
fi

if [[ "$1" =~ ^http.* ]]; then
    tmux new-window /usr/bin/w3m -o ext_image_viewer=0 "$@"
fi
