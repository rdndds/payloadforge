#!/bin/bash
# PayloadForge - Sparse Conversion

convert_to_sparse() {
    local img_file="$1"
    local partition=$(basename "$img_file" .img)
    local output_file="${img_file}.sparse"
    local sizes_file="$TEMP_DIR/partition_sizes.txt"
    
    # Save original partition size before conversion
    local img_size=$(stat -c%s "$img_file" 2>/dev/null || echo 0)
    echo "${partition}=${img_size}" >> "$sizes_file"
    
    if ! python3 "$SCRIPTS_DIR/img2simg.py" "$img_file" -o "$output_file" > /dev/null 2>&1; then
        log_error "Failed to convert $(basename "$img_file") to sparse"
        return 1
    fi
    
    mv "$output_file" "$img_file"
    return 0
}
