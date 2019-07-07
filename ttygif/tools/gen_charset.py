
# -*- coding: utf-8 -*-


o=[]

bracketed_paste_end="\033[?2004l"
bracketed_paste_start="\033[?2004h"
start_nocode=u"\033[200~"
end_nocode=u"\033[201~"
print(bracketed_paste_start)
o=[]
for i in range(0,256):
    o.append("{0:03} {1}".format(i,unichr(i)))
    if i!=0:
        if i%32==0  or i==255:
                #print o
                print start_nocode , 
                print u" | ".join(o).encode('latin-1'),
                print end_nocode ,
                print u"\r\n" , 
                o=[]

print(bracketed_paste_end)

#.decode('cp437')