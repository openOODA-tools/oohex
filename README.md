# oohex: Sovereign HEX DUMP PAGER

<div align="center">

```
================================================================================
                                oohex
                Sovereign openOODA HEX DUMP PAGER
================================================================================
```

**Sovereign HEX DUMP PAGER**  
*Color-coded hexadecimal viewer with canonical ASCII sidebar and delta highlighting.*  
*Two Faces, One Engine:* Modern terminal ergonomics for humans • Zero-leakage MCP for AI agents  
Written in 100% pure [openOODA](https://github.com/openOODA).

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![openOODA](https://img.shields.io/badge/openOODA-1.0-emerald.svg)](https://openooda.org)
[![Architecture: x86_64 | aarch64](https://img.shields.io/badge/Arch-x86__64%20%7C%20aarch64-lightgrey.svg)]()

</div>

---

## 1. Quick Install

### Automated Installer (Linux x86_64 & aarch64)
```bash
curl -fsSL https://openooda-tools.github.io/oohex/install.sh | bash
```

### Native Package Managers
```bash
# Arch Linux (AUR / PKGBUILD)
yay -S oohex-bin
# Or manual PKGBUILD:
cd packaging/arch && makepkg -si

# Debian / Ubuntu (.deb)
curl -fsSL https://openooda-tools.github.io/oohex/install.sh | bash -s -- --deb

# Fedora / RHEL (.rpm)
curl -fsSL https://openooda-tools.github.io/oohex/install.sh | bash -s -- --rpm
```

### Uninstallation
```bash
oohex-uninstall
# or: curl -fsSL https://openooda-tools.github.io/oohex/uninstall.sh | bash
```

---

## 2. CLI Usage

```
usage: oohex [options] [FILE]...

Color-coded hexadecimal viewer with canonical ASCII sidebar and delta highlighting.

Options:
  -c, --cols <NUM>      format <NUM> octets per line [default: 16]
  -s, --skip <NUM>      skip <NUM> octets from beginning of input [default: 0]
  -n, --length <NUM>    stop after reading <NUM> octets
  -g, --groupsize <NUM> group octets in clusters of <NUM>
  -C, --canonical       canonical hex+ASCII display [default]
  -p, --plain           output plain continuous hexadecimal string
  -u, --uppercase       use uppercase hex letters
  -r, --reverse         reverse operation: convert hex back into binary/ASCII
      --no-color        suppress ANSI color highlights
  -j, --json            output structured JSON telemetry
  -D, --demo            run interactive hex dump and delta showcase
      --test            run internal verification anchor self-test suite
  -h, --help            display this help and exit
  -v, --version         output version information and exit
      --mcp             run as Model Context Protocol stdio server
```

---

## 3. Model Context Protocol (MCP)

When invoked with `--mcp`, `oohex` runs a JSON-RPC 2.0 stdio server providing capability-bounded hex dump and delta tools for AI coding agents:

```bash
oohex --mcp
```

### Supported Tools
1. `hex_dump` - Generate color-coded/canonical hex dump of text or binary buffer.
2. `hex_inspect` - Dump and inspect a target file with offset, length, and column options under `&FsReadCap`.
3. `hex_diff` - Compare two files or buffers and visually highlight byte deltas.
4. `hex_stats` - Compute byte frequency distribution and Shannon entropy metrics.
5. `hex_demo` - Run hex viewer, ELF header dissection, and delta highlighting showcase.

---

## 4. Security & Zero Ambient Authority

* **Pure Capability Bounded:** Operates strictly with explicit tokens (`&FsReadCap`, `&ProcessCap`, `&EnvCap`). Physical absence of ambient disk/net leakage.
* **Negative-Trust Architecture:** Strict input validation and operational limits.
* **Hermetic Binary:** Standalone zero-dependency executable.

---

## 5. License

Apache License, Version 2.0. See [LICENSE](LICENSE) for details.
