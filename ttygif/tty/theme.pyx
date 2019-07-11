# cython: profile=True
# cython: binding=True
# cython: language_level=2

from cpython cimport array
from image cimport rect
import os
import types




cdef class layer:
    def __int__(self):
        self.z_index=0
        self.name=''
        self.file=''
        self.mode=''
        self.outer=rect(0,0,0,0)
        self.inner=rect(0,0,0,0)

    cdef debug(self):
        print("Layer")
        print("  name:    {0}".format(self.name))
        print("  z_index: {0}".format(self.z_index))
        print("  file:    {0}".format(self.file))
        print("  mode:    {0}".format(self.mode))
        print("Outer: ")
        self.outer.debug()
        print("Inner: ")
        self.inner.debug()
        


cdef class theme:
    
    def __cinit__(self,name):
        self.name=name
        self.background=0
        self.foreground=15
        self.default_background=0
        self.default_foreground=15
        self.palette=array.array('B')
        self.padding=rect(0,0,0,0)
        self.init()
     
    cdef init(self):
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
        
        path=os.path.join(script_path,'themes',self.name+".theme")
        
        if os.path.exists(path)==False:
            raise Exception("Invalid theme file")
        print("Theme: {0}".format(self.name))
        theme_file=open(path) 
        theme_data=theme_file.readlines()

        theme_layer=None
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
                        theme_layer.name="layer1"
                        self.layer1=theme_layer
                    elif self.layer2==None:
                        theme_layer.name="layer2"
                        self.layer2=theme_layer
                    elif self.layer3==None:
                        theme_layer.name="layer3"
                        self.layer3=theme_layer
                    elif self.layer4==None:
                        theme_layer.name="layer4"
                        self.layer4=theme_layer
                    elif self.layer5==None:
                        theme_layer.name="layer5"
                        self.layer5=theme_layer
                    theme_layer=None

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
            elif section=='padding':
                if   key=='left':
                    self.padding.left=int(value)
                elif key=='right':
                    self.padding.right=int(value)
                elif key=='top':
                    self.padding.top=int(value)
                elif key=='bottom':
                    self.padding.bottom=int(value)

            elif section=='layer':
                if   key=='layer':
                    theme_layer=layer()
                
                elif key=='depth':
                    theme_layer.z_index=int(value)
                elif key=='file':
                    theme_layer.file=value
                elif key=='mode':
                    theme_layer.mode=value
                elif key=='outer-left':
                    theme_layer.outer.left=int(value)
                elif key=='outer-top':
                    theme_layer.outer.top=int(value)
                elif key=='outer-right':
                    theme_layer.outer.right=int(value)
                elif key=='outer-bottom':
                    theme_layer.outer.bottom=int(value)
                elif key=='inner-left':
                    theme_layer.inner.left=int(value)
                elif key=='inner-top':
                    theme_layer.inner.top=int(value)
                elif key=='inner-right':
                    theme_layer.inner.right=int(value)
                elif key=='inner-bottom':
                    theme_layer.inner.bottom=int(value)
            
            elif section=='palette':
                if   key=='palette':
                    continue
                elif key=='colors':
                    self.colors=int(value)
                    array.resize(self.palette,self.colors*3)
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
    

        print("name:        {0}".format(self.name))
        print("background:  {0}".format(self.background))
        print("foreground:  {0}".format(self.foreground))
        print("default_background:  {0}".format(self.default_background))
        print("default_foreground:  {0}".format(self.default_foreground))
        print("colors:              {0}".format(self.colors))
        self.padding.debug()
        
        print self.layer1.inner.left
        print self.layer1.inner.top
        print self.layer1.inner.right
        print self.layer1.inner.bottom
        if self.layer1: self.layer1.debug();
        if self.layer2: self.layer2.debug();
        if self.layer3: self.layer3.debug();
        if self.layer4: self.layer4.debug();
        if self.layer5: self.layer5.debug();


    
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