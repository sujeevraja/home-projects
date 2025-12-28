#!/bin/bash

# ==============================================================================
# NAME: frame_slideshow.sh
# DESCRIPTION: Automatically loops through images in a directory, resizes them 
#              to fit the Samsung SPF photo frame, and pushes them via USB.
#
# PREREQUISITES:
#   1. ImageMagick ('convert' command)
#   2. PyUSB and the 'frame-ctrl.py' script
#   3. A mounted directory containing JPEG images
# ==============================================================================

# --- Configuration ---
# Path to the directory containing the frame control Python script
REPO_PATH="/home/sujeev/Desktop/home-projects"

# Path to the folder where your NAS is mounted
PHOTO_DIR="/home/sujeev/Desktop/qnap_photos"

# Time in seconds to display each image
INTERVAL=15

# --- Validation ---
if [ ! -d "$REPO_PATH" ]; then
    echo "Error: REPO_PATH not found at $REPO_PATH"
    exit 1
fi

if [ ! -d "$PHOTO_DIR" ]; then
    echo "Error: PHOTO_DIR not found at $PHOTO_DIR. Is the NAS mounted?"
    exit 1
fi

echo "Starting slideshow... Press [CTRL+C] to stop."

# --- Main Loop ---
while true; do
    # 'find' looks into all subfolders (-recursive is default)
    # '-iregex' makes it case-insensitive for various extensions
    find "$PHOTO_DIR" -type f -iregex '.*\.\(jpg\|jpeg\|png\|heif\)' | shuf | while read -r file; do
        
        echo "Displaying: $(basename "$file")"

        # Process and send to frame
        cat "$file" | \
        convert - \
	-auto-orient \
	-colorspace sRGB \
	-resize 800x600 \
	-background black \
	-gravity center \
	-extent 800x600 \
	-strip \
	-interlace none \
	-define jpeg:extent=64kb \
       	jpeg:- | \
	tee /tmp/transfer.jpg | \
        sudo python3 "$REPO_PATH/frame-ctrl.py" - && \
	echo "Transferred size: $(wc -c < /tmp/transfer.jpg) bytes"

	# Wait before showing the next photo
        sleep "$INTERVAL"
    done
done
