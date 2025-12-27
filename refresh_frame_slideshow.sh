#!/bin/bash
# refresh_frame_slideshow.sh

# 1. Kill the existing slideshow process
pkill -f /home/sujeev/Desktop/frame_slideshow.sh

# 2. (Optional) Remount the NAS to ensure new folders are visible
# ./mount_nas.sh

# 3. Start a new slideshow in the background
nohup /home/sujeev/Desktop/frame_slideshow.sh > /home/sujeev/Desktop/slideshow.log 2>&1 &

