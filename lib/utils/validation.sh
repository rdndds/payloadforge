#!/bin/bash
# PayloadForge - Validation Utilities

check_dependencies() {
    log_info "Checking dependencies..."
    
    local missing=()
    
    # Check system tools
    local system_tools=(
        "brotli"
        "zip"
        "python3"
    )
    
    for tool in "${system_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing+=("$tool")
        fi
    done
    
    # Check local tools
    [ ! -f "$BIN_DIR/payload" ] && missing+=("bin/payload")
    [ ! -f "$BIN_DIR/update-binary" ] && missing+=("bin/update-binary")
    
    # Check Python scripts
    [ ! -f "$SCRIPTS_DIR/img2sdat.py" ] && missing+=("scripts/img2sdat.py")
    [ ! -f "$SCRIPTS_DIR/img2simg.py" ] && missing+=("scripts/img2simg.py")
    
    if [ ${#missing[@]} -gt 0 ]; then
        log_error "Missing required tools: ${missing[*]}"
        log_error "Run './install.sh' to install dependencies"
        return 1
    fi
    
    log_success "All dependencies found"
    return 0
}

validate_input_file() {
    local file="$1"
    
    if [ -z "$file" ]; then
        log_error "No input file specified"
        return 1
    fi
    
    if [ ! -f "$file" ]; then
        log_error "File not found: $file"
        return 1
    fi
    
    # Detect file type - only support OTA ZIP files
    local filename=$(basename "$file")
    local extension="${filename##*.}"
    
    if [[ "$extension" == "zip" ]]; then
        echo "ota"
    else
        log_error "Unsupported file type: $file (only .zip OTA files supported)"
        return 1
    fi
}


