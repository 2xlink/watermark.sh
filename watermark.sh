#!/bin/bash
set -euo pipefail
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 IMAGE WATERMARK-TEXT"
    exit 1
fi

FILE=$1
TEXT=$2
TARGET_FILE=${FILE%.*}-watermark.${FILE##*.}

WIDTH=$(bc <<< "$(identify $FILE | cut -d " " -f 3 | sed -E "s/([0-9]+)x([0-9]+)/\1/g") * 0.5")
HEIGHT=$(bc <<< "$(identify $FILE | cut -d " " -f 3 | sed -E "s/([0-9]+)x([0-9]+)/\2/g") * 0.5")
POINTSIZE=$(bc <<< "x = ($HEIGHT - $WIDTH) * 0.4; if (x < 0) -x else x")
X1=$(bc <<< "60 + $RANDOM % 30")
X2=$(bc <<< "60 + $RANDOM % 30")
Y1=$(bc <<< "60 + $RANDOM % 30")
Y2=$(bc <<< "60 + $RANDOM % 30")

convert -size ${WIDTH}x${HEIGHT} xc:none -fill "#00000050" \
      -gravity NorthWest -pointsize $POINTSIZE -draw "text $X1,$Y1 '$TEXT'" \
      -gravity SouthEast -pointsize $POINTSIZE -draw "text $X2,$Y2 '$TEXT'" \
      miff:- |\
composite -tile - $FILE $TARGET_FILE
