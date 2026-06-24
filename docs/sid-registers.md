# SID register reference (6581/8580)

The SID lives at base **`S = 54272`** (`$D400`) and spans 29 registers
(`$D400`–`$D41C`). It has **3 voices**, each with an identical block of 7
registers, followed by shared filter/volume and read-only registers.

Absolute address = **voice base + offset** (for per-voice registers), or
**`S` + offset** (for the global ones).

## Voice base addresses

| Voice | Offset from `S` | Dec | Hex |
|---|---|---|---|
| 1 | `S+0`  | 54272 | `$D400` |
| 2 | `S+7`  | 54279 | `$D407` |
| 3 | `S+14` | 54286 | `$D40E` |

## Per-voice registers (offset from the voice base)

| Offset | Hex | Register | Width | Function |
|---:|---|---|---|---|
| 0 | `$00` | FREQ LO  | 8 bits | Frequency, low byte |
| 1 | `$01` | FREQ HI  | 8 bits | Frequency, high byte (16-bit total) |
| 2 | `$02` | PW LO    | 8 bits | Pulse width, low byte |
| 3 | `$03` | PW HI    | 4 bits (low nibble) | Pulse width, high nibble (12-bit total) |
| 4 | `$04` | CONTROL  | 8 bits | Waveform select + gate/ring/sync/test |
| 5 | `$05` | ATK/DEC  | 4+4    | Attack (high nibble) / Decay (low nibble) |
| 6 | `$06` | SUS/REL  | 4+4    | Sustain (high nibble) / Release (low nibble) |

Worked example: Voice 2 control register = `54279 + 4` = **54283** (`$D40B`).

## Global filter, volume & read-only registers (offset from `S`)

| Offset | Hex | Addr (dec) | Addr (hex) | Register | Function |
|---:|---|---:|---|---|---|
| 21 | `$15` | 54293 | `$D415` | FC LO    | Filter cutoff, low 3 bits |
| 22 | `$16` | 54294 | `$D416` | FC HI    | Filter cutoff, high 8 bits (11-bit total) |
| 23 | `$17` | 54295 | `$D417` | RES/FILT | Resonance + per-voice filter enable |
| 24 | `$18` | 54296 | `$D418` | MODE/VOL | Filter mode + master volume |
| 25 | `$19` | 54297 | `$D419` | POTX     | Paddle X (read-only) |
| 26 | `$1A` | 54298 | `$D41A` | POTY     | Paddle Y (read-only) |
| 27 | `$1B` | 54299 | `$D41B` | OSC3     | Voice 3 oscillator output (read-only) |
| 28 | `$1C` | 54300 | `$D41C` | ENV3     | Voice 3 envelope output (read-only) |

## Control register — offset `$04` (bit values)

| Bit | Dec | Hex | Name | Function |
|---:|---:|---|---|---|
| 0 | 1   | `$01` | GATE     | 1 = start attack, 0 = start release |
| 1 | 2   | `$02` | SYNC     | Hard-sync oscillator with previous voice |
| 2 | 4   | `$04` | RING     | Ring-modulate with previous voice (triangle) |
| 3 | 8   | `$08` | TEST     | Reset & lock the oscillator |
| 4 | 16  | `$10` | TRIANGLE | Triangle waveform |
| 5 | 32  | `$20` | SAWTOOTH | Sawtooth waveform |
| 6 | 64  | `$40` | PULSE    | Pulse / square waveform |
| 7 | 128 | `$80` | NOISE    | Noise waveform |

The byte is just the sum of the bits you want. Common waveform + gate combos:

| Dec | Hex | Meaning |
|---:|---|---|
| 17  | `$11` | Triangle + gate on |
| 33  | `$21` | Sawtooth + gate on |
| 65  | `$41` | Pulse + gate on |
| 129 | `$81` | Noise + gate on |
| 16  | `$10` | Triangle, gate off (release) |
| 32  | `$20` | Sawtooth, gate off |
| 64  | `$40` | Pulse, gate off |
| 128 | `$80` | Noise, gate off |

## Resonance / filter routing — offset `$17` (`$D417`)

| Bits | Dec | Hex | Function |
|---|---:|---|---|
| 0 | 1  | `$01` | Route voice 1 through filter |
| 1 | 2  | `$02` | Route voice 2 through filter |
| 2 | 4  | `$04` | Route voice 3 through filter |
| 3 | 8  | `$08` | Route external audio in through filter |
| 4–7 | high nibble | — | Resonance 0–15 (byte value = `resonance × 16`) |

## Filter mode / volume — offset `$18` (`$D418`)

| Bits | Dec | Hex | Function |
|---|---:|---|---|
| 0–3 | 0–15 | `$0`–`$F` | Master volume (0 = silent, 15 = max) |
| 4 | 16  | `$10` | Low-pass filter on |
| 5 | 32  | `$20` | Band-pass filter on |
| 6 | 64  | `$40` | High-pass filter on |
| 7 | 128 | `$80` | Disconnect voice 3 from the output |

Filter modes can be combined (e.g. low + high = notch). Byte = volume +
mode bits, e.g. `low-pass + volume 15` = `16 + 15` = **31** (`$1F`).

## Packing nibbles (ADSR registers)

Both envelope registers hold two 4-bit values. The byte is:

```
ATK/DEC byte = attack × 16 + decay      (reg +5)
SUS/REL byte = sustain × 16 + release   (reg +6)
```

Example: attack 6, decay 1 → `6×16 + 1` = **97** (`$61`).
Sustain 12, release 8 → `12×16 + 8` = **200** (`$C8`).

## Attack times — high nibble of reg `$05`

| Value | Hex | Attack |
|---:|---|---|
| 0  | `$0` | 2 ms |
| 1  | `$1` | 8 ms |
| 2  | `$2` | 16 ms |
| 3  | `$3` | 24 ms |
| 4  | `$4` | 38 ms |
| 5  | `$5` | 56 ms |
| 6  | `$6` | 68 ms |
| 7  | `$7` | 80 ms |
| 8  | `$8` | 100 ms |
| 9  | `$9` | 250 ms |
| 10 | `$A` | 500 ms |
| 11 | `$B` | 800 ms |
| 12 | `$C` | 1 s |
| 13 | `$D` | 3 s |
| 14 | `$E` | 5 s |
| 15 | `$F` | 8 s |

## Decay & release times — low nibble of reg `$05` / low nibble of reg `$06`

Decay and release share one table (3× the attack times).

| Value | Hex | Decay / Release |
|---:|---|---|
| 0  | `$0` | 6 ms |
| 1  | `$1` | 24 ms |
| 2  | `$2` | 48 ms |
| 3  | `$3` | 72 ms |
| 4  | `$4` | 114 ms |
| 5  | `$5` | 168 ms |
| 6  | `$6` | 204 ms |
| 7  | `$7` | 240 ms |
| 8  | `$8` | 300 ms |
| 9  | `$9` | 750 ms |
| 10 | `$A` | 1.5 s |
| 11 | `$B` | 2.4 s |
| 12 | `$C` | 3 s |
| 13 | `$D` | 9 s |
| 14 | `$E` | 15 s |
| 15 | `$F` | 24 s |

**Sustain** (high nibble of reg `$06`) is a *level* 0–15, not a time — the
volume the note holds at while the gate stays on.
