10 s = 54272
20 poke s+24,15 : rem volume = max
30 poke s+6,242 : rem sustain=15, release=2 ($f2)
40 poke s+1,17  : rem frequency high byte (pitch)
50 poke s+4,17  : rem triangle + gate on -> tone starts and holds
60 rem to stop: poke s+4,16 (gate off) or poke s+24,0 (volume off)
70 t = ti : rem get current system time
80 if ti < t + 20 then 80 : rem pause ~20 jiffies (about 1/3 second)
90 poke s+4,16 : rem gate off -> release the note
95 t = ti
100 if ti < t + 30 then 100 : rem pause ~30 jiffies (about 1/3 second)
110 poke s+1,20  : rem frequency high byte (pitch)
120 poke s+4,33  : rem triangle + gate on -> tone starts and holds
125 t = ti
130 if ti < t + 20 then 130 : rem pause ~20 jiffies (about 1/3 second)
140 poke s+4,16 : rem gate off -> release the note
150 t = ti
160 if ti < t + 30 then 160 : rem pause ~30 jiffies (about 1/3 second)
170 poke s+1,23  : rem frequency high byte (pitch)
180 poke s+4,1  : rem triangle + gate on -> tone starts and holds
190 t = ti
200 if ti < t + 20 then 200 : rem pause ~20 jiffies (about 1/3 second)
210 poke s+4,16 : rem gate off -> release the note
220 goto 40
