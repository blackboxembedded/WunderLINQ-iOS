#!/bin/sh
plutil -convert json "$1" -o - | ruby -r json -e 'puts JSON.parse(STDIN.read).keys.sort'
