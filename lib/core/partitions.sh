#!/bin/bash
# PayloadForge - Partition Selection

select_partitions() {
    local mode="$1"
    local custom_parts="$2"
    
    if [ "$mode" = "template" ]; then
        SELECTED_PARTITIONS="$DEFAULT_PARTITIONS"
        log_info "Using template partitions"
        return 0
    fi
    
    if [ "$mode" = "manual" ] && [ -n "$custom_parts" ]; then
        SELECTED_PARTITIONS="$custom_parts"
        log_info "Using custom partitions: $SELECTED_PARTITIONS"
        return 0
    fi
    
    # Interactive mode - list available partitions
    list_payload_partitions
    
    echo "Default partitions:"
    echo "-------------------------------------"
    echo "$DEFAULT_PARTITIONS"
    echo ""
    echo "Enter partition names (space-separated), or press ENTER for defaults:"
    read -r user_input
    
    if [ -z "$user_input" ]; then
        SELECTED_PARTITIONS="$DEFAULT_PARTITIONS"
        log_info "Using default partitions"
    else
        SELECTED_PARTITIONS="$user_input"
        log_info "Using selected partitions"
    fi
}

filter_partitions() {
    local partition_dir="$TEMP_DIR/partitions"
    
    echo ""
    log_info "Filtering selected partitions..."
    echo ""
    
    local valid_partitions=""
    local found=0
    local not_found=0
    
    for partition in $SELECTED_PARTITIONS; do
        if [ -f "$partition_dir/${partition}.img" ]; then
            local size=$(stat -c%s "$partition_dir/${partition}.img" 2>/dev/null || echo 0)
            local size_mb=$((size / 1024 / 1024))
            log_success "  ✓ ${partition}.img (${size_mb} MB)"
            valid_partitions="$valid_partitions $partition"
            found=$((found + 1))
        else
            log_warn "  ✗ ${partition}.img not found, skipping"
            not_found=$((not_found + 1))
        fi
    done
    
    if [ $found -eq 0 ]; then
        echo ""
        log_error "No valid partitions found"
        return 1
    fi
    
    SELECTED_PARTITIONS=$(echo $valid_partitions | xargs)
    
    echo ""
    log_success "Found $found partitions, skipped $not_found"
    
    return 0
}
