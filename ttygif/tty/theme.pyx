# cython: profile=True
# cython: binding=True
# cython: language_level=2

from cpython cimport array
from image cimport rect,point
import os
import types
from os.path import expanduser
from ..gif.decode import decode




cdef class layer:
    def __cinit__(self):
        self.z_index=0
        self.name=''
        self.file=''
        self.mode=''
        self.outer =rect(0,0,0,0)
        self.inner =rect(0,0,0,0)
        self.bounds=rect(0,0,0,0)
        self.dst   =point(0,0)
        
        

    cdef load_file(self,path):
        path=os.path.join(path,'layers',self.file) 
        if os.path.exists(path)==False:
            raise Exception("Invalid image file")

        underlay_image=decode(path)
        gif_raw=underlay_image.get()
        for frame in gif_raw['frames']:
            if frame['image']:
                atrribs=frame['descriptor']
                self.image=image(1,atrribs.Width,atrribs.Height,array.array('B',gif_raw['global_color_table'].colors),0)
                self.image.data=frame['image'].data
                if frame['gc'].TransparentColorFlag==0:
                    self.image.transparent=-1
                if frame['gc'].TransparentColorFlag==1:
                    self.image.transparent=frame['gc'].ColorIndex


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
        print("Bounds: ")
        self.bounds.debug()
        print("Dst: ")
        self.dst.debug()
        


cdef class theme:
    
    def __cinit__(self,name):
        self.name=name
        self.background=0
        self.foreground=15
        self.default_background=0
        self.default_foreground=15
        self.palette=array.array('B')
        self.padding=rect(0,0,0,0)
        self.transparent=-1
        self.init()
    
    cdef update_layer(self, layer temp):

        temp.load_file(self.path)
        if temp.outer.left   ==-1: temp.outer.left=self.padding.left
        if temp.outer.top    ==-1: temp.outer.top=self.padding.top
        if temp.outer.right  ==-1: temp.outer.right=temp.image.dimentions.width-1
        if temp.outer.bottom ==-1: temp.outer.bottom=temp.image.dimentions.height-1
        if temp.inner.left   ==-1: temp.inner.left=temp.outer.get_x_percent(33)
        if temp.inner.top    ==-1: temp.inner.top=temp.outer.get_y_percent(33)
        if temp.inner.right  ==-1: temp.inner.right=temp.outer.get_x_percent(66)
        if temp.inner.bottom ==-1: temp.inner.bottom=temp.outer.get_y_percent(33)
        if temp.bounds.left  ==-1: temp.bounds.left=0
        if temp.bounds.top   ==-1: temp.bounds.top=0
        if temp.bounds.right ==-1: temp.bounds.right  =temp.image.dimentions.width-1
        if temp.bounds.bottom==-1: temp.bounds.bottom =temp.image.dimentions.height-1
        if temp.dst.left     ==-1: temp.dst.left      =(temp.bounds.right-temp.bounds.left)*-1
        if temp.dst.top      ==-1: temp.dst.top       =(temp.bounds.bottom-temp.bounds.top)*-1
        temp.outer.update()
        temp.inner.update()
        temp.bounds.update()


    cdef auto(self):
        if self.layer1:
            self.update_layer(self.layer1)

        if self.layer2:
            self.update_layer(self.layer2)

        if self.layer3:
            self.update_layer(self.layer3)

        if self.layer4:
            self.update_layer(self.layer4)

        if self.layer5:
            self.update_layer(self.layer5)

    cdef init(self):
        cdef int a,b,c,index
        index=0

        script_path = os.path.dirname(os.path.abspath( __file__ ))
        self.path=script_path
        path=os.path.join(script_path,'themes',self.name+".theme")
        if os.path.exists(path)==False:
        
            home = os.path.join(expanduser("~"),'.ttygif')
            path=os.path.join(home,'themes',self.name+".theme")
            self.path=home
        
            if os.path.exists(path)==False:
                raise Exception("Invalid theme file")
  
        print("Theme: {0}".format(self.name))
        theme_file=open(path) 
        theme_data=theme_file.readlines()

        cdef layer theme_layer=None
        section=''
  
  
        for line in theme_data:
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
                    self.auto()
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
                elif key=='transparent':
                    self.transparent=int(value)
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
                elif key=='left':
                    theme_layer.bounds.left=int(value)
                elif key=='top':
                    theme_layer.bounds.top=int(value)
                elif key=='right':
                    theme_layer.bounds.right=int(value)
                elif key=='bottom':
                    theme_layer.bounds.bottom=int(value)
                elif key=='dst-left':
                    theme_layer.dst.left=int(value)
                elif key=='dst-top':
                    theme_layer.dst.top=int(value)
           

            elif section=='palette':
                if   key=='palette':
                    continue
                elif key=='colors':
                    self.colors=int(value)
                    array.resize(self.palette,self.colors*3)
                if key=='array':
                    #tokens=line.split(' ')
                    #print line,tokens
                    a=int(value[0])
                    b=int(value[1])
                    c=int(value[2])
                    self.palette[index+0]=a
                    self.palette[index+1]=b
                    self.palette[index+2]=c
                    index+=3
    

        if 0==1:
            print("name:        {0}".format(self.name))
            print("background:  {0}".format(self.background))
            print("foreground:  {0}".format(self.foreground))
            print("default_background:  {0}".format(self.default_background))
            print("default_foreground:  {0}".format(self.default_foreground))
            print("colors:              {0}".format(self.colors))
            self.padding.debug()
            
        
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
        
        if not line: return None
        
        line=" ".join(line.split() )
        tokens=line.split()
        
        if   isinstance(tokens,list):
            if   len(tokens)==1:
                return {'key':tokens[0]}
            elif len(tokens)==2:
                return {'key':tokens[0],'value':tokens[1]}
            elif len(tokens)>2:
                return {'key':'array','value':tokens}
        elif isinstance(tokens,str):
                return {'key':tokens}
        return None     