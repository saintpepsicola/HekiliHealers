#!/bin/bash

# Script to package Hekili Mouseovers addon for release
# This script zips the necessary files while excluding Mac-specific hidden files

# Define the zip file name
ZIP_NAME="HekiliHealers.zip"

# List of files to include in the zip
FILES=(
    "HekiliHealers.toc"
    "HekiliHealers.lua"
    "main.lua"
    "druid_resto.lua"
    "shaman_resto.lua"
    "priest_holy.lua"
)

# Check if all files exist in the current directory
echo "Checking for addon files..."
for file in "${FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "Error: File '$file' not found in the current directory. Ensure all files are in the same directory as this script."
        exit 1
    fi
done

# Remove any existing zip file with the same name
if [ -f "$ZIP_NAME" ]; then
    echo "Removing existing zip file: $ZIP_NAME"
    rm "$ZIP_NAME"
fi

# Zip the files directly, excluding Mac-specific hidden files
echo "Creating zip file: $ZIP_NAME"
zip "$ZIP_NAME" "${FILES[@]}" -x "*/__MACOSX/*" "*/.DS_Store"

# Check if the zip was created successfully
if [ -f "$ZIP_NAME" ]; then
    echo "Successfully created release package: $ZIP_NAME"
else
    echo "Error: Failed to create zip file: $ZIP_NAME"
    exit 1
fi

echo "Release packaging complete!" 