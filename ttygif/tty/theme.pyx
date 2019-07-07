# cython: profile=True
# cython: binding=True
# cython: language_level=2

from cpython cimport array
import os

cdef class theme:
    
    def __cinit__(self,name):
        self.name=name
        self.background=0
        self.foreground=15
        self.default_background=0
        self.default_foreground=15
        self.palette=array.array('B')
        array.resize(self.palette,256*3)
        cdef int a,b,c        

        script_path = os.path.dirname(os.path.abspath( __file__ ))
        
        path=os.path.join(script_path,'themes',name+".theme")
        
        if os.path.exists(path)==False:
            raise Exception("Invalid theme file")
        
        font_file=open(path) 
        font_data=font_file.readlines()
        in_header=True
        self.graphic=array.array('B')
        for line in font_data:
            #print line
            line=line.strip()
            if not line:
                continue
            if in_header:
                if line[0]=='#':
                    continue
                res=self.get_var(line,'background')
                if res:
                    self.pointsize=int(res)
                res=self.get_var(line,'foreground')
                if res:
                    self.height=int(res)
                    print ("Height: {0}".format(self.height))
                res=self.get_var(line,'default_foreground')
                if res:
                    self.ascent=int(res)
                res=self.get_var(line,'default_background')
                if res:
                    self.inleading=int(res)

                res=self.get_var(line,'colors')
                if res:
                    self.colors=int(res)
                    in_header=None
            else:
                    tokens=line.split(' ')
                    a=int(tokens[0])
                    b=int(tokens[1])
                    c=int(tokens[2])
                    self.palette[index+0]=a
                    self.palette[index+2]=b
                    self.palette[index+3]=c
                    index+=3
    
    def get_var(self,line,var):
        index=line.find(var)
        if index>=0:
            res=line[index+len(var):]
            res=res.strip()
            return res
        return None