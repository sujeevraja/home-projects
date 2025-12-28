#!/bin/bash

echo "frame* processes before refresh"
ps -ef | grep frame

# 1. Kill the existing slideshow process
pkill -f /home/sujeev/Desktop/home-projects/frame_slideshow.sh
echo "killed /home/sujeev/Desktop/home-projects/frame_slideshow.sh"

rm /home/sujeev/Desktop/home-projects/slideshow.log
echo "removed /home/sujeev/Desktop/home-projects/slideshow.log"

# 2. (Optional) Remount the NAS to ensure new folders are visible
./mount_nas.sh

# 3. Start a new slideshow in the background
nohup /home/sujeev/Desktop/home-projects/frame_slideshow.sh > /home/sujeev/Desktop/home-projects/slideshow.log 2>&1 &
echo "started slideshow script"

echo "frame* processes after refresh"
ps -ef | grep frame

echo "all done"

