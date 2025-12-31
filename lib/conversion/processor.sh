#!/bin/bash
# PayloadForge - Partition Processing Pipeline

process_partitions() {
    local partition_dir="$TEMP_DIR/partitions"
    local brotli_level="$BROTLI_LEVEL"
    
    log_blank
    log_info "Processing partitions"
    log_info "Threads: $MAX_THREADS"
    log_info "Brotli level: $brotli_level"
    log_info "Compression: $USE_COMPRESSION"
    
    rm -f "$TEMP_DIR/partition_sizes.txt"
    
    local total=$(echo $SELECTED_PARTITIONS | wc -w)
    local current=0
    
    for partition in $SELECTED_PARTITIONS; do
        current=$((current + 1))
        local img_file="$partition_dir/${partition}.img"
        local img_size=$(stat -c%s "$img_file" 2>/dev/null || echo 0)
        local img_size_mb=$((img_size / 1024 / 1024))
        
        log_blank
        log_info "[$current/$total] Processing: ${partition}"
        log_info "Size: ${img_size_mb} MB (${img_size} bytes)"
        
        if ! convert_to_sparse "$img_file"; then
            log_error "Sparse conversion failed for $partition"
            return 1
        fi
        log_success "Sparse conversion complete"
        
        if ! convert_to_dat "$img_file"; then
            log_error "DAT conversion failed for $partition"
            return 1
        fi
        log_success "DAT conversion complete"
        
        if ! compress_brotli "$partition" "$brotli_level"; then
            log_error "Brotli compression failed for $partition"
            return 1
        fi
        
        # Show output file size
        local dat_file="$TEMP_DIR/output/${partition}.new.dat.br"
        if [ -f "$dat_file" ]; then
            local dat_size=$(stat -c%s "$dat_file" 2>/dev/null || echo 0)
            local dat_size_mb=$((dat_size / 1024 / 1024))
            local ratio=$((dat_size * 100 / img_size))
            log_success "Compression complete: ${dat_size_mb} MB (${ratio}% of original)"
        else
            log_success "Compression complete"
        fi
    done
    
    log_blank
    log_success "All $total partitions processed successfully!"
}
