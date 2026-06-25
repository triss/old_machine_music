 10 rem sounds organised by lines and bloody gotos. 
 20 rem hopefully sequenced by a few DIM'd arrays
 30 dim hf(6) : hf(0) = 17 : hf(1) = 19 : hf(2) = 20 : hf(3) = 17 : hf(4) = 25
 31 hf(5) = 20
 35 dim lf(6) : lf(0) = 103 : lf(1) = 137 : lf(2) = 178 : lf(3) = 103 : lf(4) = 59 : rem freq low bytes for exact tuning
 36 lf(5) = 178
 40 dim vs(3) : vs(0) = 54272 : vs(1) = 54279 : vs(2) = 54286
 50 poke vs(0)+24,31 : rem max volume, low pass filter
 60 poke vs(0)+22,10
 60 poke vs(0)+23,135
 70 for i=0 to 2 
 80 poke vs(i)+6,240 
 90 poke vs(i)+1,hf(3+i)
 95 poke vs(i),lf(3+i)
100 poke vs(i)+4,17
120 next
130 for f=0 to 30
140 t = ti
150 if ti - t < 1  goto 150
160 poke vs(0)+22,f
170 next
180 for f=0 to 30
190 t = ti
200 if ti - t < 3  goto 200
210 poke vs(0)+22,30-f
220 print 30-f
230 next
240 goto 130
