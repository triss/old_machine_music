10 s = 54272
20 poke s+24,15 : rem volume = max
30 poke s+6,255 : rem sustain=15, release=15 ($ff)
40 poke s+1,17  : rem frequency high byte (pitch)
50 poke s+4,17  : rem triangle + gate on -> tone starts and holds
60 rem to stop: poke s+4,16 (gate off) or poke s+24,0 (volume off)
70 t = ti : rem get current system time
80 if ti < t + 20 then 80 : rem pause ~20 jiffies (about 1/3 second)
90 poke s+4,16 : rem gate off -> release the note
