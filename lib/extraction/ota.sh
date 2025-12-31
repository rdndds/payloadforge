#!/bin/bash
# PayloadForge - OTA Extraction

extract_ota() {
    local ota_file="$1"
    local payload_file="$TEMP_DIR/payload.bin"
    
    log_info "Extracting payload.bin from OTA zip..."
    
    if [ "${VERBOSE:-false}" = "true" ]; then
        if ! unzip -o "$ota_file" "payload.bin" -d "$TEMP_DIR"; then
            log_error "Failed to extract payload.bin"
            return 1
        fi
    else
        if ! unzip -o -q "$ota_file" "payload.bin" -d "$TEMP_DIR" 2>/dev/null; then
            log_error "Failed to extract payload.bin (rerun with --verbose for unzip output)"
            return 1
        fi
    fi
    
    if [ ! -f "$payload_file" ]; then
        log_error "payload.bin not found"
        return 1
    fi
    
    log_success "payload.bin extracted"
    return 0
}

extract_payload() {
    local payload_file="$TEMP_DIR/payload.bin"
    local output_dir="$TEMP_DIR/partitions"
    
    log_info "Extracting partitions using $MAX_THREADS threads..."
    echo ""
    
    # Run without output redirection to show progress
    if ! "$BIN_DIR/payload" "$payload_file" -c "$MAX_THREADS" -o "$output_dir" 2>&1; then
        log_error "Failed to extract payload.bin"
        return 1
    fi
    
    echo ""
    local count=$(ls -1 "$output_dir"/*.img 2>/dev/null | wc -l)
    log_success "Extracted $count partitions"
    return 0
}

list_payload_partitions() {
    local output_dir="$TEMP_DIR/partitions"
    
    echo ""
    echo "Available partitions:"
    echo "-------------------------------------"
    
    local index=1
    for img in "$output_dir"/*.img; do
        if [ -f "$img" ]; then
            printf "%6d  %s\n" $index "$(basename "$img" .img)"
            index=$((index + 1))
        fi
    done
    echo ""
}
