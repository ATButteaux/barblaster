# barblaster
This is a suite of scripts that will convert a file into an a stream of QR Codes in mp4 format for the purpose of transferring the file over an airgap (screen to webcam).

`barblaster.sh <input_filename>` will convert the input file to a similarly named MP4.

`barblaster-play.sh <filename>` will play the mp4 in my preferred player with preferred options.

`barblaster-rx.sh` is run on the receiving computer. It will prompt user to scan in QR Code stream, then decode the stream into the original file. It will display a partial hash of the original file for confirmation.
