

# -*- coding: utf-8 -*-
import sys

name=sys.argv[1]
o=[]
bracketed_paste_end="\033[?2004l"
bracketed_paste_start="\033[?2004h"
start_nocode=u"\033[200~"
end_nocode=u"\033[201~"
#print bracketed_paste_start.encode('latin-1'),

print ""
print(bracketed_paste_start+" Font: {0}\r".format(name))


o=[" {0:03} ".format(0)]
for i in range(0,256):
    o.append(unichr(i))
    if len(o)==64+1 or i==255:
        o.append(" {0:03}".format(i))
        print start_nocode.encode('latin-1')+ "".join(o).encode('latin-1') + end_nocode.encode('latin-1'),
        print u"\n\r", 
        o=[" {0:03} ".format(i+1)]

print bracketed_paste_end +"\r",