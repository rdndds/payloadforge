#!/bin/bash
# PayloadForge - Flashable Package Creation

create_update_binary() {
    local meta_dir="$TEMP_DIR/output/META-INF/com/google/android"
    local binary_source="$BIN_DIR/update-binary"
    
    if [ ! -f "$binary_source" ]; then
        log_error "update-binary not found in $BIN_DIR"
        return 1
    fi
    
    cp "$binary_source" "$meta_dir/update-binary"
    chmod +x "$meta_dir/update-binary"
    
    return 0
}

shorten_output_name() {
    local name="$1"
    local max_len="${OUTPUT_NAME_MAX_LEN:-40}"
    local hash_len=8

    local cleaned
    cleaned="$(printf '%s' "$name" | tr -cd 'A-Za-z0-9._-')"
    cleaned="$(printf '%s' "$cleaned" | sed -E 's/[-_]{2,}/-/g; s/^[.-_]+//; s/[.-_]+$//')"
    if [ -z "$cleaned" ]; then
        cleaned="rom"
    fi

    if [ "${#cleaned}" -le "$max_len" ]; then
        printf '%s' "$cleaned"
        return 0
    fi

    local hash
    if command -v sha1sum >/dev/null 2>&1; then
        hash="$(printf '%s' "$cleaned" | sha1sum | awk '{print $1}' | cut -c1-$hash_len)"
    elif command -v shasum >/dev/null 2>&1; then
        hash="$(printf '%s' "$cleaned" | shasum -a 1 | awk '{print $1}' | cut -c1-$hash_len)"
    else
        hash="$(printf '%s' "$cleaned" | cksum | awk '{print $1}' | tr -d '\n' | cut -c1-$hash_len)"
    fi

    local prefix_len=$((max_len - hash_len - 1))
    if [ "$prefix_len" -lt 8 ]; then
        prefix_len=8
    fi
    local prefix="${cleaned:0:$prefix_len}"
    prefix="$(printf '%s' "$prefix" | sed -E 's/[._-]+$//')"
    if [ -z "$prefix" ]; then
        prefix="rom"
    fi
    printf '%s-%s' "$prefix" "$hash"
}

package_flashable_zip() {
    local base_name=""
    local timestamp=$(date +%Y%m%d_%H%M%S)
    
    if [ -n "$INPUT_FILE_NAME" ]; then
        base_name=$(basename "$INPUT_FILE_NAME" .zip)
        base_name=$(basename "$base_name" .img)
        base_name=$(echo "$base_name" | sed 's/_ota$//' | sed 's/_OTA$//' | sed 's/^ota_//')
    else
        base_name="rom"
    fi
    
    local part_count=$(echo $SELECTED_PARTITIONS | wc -w)

    local short_name
    short_name="$(shorten_output_name "$base_name")"

    local output_zip="$OUTPUT_DIR/${short_name}_${part_count}p_${timestamp}.zip"

    GENERATED_ZIP_PATH="$output_zip"
    
    log_info "Creating flashable ZIP..."
    
    local meta_dir="$TEMP_DIR/output/META-INF/com/google/android"
    mkdir -p "$meta_dir"
    
    mv "$TEMP_DIR/output/updater-script" "$meta_dir/"
    create_update_binary || return 1
    
    cd "$TEMP_DIR/output" || return 1
    
    local zip_opts="-r -q"
    if [ "${VERBOSE:-false}" = "true" ]; then
        zip_opts="-r -v"
    fi
    if [ "$ZIP_COMPRESSION_LEVEL" = "0" ]; then
        zip_opts="-0 $zip_opts"
        log_info "Using store mode (no ZIP compression)..."
    else
        zip_opts="-${ZIP_COMPRESSION_LEVEL} $zip_opts"
        log_info "Using ZIP compression level $ZIP_COMPRESSION_LEVEL..."
    fi
    
    if ! zip $zip_opts "$output_zip" .; then
        log_error "Failed to create ZIP"
        return 1
    fi
    
    cd - > /dev/null
    
    log_success "Flashable ZIP created: $(basename "$output_zip")"
    log_info "Output size: $(du -h "$output_zip" | cut -f1)"
    
    return 0
}
