#!/bin/bash

# === CONFIG ===
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
SYMLINK_PATH="$HOME/.config/hypr/current_wallpaper"

cd "$WALLPAPER_DIR" || exit 1

# === handle spaces name
IFS=$'\n'

# === RANDOM WALLPAPER SELECTION ===
WALLPAPER_LIST=($(ls *.jpg *.png *.gif *.jpeg 2>/dev/null))
if [ ${#WALLPAPER_LIST[@]} -eq 0 ]; then
  echo "No wallpapers found!"
  exit 1
fi
SELECTED_WALL="${WALLPAPER_LIST[$RANDOM % ${#WALLPAPER_LIST[@]}]}"

SELECTED_PATH="$WALLPAPER_DIR/$SELECTED_WALL"

# === SET WALLPAPER ===
matugen image "$SELECTED_PATH"

# === CREATE SYMLINK ===
mkdir -p "$(dirname "$SYMLINK_PATH")"
ln -sf "$SELECTED_PATH" "$SYMLINK_PATH"

