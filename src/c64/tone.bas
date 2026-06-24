10 s = 54272
20 poke s+24,15 : rem volume = max
30 poke s+6,240 : rem sustain=15, release=0 ($f0)
40 poke s+1,17  : rem frequency high byte (pitch)
50 poke s+4,17  : rem triangle + gate on -> tone starts and holds
60 rem to stop: poke s+4,16 (gate off) or poke s+24,0 (volume off)
