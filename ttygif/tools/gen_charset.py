

o=[]

for i in range(33,256):
    o.append(u"{0:03} 0X{0:02X} {1}".format(i,unichr(i)))   
    if i%8==0 or i==255:
        print u"  ".join(o)+"\r"
        o=[]
print u"  ".join(o)+"\r"
o=[]

