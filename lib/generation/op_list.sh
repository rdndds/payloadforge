#!/bin/bash
# PayloadForge - Dynamic Partitions Op List Generation

generate_dynamic_partitions_op_list() {
    local output_file="$TEMP_DIR/output/dynamic_partitions_op_list"
    local sizes_file="$TEMP_DIR/partition_sizes.txt"
    
    log_info "Generating dynamic_partitions_op_list..."
    
    get_partition_size() {
        local partition=$1
        grep "^${partition}=" "$sizes_file" 2>/dev/null | cut -d= -f2 || echo "0"
    }
    
    {
        echo "# Remove all existing dynamic partitions"
        echo "remove_all_groups"
        echo "# Add group $GROUP_TABLE with maximum size $GROUP_TABLE_SIZE"
        echo "add_group $GROUP_TABLE $GROUP_TABLE_SIZE"
        
        for partition in $SELECTED_PARTITIONS; do
            echo "# Add partition $partition to group $GROUP_TABLE"
            echo "add $partition $GROUP_TABLE"
        done
        
        for partition in $SELECTED_PARTITIONS; do
            local size=$(get_partition_size "$partition")
            echo "# Grow partition $partition from 0 to $size"
            echo "resize $partition $size"
        done
    } > "$output_file"
    
    log_success "op_list generated"
}
