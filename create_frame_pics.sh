#!/bin/bash

# ==============================================================================
# NAME: create_frame_pics.sh
# DESCRIPTION: Automatically loops through images in a directory, resizes them 
#              to the output dir. Copy this output dir into the photo frame.
#
# PREREQUISITES:
#   1. ImageMagick ('convert' command)
#   2. A mounted directory containing JPEG images
# ==============================================================================

# --- Configuration ---
OUTPUT_DIR="/home/sujeev/Desktop/write_out"

# Path to the folder where your NAS is mounted
PHOTO_DIR="/home/sujeev/Desktop/qnap_photos"

# --- Validation ---
rm -rf $OUTPUT_DIR
mkdir $OUTPUT_DIR
if [ ! -d "$OUTPUT_DIR" ]; then
    echo "Error: OUTPUT_DIR not found at $OUTPUT_DIR"
    exit 1
fi

if [ ! -d "$PHOTO_DIR" ]; then
    echo "Error: PHOTO_DIR not found at $PHOTO_DIR. Is the NAS mounted? Mount using cd /home/sujeev/Desktop/hom-projects; ./mount_nas.sh"
    exit 1
fi

# --- Main Loop ---
# 'find' looks into all subfolders (-recursive is default)
# '-iregex' makes it case-insensitive for various extensions
find "$PHOTO_DIR" -type f -iregex '.*\.\(jpg\|jpeg\|png\|heif\)' | shuf | while read -r file; do
    
    echo "Copying: $(basename "$file")"
    FILE_NAME=$(basename "$file")

    # Process and write to file
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
   	jpeg:- > "$OUTPUT_DIR/$FILE_NAME"

done

echo "All photos converted and written out to $OUTPUT_DIR"
