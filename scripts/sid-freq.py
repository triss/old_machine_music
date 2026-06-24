#!/usr/bin/env python3
"""SID oscillator frequency helper.

The SID oscillator frequency is:

    Fout = Fn * Fclk / 2^24

where Fn is the 16-bit value in the voice's FREQ LO/HI registers and Fclk is
the system clock (PAL 985248 Hz, NTSC 1022727 Hz). Fn is linear in pitch, so
each octave up simply doubles Fn.

Usage:
    scripts/sid-freq.py                 # note table, C1..B7 (PAL)
    scripts/sid-freq.py --ntsc          # same, NTSC clock
    scripts/sid-freq.py --note A4       # register value for a note name
    scripts/sid-freq.py --hz 440        # register value for a frequency
    scripts/sid-freq.py --reg 7493      # Hz + nearest note for a register value
"""
import argparse
import math

PAL = 985248
NTSC = 1022727
TWO24 = 1 << 24
NAMES = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']


def fn(freq, clock):
    """Register value (Fn) for a desired frequency in Hz."""
    return round(freq * TWO24 / clock)


def hz(n, clock):
    """Frequency in Hz for a register value Fn."""
    return n * clock / TWO24


def note_freq(midi):
    """Equal-tempered frequency for a MIDI note number (A4 = 69 = 440 Hz)."""
    return 440.0 * 2 ** ((midi - 69) / 12)


def note_name(midi):
    return NAMES[midi % 12] + str(midi // 12 - 1)


def nearest_note(freq):
    midi = round(69 + 12 * math.log2(freq / 440))
    return midi, note_name(midi), note_freq(midi)


def print_table(clock, lo_midi=24, hi_midi=95):
    """Note table from C1 (midi 24) to B7 (midi 95) by default."""
    print(f"{'note':5}{'Hz':>9}{'Fn':>7}{'hi':>5}{'lo':>5}  hex")
    for midi in range(lo_midi, hi_midi + 1):
        f = note_freq(midi)
        v = fn(f, clock)
        if v > 65535:
            print(f"{note_name(midi):5}{f:9.2f}   --- out of 16-bit range ---")
            continue
        print(f"{note_name(midi):5}{f:9.2f}{v:7d}{v >> 8:5d}{v & 255:5d}  ${v:04X}")


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--ntsc', action='store_true', help='use the NTSC clock')
    ap.add_argument('--note', help='note name e.g. A4, C#3 -> register value')
    ap.add_argument('--hz', type=float, help='frequency in Hz -> register value')
    ap.add_argument('--reg', type=int, help='register value -> Hz + nearest note')
    args = ap.parse_args()
    clock = NTSC if args.ntsc else PAL

    if args.note:
        name = args.note.strip().upper()
        # split trailing octave digit(s), allow negative not needed here
        i = len(name)
        while i > 0 and (name[i - 1].isdigit()):
            i -= 1
        pitch, octave = name[:i], int(name[i:])
        midi = NAMES.index(pitch) + (octave + 1) * 12
        f = note_freq(midi)
        v = fn(f, clock)
        print(f"{name}: {f:.2f} Hz -> Fn={v} (hi={v >> 8} lo={v & 255}) ${v:04X}")
    elif args.hz is not None:
        v = fn(args.hz, clock)
        _, nm, nf = nearest_note(args.hz)
        print(f"{args.hz} Hz -> Fn={v} (hi={v >> 8} lo={v & 255}) ${v:04X}; "
              f"nearest {nm} ({nf:.2f} Hz)")
    elif args.reg is not None:
        f = hz(args.reg, clock)
        _, nm, nf = nearest_note(f)
        print(f"Fn={args.reg} -> {f:.2f} Hz; nearest {nm} ({nf:.2f} Hz)")
    else:
        print(f"# {'NTSC' if args.ntsc else 'PAL'} clock = {clock} Hz\n")
        print_table(clock)


if __name__ == '__main__':
    main()
