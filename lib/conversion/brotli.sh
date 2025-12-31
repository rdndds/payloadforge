#!/bin/bash
# PayloadForge - Brotli Compression

compress_brotli() {
    local partition="$1"
    local level="$2"
    local input_file="$TEMP_DIR/output/${partition}.new.dat"
    local output_file="$TEMP_DIR/output/${partition}.new.dat.br"
    
    if [ "$USE_COMPRESSION" != "true" ]; then
        mv "$input_file" "$output_file"
        return 0
    fi
    
    # Check if input file exists
    if [ ! -f "$input_file" ]; then
        log_error "Input file not found: $input_file"
        return 1
    fi
    
    # Run brotli compression - it automatically creates .br file and removes source with -j
    # -q is quality, not quiet.
    local brotli_opts=("-q" "$level" -j -w 24)
    if [ "${VERBOSE:-false}" = "true" ]; then
        brotli_opts+=(-v)
    fi

    if ! brotli "${brotli_opts[@]}" "$input_file" 2>&1; then
        log_error "Failed to compress $partition"
        return 1
    fi
    
    # Verify output was created
    if [ ! -f "$output_file" ]; then
        log_error "Output file not created: $output_file"
        return 1
    fi
    
    return 0
}
