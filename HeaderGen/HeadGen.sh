##!/bin/bash

SDK_DIR="sdk/usr/include"
OUTPUT_DIR="./fssdk"
GENERATOR_PY="./Generator.py"
mkdir -p "$OUTPUT_DIR"

get_relative_path() {
    local header_file=$1
    echo "$header_file" | sed "s|^$SDK_DIR/||"
}

process_header() {
    local header_file=$1
    local relative_path=$(get_relative_path "$header_file")
    local output_path="$OUTPUT_DIR/$relative_path"

    mkdir -p "$(dirname "$output_path")"

    python3 "$GENERATOR_PY" "$header_file"

    mv "macros.js" "$output_path.fs"
    echo "Converted and saved $header_file as $output_path.fs"
}

process_all_headers() {
    find "$SDK_DIR" -type f -name "*.h" | while read header; do
        echo "Processing header: $header"
        process_header "$header"
    done
}

process_all_headers
echo "SDK conversion complete."
