#!/bin/bash

# Check if file argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 filename.html"
  exit 1
fi

# Input file
input_file="$1"

# Output file (you can change this to overwrite the original)
output_file="${input_file%.html}_singleline.html"

# Replace newlines with spaces
tr '\n' ' ' < "$input_file" > "$output_file"

echo "Processed file saved as: $output_file"

