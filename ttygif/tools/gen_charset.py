
# -*- coding: utf-8 -*-


o=[]

bracketed_paste_end="\033[?2004l"
bracketed_paste_start="\033[?2004h"
start_nocode=u"\033[200~"
end_nocode=u"\033[201~"
print(bracketed_paste_start)
o=u""
for i in range(0,256):
    o+=unichr(i)
    if i!=0:
        if i%32==0  or i==255:
                #print o
                print start_nocode , 
                print o.encode('latin-1'),
                print end_nocode ,
                print u"\r\n" , 
                o=u""

print(bracketed_paste_end)

#.decode('cp437')