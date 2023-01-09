#!/bin/bash

QR_DATA_SIZE=1000
SPLIT_DELAY=50 #CentiSeconds
WORK_DIR=$(mktemp -d -p "/tmp")

#Check if input file exists
INPUT_FILE="$1"
if [[ ! "${INPUT_FILE}" ]]; then
  echo "${INPUT_FILE} does not exist."
  exit
fi

FILE_SIZE=$(stat --format="%s" ${INPUT_FILE})
if [ ${FILE_SIZE} -gt 1000000 ]; then
  echo "You have filled my anus and I cannot take any more"
  exit
fi

# Checkf if temp dir was created
if [[ ! "${WORK_DIR}" || ! -d "${WORK_DIR}" ]]; then
  echo "Could not create temp directory"
  exit 1
fi

#Delete temp directory
function cleanup {
  rm -rf "$WORK_DIR" && echo "Deleted temp directory ${WORK_DIR}" || echo "Error deleting temp directory ${WORK_DIR}"
}

#Register cleanup function
trap cleanup EXIT

#Generate data
#dd if=/dev/urandom of=~/ramdisk/barblaster-data.bin bs=1k count=5 > /dev/null 2>&1

#Encode data to Base64
base64 ${INPUT_FILE} > ${WORK_DIR}/barblaster-data.b64

#Split data into 1.5k chunks
split -b ${QR_DATA_SIZE} --suffix-length=4 --numeric-suffixes=0101 --additional-suffix=.b64 ${WORK_DIR}/barblaster-data.b64 ${WORK_DIR}/barblaster-split-

#Convert split.b64 files into qr codes
for FILE in ${WORK_DIR}/barblaster-split-* ; do
  OUTFILE=$(echo "${FILE}" | sed "s/.b64/.png/")
  cat ${FILE} | qrencode -o ${OUTFILE}
done

#Generate Start/Stop Frames
convert -size 400x400 xc:#FFFFFF -gravity Center -pointsize 30 -annotate 0 '3' ${WORK_DIR}/barblaster-split-0001.png
convert -size 400x400 xc:#FFFFFF -gravity Center -pointsize 30 -annotate 0 '2' ${WORK_DIR}/barblaster-split-0002.png
convert -size 400x400 xc:#FFFFFF -gravity Center -pointsize 30 -annotate 0 '1' ${WORK_DIR}/barblaster-split-0003.png
convert -size 400x400 xc:#990000 -gravity Center -pointsize 30 -annotate 0 'STOP' ${WORK_DIR}/barblaster-split-9997.png
convert -size 400x400 xc:#990000 -gravity Center -pointsize 30 -annotate 0 'STOP' ${WORK_DIR}/barblaster-split-9998.png
convert -size 400x400 xc:#990000 -gravity Center -pointsize 30 -annotate 0 'STOP' ${WORK_DIR}/barblaster-split-9999.png

#Convert PNG to animated GIF
convert -delay ${SPLIT_DELAY} -loop 0 -resize 400x400 ${WORK_DIR}/barblaster-split-*.png ${WORK_DIR}/barblaster-data.gif

#Move to current directory
OUT_FILE=$(echo "${INPUT_FILE}" | sed "s/\..*$/.gif/")
cp ${WORK_DIR}/barblaster-data.gif $(basename ${OUT_FILE})

OUT_FILE=$(echo "${INPUT_FILE}" | sed "s/\..*$/.mp4/")
ffmpeg -f gif -i ${WORK_DIR}/barblaster-data.gif $(basename ${OUT_FILE}) > /dev/null 2>&1

echo "${INPUT_FILE} ($(du -b -s ${INPUT_FILE}|cut -f1) bytes), was converted to $(ls ${WORK_DIR}/*.png | wc -l) images totaling $(du -b -s *.gif | cut -f1) bytes."
