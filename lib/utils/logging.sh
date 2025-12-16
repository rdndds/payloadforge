#!/bin/bash
# PayloadForge - Logging Utilities

# Colors
C='\033[0;36m'    # Cyan
G='\033[0;32m'    # Green
Y='\033[0;33m'    # Yellow
R='\033[0;31m'    # Red
NC='\033[0m'      # No Color

log_info() {
    echo -e "[${C}INFO${NC}] $1"
}

log_success() {
    echo -e "[${G}SUCCESS${NC}] $1"
}

log_warn() {
    echo -e "[${Y}WARN${NC}] $1"
}

log_error() {
    echo -e "[${R}ERROR${NC}] $1"
}

banner() {
    local C='\033[0;36m'
    local NC='\033[0m'
    echo -e "${C}╔════════════════════════════════════════╗${NC}"
    echo -e "${C}║            PayloadForge                ║${NC}"
    echo -e "${C}║  Forge Flashable ROMs from Payloads   ║${NC}"
    echo -e "${C}╚════════════════════════════════════════╝${NC}"
    echo ""
}

show_usage() {
    cat << 'USAGE'
Usage: payloadforge <ota.zip> [OPTIONS]

Partition Selection:
  (default)                    Template partitions (odm_dlkm, product, system, system_ext, vendor, vendor_dlkm)
  -p, --partitions "list"      Custom partitions (space-separated)
  -i, --interactive            Interactive selection

Compression:
  -b, --brotli LEVEL           Brotli compression level 0-11 (default: 6, 0=disable)
  -z, --zip LEVEL              ZIP compression level 0-9 (default: 6, 0=store)

Performance:
  -t, --threads N              CPU threads (default: auto-detect)

Other:
  -h, --help                   Show this help message

Examples:
  payloadforge ota.zip                              # Template partitions, default settings
  payloadforge ota.zip -b 11                        # Maximum compression
  payloadforge ota.zip -b 0                         # No brotli compression (faster)
  payloadforge ota.zip -p "system vendor product"   # Custom partitions
  payloadforge ota.zip -i                           # Interactive mode
  payloadforge ota.zip -t 4 -z 0                    # 4 threads, no ZIP compression
USAGE
}
