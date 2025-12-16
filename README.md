# PayloadForge

Convert Android OTA packages to flashable ZIPs with dynamic partition support.

## Quick Start

```bash
git clone https://github.com/rdndds/payloadforge.git
cd payloadforge
./install.sh
payloadforge ota.zip
```

## Usage

```bash
payloadforge <ota.zip> [OPTIONS]
```

### Options

```
Partitions:
  -p "list"       Custom partitions (default: template)
  -i              Interactive selection

Compression:
  -b LEVEL        Brotli 0-11 (default: 6, 0=disable)
  -z LEVEL        ZIP 0-9 (default: 6, 0=store)

Performance:
  -t N            Threads (default: auto)

Other:
  -h              Help
```

### Examples

```bash
payloadforge ota.zip                    # Use template partitions
payloadforge ota.zip -b 11              # Maximum compression
payloadforge ota.zip -b 0               # No brotli (faster)
payloadforge ota.zip -p "system vendor" # Custom partitions
payloadforge ota.zip -i                 # Interactive mode
payloadforge ota.zip -t 4 -z 0          # 4 threads, no ZIP compression
```

## Requirements

- `brotli` - Compression
- `zip` - Packaging
- `python3` - Conversion scripts

Install with: `./install.sh`

## Features

- 🚀 Fast multi-threaded processing
- 📦 Automatic GROUP_TABLE_SIZE calculation
- 🎯 Template, manual, or interactive partition selection
- 🔧 Configurable compression levels
- 📊 Verbose progress output

## Configuration

Edit `config/settings.conf`:

```bash
THREADS=0                    # 0 = auto
BROTLI_LEVEL=6              # 0-11
USE_COMPRESSION=yes         # yes/no
ZIP_COMPRESSION_LEVEL=6     # 0-9
```

Edit `config/dynamic_partitions.conf`:

```bash
GROUP_TABLE=main
GROUP_TABLE_SIZE=9126805504  # Auto-calculated if not set
```

## Output

Flashable ZIP created in `output/` directory:
```
output/rom_6parts_20251216_134131.zip
```

Flash with TWRP or compatible recovery.

## License

MIT License - see [LICENSE](LICENSE)

---

**Made for the Android community** 🤖
