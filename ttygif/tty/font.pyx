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
        self.charset=0
        self.offset=[0]*256


        script_path = os.path.dirname(os.path.abspath( __file__ ))

        font_file=open(os.path.join(script_path,'fonts',name+".fd")) 
        font_data=font_file.readlines()
        in_header=True
        char_data=None
        char_y=0
        self.graphic=array.array('B')
        print len(self.graphic)
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
                    self.pointsize=int(res)
                res=self.get_var(line,'height')
                if res:
                    self.height=int(res)
                    print ("Height: {0}".format(self.height))
                res=self.get_var(line,'ascent')
                if res:
                    self.ascent=int(res)
                res=self.get_var(line,'inleading')
                if res:
                    self.inleading=int(res)
                res=self.get_var(line,'exleading')
                if res:
                    self.exleading=int(res)
                res=self.get_var(line,'charset')
                if res:
                    self.charset=int(res)
                    in_header=None
            else:
                print "X",line
                if char_data:
                    print "C",line
                    for i in range(0,self.width):
                        c=line[i]
                        if c=='x':
                            pos=char*self.width*self.height+char_y*self.width+i
                            print pos,len(self.graphic)

                            self.graphic[pos]=1
                    if char_y==self.height:
                        char_data=None
                        char_y=0
                else:
                    res=self.get_var(line,'char')
                    if res:
                        char=int(res)
                        self.offset[char]=self.width*self.height

                    res=self.get_var(line,'width')
                    if res:
                        self.width=int(res)
                        print ("width: {0}".format(self.width))
                        char_data=True
                        char_y=0
                        print("Resizing {0}".format(len(self.graphic)+self.width*self.height))
                        array.resize(self.graphic,len(self.graphic)+self.width*self.height)

            
    
    def get_var(self,line,var):
        index=line.find(var)
        if index>=0:
            res=line[index+len(var):]
            res=res.strip()
            return res
        return None