
# -*- coding: utf-8 -*-


o=[]

bracketed_paste_end="\033[?2004l"
bracketed_paste_start="\033[?2004h"
start_nocode=u"\033[200~"
end_nocode=u"\033[201~"
print(bracketed_paste_start)
o=[u"{0:3}".format(0)]
for i in range(0,256):
    
    uch=u" {0}".format(unichr(i))
    o.append(uch )
    if len(o)==17 or i==255:
            print start_nocode , 
            print u"".join(o),
            print end_nocode ,
            print u"\r\n" , 
            o=[u"{0:3}".format(i)]
    

print(bracketed_paste_end)

#.decode('cp437')