#!/bin/bash
# PayloadForge - DAT Conversion

convert_to_dat() {
    local img_file="$1"
    local partition=$(basename "$img_file" .img)
    local output_dir="$TEMP_DIR/output"
    
    if [ "${VERBOSE:-false}" = "true" ]; then
        if ! PYTHONUNBUFFERED=1 python3 "$SCRIPTS_DIR/img2sdat.py" "$img_file" -o "$output_dir" -v 4 -p "$partition"; then
            log_error "Failed to convert $(basename "$img_file") to DAT"
            return 1
        fi
    else
        if ! python3 "$SCRIPTS_DIR/img2sdat.py" "$img_file" -o "$output_dir" -v 4 -p "$partition" > /dev/null 2>&1; then
            log_error "Failed to convert $(basename "$img_file") to DAT"
            return 1
        fi
    fi
    
    return 0
}
