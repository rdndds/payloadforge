# Configuration

## settings.conf

Control defaults for compression and performance:

```bash
THREADS=0                    # 0 = auto-detect all cores
BROTLI_LEVEL=6              # 0-11 (0=store, 11=max)
USE_COMPRESSION=yes         # yes/no
ZIP_COMPRESSION_LEVEL=6     # 0-9 (0=store, 9=max)

# Logging (optional)
VERBOSE=no                  # yes/no (show tool output)
LOG_LEVEL=INFO              # DEBUG|INFO|WARN|ERROR
LOG_FILE=                   # write plain logs to a file
LOG_COLOR=auto              # auto|always|never
LOG_TIME_FORMAT=%Y-%m-%d\ %H:%M:%S
LOG_CONTEXT=none            # none|func|fileline|full

# Output naming
OUTPUT_NAME_MAX_LEN=40      # integer >= 8 (shorten very long OTA filenames)
```

## dynamic_partitions.conf

Control dynamic partition settings:

```bash
GROUP_TABLE=main
GROUP_TABLE_SIZE=9126805504  # Auto-calculated if not set
```

**Note:** `GROUP_TABLE_SIZE` is automatically calculated from actual partition sizes if not specified.

## default_partitions.txt

Template partition list (one per line):

```
odm_dlkm
product
system
system_ext
vendor
vendor_dlkm
```

Edit to customize default partitions.
