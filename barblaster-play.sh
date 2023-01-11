#!/bin/bash
echo "Bar Blaster Play"
echo "Ver 20230111.1119"
echo


if [ "$#" = 0 ]; then
  echo "You need to specify a file to play."
  exit 1
fi

PLAYFILE="$1"
if [[ ! -f "${PLAYFILE}" ]]; then
  echo "${PLAYFILE} cannot be found."
  exit 1
fi

mpv --pause --keep-open --window-scale=2 "${PLAYFILE}" > /dev/null 2>&1
