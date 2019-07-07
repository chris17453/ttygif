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
        cdef int a,b,c,index
        index=0

        script_path = os.path.dirname(os.path.abspath( __file__ ))
        
        path=os.path.join(script_path,'themes',name+".theme")
        
        if os.path.exists(path)==False:
            raise Exception("Invalid theme file")
        
        theme_file=open(path) 
        theme_data=theme_file.readlines()
        in_header=True
        for line in theme_data:
            #print line
            line=" ".join(line.split())
            line=line.strip()
            if not line:
                continue
            if line[0]=='#':
                continue
            if in_header:
                res=self.get_var(line,'background')
                if res:
                    self.background=int(res)
                res=self.get_var(line,'foreground')
                if res:
                    self.foreground=int(res)
                res=self.get_var(line,'default_foreground')
                if res:
                    self.default_foreground=int(res)
                res=self.get_var(line,'default_background')
                if res:
                    self.default_background=int(res)

                res=self.get_var(line,'colors')
                if res:
                    self.colors=int(res)
                    in_header=None
            else:
                    tokens=line.split(' ')
                    print line,tokens
                    a=int(tokens[0])
                    b=int(tokens[2])
                    c=int(tokens[4])
                    self.palette[index+0]=a
                    self.palette[index+1]=b
                    self.palette[index+2]=c
                    index+=3
                    
    
    def get_var(self,line,var):
        index=line.find(var)
        if index>=0:
            res=line[index+len(var):]
            res=res.strip()
            return res
        return None