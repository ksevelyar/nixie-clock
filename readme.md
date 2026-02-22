# Nixie Clock [![Continuous Integration](https://github.com/ksevelyar/nixie-clock/actions/workflows/rust_ci.yml/badge.svg)](https://github.com/ksevelyar/nixie-clock/actions/workflows/rust_ci.yml)

## Features
- Keeps time in sync via SNTP over Wi‑Fi
- Socketed tubes for quick replacement
- 3D‑printed case
- RISC‑V mcu
- std Rust

## How it works
- On boot, connects to Wi‑Fi and starts SNTP.
- The main loop reads UNIX time, formats HH:MM, and multiplexes four digits.
- GPIO 0–3 carry BCD; GPIO 4–7 select the active digit (one high at a time).
- ~2 ms per digit yields flicker‑free display.

### BCD
```
0 → 0000
1 → 0001
2 → 0010
3 → 0011
4 → 0100
5 → 0101
6 → 0110
7 → 0111
8 → 1000
9 → 1001
```

## Hardware

### Schematic
[![Schematic](./doc/schematic.png)](./doc/schematic.png?raw=1)

### PCB
[![PCB](./doc/pcb.png)](./doc/pcb.png?raw=1)

### Pinout
| GPIO | Function |
| ---- | -------- |
| 0–3 | encodes current digit |
| 4–7 | selects active digit |

## Build & Flash

```fish
nix develop

SSID="WiFi" PASS="Password" cargo run --release
```
