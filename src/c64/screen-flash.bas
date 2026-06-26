 10 sb = 53280 : bg = 53281 : fg = 646
 19 poke bg,0
 20 poke sb,int(rnd(ti)*16) : poke fg,int(rnd(ti)*16)
 30 t = ti
 40 print chr$(int(rnd(ti) * 50) + 148);
 50 if ti - t < 20 then goto 40
 60 goto 20
