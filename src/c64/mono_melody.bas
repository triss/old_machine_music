10 s = 54272
20 poke s+24,15 : rem volume = max
30 poke s+6,242 : rem sustain=15, release=2 ($f2)
35 poke s+2,0 : poke s+3,8 : rem pulse width 50% ($800) for the pulse note
40 poke s+1,17  : rem note 1 pitch (freq high byte)
50 poke s+4,17  : rem triangle + gate on
60 rem to stop: poke s+4,16 (gate off) or poke s+24,0 (volume off)
70 t = ti : rem get current system time
80 if ti < t + 20 then 80 : rem hold ~20 jiffies (about 1/3 second)
90 poke s+4,16 : rem triangle gate off -> release
95 t = ti
100 if ti < t + 30 then 100 : rem gap ~30 jiffies
110 poke s+1,20  : rem note 2 pitch
120 poke s+4,33  : rem sawtooth + gate on
125 t = ti
130 if ti < t + 20 then 130 : rem hold
140 poke s+4,32 : rem sawtooth gate off -> release
150 t = ti
160 if ti < t + 30 then 160 : rem gap
170 poke s+1,23  : rem note 3 pitch
180 poke s+4,65  : rem pulse + gate on
190 t = ti
200 if ti < t + 20 then 200 : rem hold
210 poke s+4,64 : rem pulse gate off -> release
220 goto 40
