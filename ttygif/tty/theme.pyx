# cython: profile=True
# cython: binding=True
# cython: language_level=2

from cpython cimport array
from image cimport rect
import os
import pickle




cdef class layer:
    def __cint__(self):
        self.z_index=0
        self.file=''
        self.mode=''
        self.outer=rect(0,0,0,0)
        self.inner=rect(0,0,0,0)


cdef class theme:
    
    def __cinit__(self,name):
        self.name=name
        self.background=0
        self.foreground=15
        self.default_background=0
        self.default_foreground=15
        self.palette=array.array('B')
        self.padding=rect(0,0,0,0)
        cdef int a,b,c,index
        index=0

        keys=[
        'background',
        'foreground',
        'default_foreground',
        'default_background',
        'padding_left',
        'padding_right',
        'padding_top',
        'padding_bottom',
        'layers',
        'colors',
        'depth',
        'file',
        'mode',
        'outer-left',
        'outer-top',
        'outer-right',
        'outer-bottom',
        'inner-left',
        'inner-top',
        'inner-right',
        'inner-bottom',]

        script_path = os.path.dirname(os.path.abspath( __file__ ))
        
        path=os.path.join(script_path,'themes',name+".theme")
        
        if os.path.exists(path)==False:
            raise Exception("Invalid theme file")
        print("Theme: {0}".format(name))
        theme_file=open(path) 
        theme_data=theme_file.readlines()

        layer=None
        section=''
        for line in theme_data:
            line=" ".join(line.split())
            line=line.strip()
            
            res=self.get_anyvar(line)
            if res ==None:
                continue

            key=res['key']
            value=None
            if 'value' in res:
                value=res['value']
                if value=='auto':
                    value='-1'

            else:
                if section=='layer':
                    if self.layer1==None:
                        self.layer1=layer
                    if self.layer2==None:
                        self.layer2=layer
                    if self.layer3==None:
                        self.layer3=layer
                    if self.layer4==None:
                        self.layer4=layer
                    if self.layer5==None:
                        self.layer5=layer
                    layer=None

                section=key


            if section=='':
                if   key=='background':
                    self.background=int(value)
                elif key=='foreground':
                    self.foreground=int(value)
                elif key=='default_foreground':
                    self.default_foreground=int(value)
                elif key=='default_background':
                    self.default_background=int(value)
                elif key=='padding_left':
                    self.padding.left=int(value)
                elif key=='padding_right':
                    self.padding.right=int(value)
                elif key=='padding_top':
                    self.padding.top=int(value)
                elif key=='padding_bottom':
                    self.padding.bottom=int(value)

            elif section=='layer':
                if   key=='layer':
                    layer=layer()
                elif key=='depth':
                    layer.depth=int(value)
                elif key=='file':
                    layer.file=value
                elif key=='mode':
                    layer.mode=value
                elif key=='outer-left':
                    layer.outer_left=int(value)
                elif key=='outer-top':
                    layer.outer_top=int(value)
                elif key=='outer-right':
                    layer.outer_right=int(value)
                elif key=='outer-bottom':
                    layer.outer_bottom=int(value)
                elif key=='inner-left':
                    layer.inner_left=int(value)
                elif key=='inner-top':
                    layer.inner_top=int(value)
                elif key=='inner-right':
                    layer.inner_right=int(value)
                elif key=='inner-bottom':
                    layer.inner_bottom=int(value)
            
            elif section=='colors':
                if key=='colors':
                    self.colors=int(res)
                    array.resize(self.palette,self.colors*3)
                    in_header=None
                else:
                    tokens=line.split(' ')
                    #print line,tokens
                    a=int(tokens[0])
                    b=int(tokens[1])
                    c=int(tokens[2])
                    self.palette[index+0]=a
                    self.palette[index+1]=b
                    self.palette[index+2]=c
                    index+=3
        print ("HI")
        print(pickle..dumps(self))
    
    def get_var(self,line,var):
        index=line.find(var)
        if index>=0:
            res=line[index+len(var):]
            res=res.strip()
            return res
        return None

    def get_anyvar(self,line):
        # return if line none
        if line==None:
            return None
        # return on empty
        if len(line)<1: return None
        # return if comment
        if line[0]=='#': return None
        
        line.strip()
        tokens=line.split()
        
        if   isinstance(tokens,list):
            if   len(tokens)==1:
                return {'key':tokens[0]}
            elif len(tokens)==2:
                return {'key':tokens[0],'value':tokens[1]}
        elif isinstance(tokens,str):
                return {'key':tokens}
        return None     