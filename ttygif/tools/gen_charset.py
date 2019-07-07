
# -*- coding: utf-8 -*-


o=[]

bracketed_paste_end="\033[?2004l"
bracketed_paste_start="\033[?2004h"
start_nocode=u"\033[200~"
end_nocode=u"\033[201~"
print(bracketed_paste_start)
o=["{0:03} ".format(0)]
for i in range(0,256):
    
    o.append(unichr(i))
    
    if len(o)==17 or i==255:
        o.append(" {0:03}".format(i))
        print start_nocode , 
        print "".join(o).encode('latin-1'),
        print end_nocode ,
        print u"\r\n" , 
        o=["{0:03} ".format(i+1)]


print(bracketed_paste_end)

#.decode('cp437')