#!/bin/bash
echo "Bar Blaster Receive"
echo "Ver 20230111.1119"
echo

WORK_DIR=$(mktemp -d -p "/tmp")
# Checkf if temp dir was created
if [[ ! "${WORK_DIR}" || ! -d "${WORK_DIR}" ]]; then
  echo "Could not create temp directory"
  exit 1
fi

if [ "$#" = 0 ]; then
  echo "You need to specify a plaintext file."
  exit 1
fi

INPUT_FILE="$1"
if [[ -f "${INPUT_FILE}" ]]; then
  echo "${INPUT_FILE} exists. Choose another filename or delete it first."
  exit 1
fi

#Delete temp directory
function cleanup {
  #rm -rf "${WORK_DIR}" && echo "Deleted temp directory ${WORK_DIR}" || echo "Error deleting temp directory ${WORK_DIR}"
  rm -rf "${WORK_DIR}"
}

#Register cleanup function
trap cleanup EXIT

echo "Scan barblast, then close webcam windows when complete."
WEBCAMDEV=
zbarcam --prescale=1024x768 --raw ${WEBCAMDEV} | tee ${WORK_DIR}/barblast.dat
base64 -d ${WORK_DIR}/barblast.dat > ${INPUT_FILE}
echo -e "\n\n\n${INPUT_FILE} hash: $(sha256sum ${INPUT_FILE} | cut -c1-8)"
