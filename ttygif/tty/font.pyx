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
        
        path=os.path.join(script_path,'fonts',name+".fd")
        
        if os.path.exists(path)==False:
            raise Exception("Invalid font")
        
        font_file=open(path) 
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
                if char_data:
                    for i in range(0,self.width):
                        c=line[i]
                        pos=char*self.width*self.height+char_y*self.width+i
                        if c=='x':
                            self.graphic[pos]=1
                        else:
                            self.graphic[pos]=0
                    char_y+=1
                    if char_y==self.height:
                        char_data=None
                        char_y=0
                else:
                    res=self.get_var(line,'char')
                    if res:
                        char=int(res)
                        self.offset[char]=self.width*self.height*char
                    res=self.get_var(line,'width')
                    if res:
                        self.width=int(res)
                        char_data=True
                        char_y=0
                        array.resize(self.graphic,len(self.graphic)+self.width*self.height)

            
    
    def get_var(self,line,var):
        index=line.find(var)
        if index>=0:
            res=line[index+len(var):]
            res=res.strip()
            return res
        return None