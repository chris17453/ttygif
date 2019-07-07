
# -*- coding: utf-8 -*-


o=[]

bracketed_paste_end="\033[?2004l"
bracketed_paste_start="\033[?2004h"
start_nocode=u"\033[200~"
end_nocode=u"\033[201~"
print(bracketed_paste_start)

for i in range(0,128):
    o.append(u'{0}'.format(chr(i).decode('cp437')))     # 0X{0:02X}
    if i!=0:
        if i%32==0  or i==255:
                #print o
                print start_nocode , 
                print u"".join(o)
                print end_nocode ,
                print u"\r\n" , 
                o=[]

print(bracketed_paste_end)
