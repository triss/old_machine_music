10 s = 54272
20 poke s+24,15 : rem volume = max
30 poke s+6,242 : rem sustain=15, release=2 ($f2)
40 poke s+2,0 : poke s+3,8 : rem pulse width 50% ($800) for the pulse note
50 poke s+1,17  : rem note 1 pitch (freq high byte)
60 poke s+4,17  : rem triangle + gate on
70 rem to stop: poke s+4,16 (gate off) or poke s+24,0 (volume off)
80 t = ti : rem get current system time
90 if ti < t + 20 then 90 : rem hold ~20 jiffies (about 1/3 second)
100 poke s+4,16 : rem triangle gate off -> release
110 t = ti
120 if ti < t + 30 then 120 : rem gap ~30 jiffies
130 poke s+1,20  : rem note 2 pitch
140 poke s+4,33  : rem sawtooth + gate on
150 t = ti
160 if ti < t + 20 then 160 : rem hold
170 poke s+4,32 : rem sawtooth gate off -> release
180 t = ti
190 if ti < t + 30 then 190 : rem gap
200 poke s+1,23  : rem note 3 pitch
210 poke s+4,65  : rem pulse + gate on
220 t = ti
230 if ti < t + 20 then 230 : rem hold
240 poke s+4,64 : rem pulse gate off -> release
250 goto 50
