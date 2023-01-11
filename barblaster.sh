#!/bin/bash
echo "Bar Blaster Creator"
echo "Ver 20230111.1146"
echo

QR_DATA_SIZE=1000
SPLIT_DELAY=50 #CentiSeconds
WORK_DIR=$(mktemp -d -p "/tmp")

#Check if input file exists
if [[ $# -ne 1 ]]; then
  echo "You must supply a file to encode."
  exit
fi

INPUT_FILE="$1"
if [[ ! "${INPUT_FILE}" ]]; then
  echo "${INPUT_FILE} does not exist."
  exit
fi

FILE_HASH="$(sha256sum ${INPUT_FILE} | cut -c1-8)..."
FILE_SIZE=$(stat --format="%s" ${INPUT_FILE})
if [ ${FILE_SIZE} -gt 1000000 ]; then
  echo "Penis is too large."
  exit
fi

# Checkf if temp dir was created
if [[ ! "${WORK_DIR}" || ! -d "${WORK_DIR}" ]]; then
  echo "Could not create temp directory"
  exit 1
fi

#Delete temp directory
function cleanup {
  #rm -rf "$WORK_DIR" && echo "Deleted temp directory ${WORK_DIR}" || echo "Error deleting temp directory ${WORK_DIR}"
  rm -rf "$WORK_DIR"
}

#Register cleanup function
trap cleanup EXIT

#Encode data to Base64
base64 ${INPUT_FILE} > ${WORK_DIR}/barblaster-data.b64

#Split data into 1.5k chunks
split -b ${QR_DATA_SIZE} --suffix-length=4 --numeric-suffixes=0101 --additional-suffix=.b64 ${WORK_DIR}/barblaster-data.b64 ${WORK_DIR}/barblaster-split-

#Convert split.b64 files into qr codes
for FILE in ${WORK_DIR}/barblaster-split-* ; do
  FILEBASE="${FILE%.*}"
  cat ${FILE} | qrencode -o ${FILEBASE}.png
done

#Generate Start/Stop Frames
convert -size 400x400 xc:#FFFFFF -gravity Center -pointsize 12 -annotate 0 "$(echo -e "Expect file hash:\n${FILE_HASH}\n\nFor focus:"; cat /usr/share/dict/words | grep "^[A-Za-z]\{4,6\}$" | iconv -f utf8 -t ascii//TRANSLIT | shuf -n 120 | tr "[:upper:]" "[:lower:]" | tr "\n" " " | fmt)" -bordercolor red -border 20 ${WORK_DIR}/barblaster-split-0001.png
convert -size 400x400 xc:#FFFFFF -gravity Center -pointsize 30 -annotate 0 '3' -bordercolor red -border 20 ${WORK_DIR}/barblaster-split-0002.png
convert -size 400x400 xc:#FFFFFF -gravity Center -pointsize 30 -annotate 0 '2' -bordercolor red -border 20 ${WORK_DIR}/barblaster-split-0003.png
convert -size 400x400 xc:#FFFFFF -gravity Center -pointsize 30 -annotate 0 '1' -bordercolor red -border 20 ${WORK_DIR}/barblaster-split-0004.png
convert -size 400x400 xc:#990000 -gravity Center -pointsize 30 -annotate 0 'STOP' ${WORK_DIR}/barblaster-split-9997.png
convert -size 400x400 xc:#990000 -gravity Center -pointsize 30 -annotate 0 'STOP' ${WORK_DIR}/barblaster-split-9998.png
convert -size 400x400 xc:#990000 -gravity Center -pointsize 30 -annotate 0 "$(echo -e "STOP\n\nFile hash: ${FILE_HASH}")" ${WORK_DIR}/barblaster-split-9999.png

#Convert PNG to animated GIF
convert -delay ${SPLIT_DELAY} -loop 0 -resize 400x400 ${WORK_DIR}/barblaster-split-*.png ${WORK_DIR}/barblaster-data.gif

OUTPUT_FILE="$(basename ${INPUT_FILE%.*}.mp4)"
if [[ -f ${OUTPUT_FILE} ]]; then
  rm ${OUTPUT_FILE}
fi
ffmpeg -f gif -i ${WORK_DIR}/barblaster-data.gif ${OUTPUT_FILE} > /dev/null 2>&1

echo "${INPUT_FILE} ($(du -b -s ${INPUT_FILE}|cut -f1) bytes), was converted to ${OUTPUT_FILE} totaling $(stat --format "%s" scripts-20230111.1119.mp4) bytes."
echo
