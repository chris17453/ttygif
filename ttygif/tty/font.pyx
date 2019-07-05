# cython: profile=True
# cython: linetrace=True
# cython: binding=True
# cython: language_level=2

from cpython cimport array
import os

cdef class font:
    def __cinit__(self,name):
        self.name=name
        self.pointsize=0
        self.height=0
        self.width=0
        self.ascent=0
        self.inleading=0
        self.exleading=0
        self.offset=[0]*256


        script_path = os.path.dirname(os.path.abspath( __file__ ))

        font_file=open(os.path.join(script_path,'fonts',name+".fd")) 
        font_data=font_file.readlines()
        in_header=True
        char_data=None
        char_y=0
        self.graphic=array.array('B')
        for line in font_data:
            #print line
            line=line.strip()
            if not line:
                char_data=None
                char_y=0
                continue
            if in_header:
                if line[0]=='#':
                    continue
                res=self.get_var(line,'pointsize')
                if res:
                    pointsize=int(res)
                res=self.get_var(line,'height')
                if res:
                    height=int(res)
                res=self.get_var(line,'ascent')
                if res:
                    ascent=int(res)
                res=self.get_var(line,'inleading')
                if res:
                    inleading=int(res)
                res=self.get_var(line,'exleading')
                if res:
                    exleading=int(res)
                res=self.get_var(line,'charset')
                if res:
                    charset=int(res)
                    in_header=None
            else:
                print "X",line
                if char_data:
                    print "C",line
                    for i in range(0,width):
                        c=line[i]
                        if c=='x':
                            self.graphic[char*width*height+char_y*width]=1
                    char+=1
                    if char_y==height:
                        char_data=None
                else:
                    res=self.get_var(line,'char')
                    if res:
                        char=int(res)
                        self.offset[char]=self.width*self.height

                    res=self.get_var(line,'width')
                    if res:
                        width=int(res)
                        char_data=True
                        char_y=0

            
    
    def get_var(self,line,var):
        index=line.find(var)
        if index>=0:
            res=line[index+len(var):]
            res=res.strip()
            return res
        return None