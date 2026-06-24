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

## Oscillator frequency (FREQ LO/HI → Hz)

The 16-bit value `Fn` in FREQ LO/HI sets the pitch:

```
Fout = Fn × Fclk / 2^24      Fn = Fout × 2^24 / Fclk
Fclk = 985248 Hz (PAL)   or   1022727 Hz (NTSC)
```

`Fn` is **linear in pitch**, so each octave up just **doubles** `Fn` (and each
octave down halves it). That means you only need one octave of note values —
multiply/divide by 2 to transpose. Octave 4, PAL, equal temperament (A4 = 440):

| Note | Hz | Fn | hi | lo | Hex |
|---|---:|---:|---:|---:|---|
| C4  | 261.63 | 4455 | 17 | 103 | `$1167` |
| C#4 | 277.18 | 4720 | 18 | 112 | `$1270` |
| D4  | 293.66 | 5001 | 19 | 137 | `$1389` |
| D#4 | 311.13 | 5298 | 20 | 178 | `$14B2` |
| E4  | 329.63 | 5613 | 21 | 237 | `$15ED` |
| F4  | 349.23 | 5947 | 23 |  59 | `$173B` |
| F#4 | 369.99 | 6300 | 24 | 156 | `$189C` |
| G4  | 392.00 | 6675 | 26 |  19 | `$1A13` |
| G#4 | 415.30 | 7072 | 27 | 160 | `$1BA0` |
| A4  | 440.00 | 7493 | 29 |  69 | `$1D45` |
| A#4 | 466.16 | 7938 | 31 |   2 | `$1F02` |
| B4  | 493.88 | 8410 | 32 | 218 | `$20DA` |

Generate the full table or convert single values with
[`../scripts/sid-freq.py`](../scripts/sid-freq.py) (e.g. `--note A4`,
`--hz 440`, `--reg 7493`, `--ntsc`). Setting only FREQ HI (low byte 0) lands
*near* a note but not on it — e.g. `hi=17` → 255.6 Hz, ~30 cents flat of C4.

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

## Filter cutoff frequency (FC LO/HI → Hz)

The cutoff is an **11-bit** value assembled from the two registers:

```
FC = (FC_HI << 3) | (FC_LO & 7)      range 0..2047
```

Unlike the oscillator, cutoff in Hz has **no clean formula** — it's strongly
chip-dependent and non-linear, and differs a lot between the two SID revisions.
Treat these as ballpark only, and tune by ear:

| Chip | Cutoff range | Rough behaviour |
|---|---|---|
| 6581 (old) | ~30 Hz – 12 kHz | Very non-linear; low end barely moves, steep curve high up |
| 8580 (new) | ~0 – 12.5 kHz | Closer to linear, ≈ `FC × 6 Hz` as a first guess |

Approximate cutoff for the high byte (FC_LO = 0), 8580-ish:

| FC_HI | FC | ≈ Hz |
|---:|---:|---:|
| 0   | 0    | ~30 |
| 32  | 256  | ~1.5 k |
| 64  | 512  | ~3 k |
| 128 | 1024 | ~6 k |
| 192 | 1536 | ~9 k |
| 255 | 2040 | ~12 k |

For musical sweeps, just ramp `FC_HI` (`$D416`) and listen — the low 3 bits
(`$D415`) are fine-tune you can usually leave at 0.

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
