
# -*- coding: utf-8 -*-


o=[]

for i in range(32,256):
    if i==128 or i<31:
        o.append(u'{0}'.format(chr(32).decode('cp437')))     # 0X{0:02X}
    else:
        o.append(u'{0}'.format(chr(i).decode('cp437')))     # 0X{0:02X}
    if i!=0:
        if i%32==0  or i==255:
                #print o
                print u"".join(o)+u"\r"
                o=[]


