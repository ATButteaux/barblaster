# barblaster
Converts a file into an animated GIF (and now mp4 for easy playback on demand) of QR codes for the purpose of transferring file over an airgap (screen to webcam)

Play video with 'mpv --pause --keep-open --window-scale=2 <filename>'

On the recieving end, run zbarcam --raw --quiet | base64 -d | tee <filename>

Close zbarcam window and images will get processed and file will appear.

Effective throughput is about 1500 bps with current frame rate.
