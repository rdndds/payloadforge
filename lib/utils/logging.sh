#!/bin/bash
# PayloadForge - Logging Utilities

_log_level_to_num() {
    case "${1^^}" in
        DEBUG) echo 10 ;;
        INFO) echo 20 ;;
        WARN|WARNING) echo 30 ;;
        ERROR) echo 40 ;;
        CRITICAL|FATAL) echo 50 ;;
        *) echo 20 ;;
    esac
}

log_set_level() {
    LOG_LEVEL="${1^^}"
    LOG_LEVEL_NUM="$(_log_level_to_num "$LOG_LEVEL")"
}

_log_should_color() {
    local mode="${LOG_COLOR:-auto}"
    case "${mode,,}" in
        always) return 0 ;;
        never) return 1 ;;
        auto)
            if [ -n "${NO_COLOR-}" ]; then
                return 1
            fi
            [ -t 1 ]
            return
            ;;
        *)
            if [ -n "${NO_COLOR-}" ]; then
                return 1
            fi
            [ -t 1 ]
            return
            ;;
    esac
}

_log_color_for_level() {
    case "${1^^}" in
        DEBUG) printf '%b' '\033[0;90m' ;;   # Gray
        INFO) printf '%b' '\033[0;36m' ;;    # Cyan
        WARN|WARNING) printf '%b' '\033[0;33m' ;;  # Yellow
        ERROR|CRITICAL|FATAL) printf '%b' '\033[0;31m' ;;  # Red
        SUCCESS) printf '%b' '\033[0;32m' ;; # Green
        *) printf '%b' '' ;;
    esac
}

_log_format_logger_name() {
    local src="$1"
    local rel="$src"
    if [[ "$src" == *"/lib/"* ]]; then
        rel="${src#*"/lib/"}"
    elif [[ "$src" == lib/* ]]; then
        rel="${src#lib/}"
    elif [[ "$src" == *"/payloadforge" ]]; then
        rel="main"
    fi

    rel="${rel%.sh}"
    rel="${rel//\//.}"
    if [ -z "$rel" ]; then
        rel="main"
    fi

    printf '%s' "payloadforge.${rel}"
}

_log_get_caller_source() {
    local i
    for ((i = 1; i < ${#BASH_SOURCE[@]}; i++)); do
        if [[ "${BASH_SOURCE[$i]}" != *"lib/utils/logging.sh" ]]; then
            printf '%s' "${BASH_SOURCE[$i]}"
            return 0
        fi
    done
    printf '%s' "payloadforge"
}

_log_get_caller_context() {
    local context_mode="${LOG_CONTEXT:-none}"
    local i

    case "${context_mode,,}" in
        none|"")
            return 0
            ;;
        func|fileline|full)
            ;;
        *)
            context_mode="none"
            return 0
            ;;
    esac

    for ((i = 1; i < ${#BASH_SOURCE[@]}; i++)); do
        if [[ "${BASH_SOURCE[$i]}" != *"lib/utils/logging.sh" ]]; then
            local src func line base
            src="${BASH_SOURCE[$i]}"
            func="${FUNCNAME[$i]:-}"
            line="${BASH_LINENO[$((i - 1))]:-}"
            base="$(basename "$src")"

            case "${context_mode,,}" in
                func)
                    if [ -n "$func" ]; then
                        printf '%s' "$func"
                    fi
                    ;;
                fileline)
                    if [ -n "$line" ]; then
                        printf '%s' "${base}:${line}"
                    else
                        printf '%s' "$base"
                    fi
                    ;;
                full)
                    if [ -n "$func" ] && [ -n "$line" ]; then
                        printf '%s' "${func} ${base}:${line}"
                    elif [ -n "$func" ]; then
                        printf '%s' "$func"
                    elif [ -n "$line" ]; then
                        printf '%s' "${base}:${line}"
                    else
                        printf '%s' "$base"
                    fi
                    ;;
            esac
            return 0
        fi
    done
}

_log_timestamp() {
    local fmt="${LOG_TIME_FORMAT:-%Y-%m-%d %H:%M:%S}"
    date "+$fmt" 2>/dev/null || date
}

_log_write_plain_file() {
    local line="$1"
    if [ -n "${LOG_FILE-}" ]; then
        mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true
        printf '%s\n' "$line" >> "$LOG_FILE" 2>/dev/null || true
    fi
}

_log_write_terminal() {
    local line="$1"
    local is_error_stream="$2"
    if [ "$is_error_stream" = "true" ]; then
        printf '%s\n' "$line" >&2
    else
        printf '%s\n' "$line"
    fi
}

log_blank() {
    if [ "${LOG_LEVEL_NUM:-20}" -gt 20 ]; then
        return 0
    fi
    _log_write_terminal "" "false"
    _log_write_plain_file ""
}

log_rule() {
    local message="$1"
    if [ "${LOG_LEVEL_NUM:-20}" -gt 20 ]; then
        return 0
    fi
    if _log_should_color; then
        local c nc
        c=$'\033[0;36m'
        nc=$'\033[0m'
        _log_write_terminal "${c}${message}${nc}" "false"
    else
        _log_write_terminal "$message" "false"
    fi
    _log_write_plain_file "$message"
}

log_emit() {
    local level="${1^^}"
    local message="$2"
    local level_num
    level_num="$(_log_level_to_num "$level")"

    if [ "${LOG_LEVEL_NUM:-20}" -gt "$level_num" ]; then
        return 0
    fi

    local timestamp logger context line plain_line
    timestamp="$(_log_timestamp)"
    logger="$(_log_format_logger_name "$(_log_get_caller_source)")"

    context="$(_log_get_caller_context)"
    if [ -n "$context" ]; then
        plain_line="${timestamp} [${logger}] ${level} (${context}): ${message}"
    else
        plain_line="${timestamp} [${logger}] ${level}: ${message}"
    fi

    if _log_should_color; then
        local color reset
        color="$(_log_color_for_level "$level")"
        reset=$'\033[0m'
        if [ -n "$context" ]; then
            line="${timestamp} [${logger}] ${color}${level}${reset} (${context}): ${message}"
        else
            line="${timestamp} [${logger}] ${color}${level}${reset}: ${message}"
        fi
        _log_write_terminal "$line" "$([ "$level_num" -ge 40 ] && echo true || echo false)"
    else
        _log_write_terminal "$plain_line" "$([ "$level_num" -ge 40 ] && echo true || echo false)"
    fi

    _log_write_plain_file "$plain_line"
}

log_emit_with_logger() {
    local level="${1^^}"
    local logger="$2"
    local message="$3"
    local level_num
    level_num="$(_log_level_to_num "$level")"

    if [ "${LOG_LEVEL_NUM:-20}" -gt "$level_num" ]; then
        return 0
    fi

    local timestamp plain_line
    timestamp="$(_log_timestamp)"
    plain_line="${timestamp} [${logger}] ${level}: ${message}"

    if _log_should_color; then
        local color reset line
        color="$(_log_color_for_level "$level")"
        reset=$'\033[0m'
        line="${timestamp} [${logger}] ${color}${level}${reset}: ${message}"
        _log_write_terminal "$line" "$([ "$level_num" -ge 40 ] && echo true || echo false)"
    else
        _log_write_terminal "$plain_line" "$([ "$level_num" -ge 40 ] && echo true || echo false)"
    fi

    _log_write_plain_file "$plain_line"
}

log_debug() {
    log_emit "DEBUG" "$1"
}

log_info() {
    log_emit "INFO" "$1"
}

log_success() {
    log_emit "SUCCESS" "$1"
}

log_warn() {
    log_emit "WARN" "$1"
}

log_error() {
    log_emit "ERROR" "$1"
}

banner() {
    local text="PayloadForge - Forge flashable ROMs from payloads"
    if _log_should_color; then
        local c nc
        c=$'\033[0;36m'
        nc=$'\033[0m'
        _log_write_terminal "${c}${text}${nc}" "false"
    else
        _log_write_terminal "$text" "false"
    fi
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
  --log-level LEVEL            Set log level (DEBUG, INFO, WARN, ERROR)
  --log-context MODE           none|func|fileline|full (default: none)
  -v, --verbose                Extra verbose (DEBUG logs + verbose tools)
  -d, --debug                  Shortcut for --log-level DEBUG

Examples:
  payloadforge ota.zip                              # Template partitions, default settings
  payloadforge ota.zip -b 11                        # Maximum compression
  payloadforge ota.zip -b 0                         # No brotli compression (faster)
  payloadforge ota.zip -p "system vendor product"   # Custom partitions
  payloadforge ota.zip -i                           # Interactive mode
  payloadforge ota.zip -t 4 -z 0                    # 4 threads, no ZIP compression
USAGE
}

: "${LOG_LEVEL:=INFO}"
: "${LOG_COLOR:=auto}"
: "${LOG_TIME_FORMAT:=%Y-%m-%d %H:%M:%S}"
: "${LOG_FILE:=}"
: "${LOG_CONTEXT:=none}"

if [ -z "${LOG_CONTEXT_SOURCE-}" ] && [ "${LOG_LEVEL^^}" = "DEBUG" ]; then
    LOG_CONTEXT="full"
fi
log_set_level "${LOG_LEVEL}"
