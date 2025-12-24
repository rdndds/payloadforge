#!/bin/bash
# PayloadForge - Updater Script Generation

generate_updater_script() {
    local output_file="$TEMP_DIR/output/updater-script"
    
    log_info "Generating updater-script..."
    
    {
        echo 'ui_print("Checking /cache...");'
        echo 'run_program("/sbin/sh", "-c", "[ -d /data/cache ] || mkdir -p /data/cache");'
        echo ''
        echo 'assert(update_dynamic_partitions(package_extract_file("dynamic_partitions_op_list")));'
        
        for partition in $SELECTED_PARTITIONS; do
            echo ""
            echo "ui_print(\"Flashing ${partition}...\");"
            echo "block_image_update(map_partition(\"${partition}\"), package_extract_file(\"${partition}.transfer.list\"), \"${partition}.new.dat.br\", \"${partition}.patch.dat\") ||"
            echo "  abort(\"E1001: Failed to flash ${partition}\");"
        done
        
        echo ""
        echo 'ui_print("Installation complete!");'
    } > "$output_file"
    
    log_success "updater-script generated"
}
