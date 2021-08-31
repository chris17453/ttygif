# cython: profile=True
# cython: binding=True
# cython: language_level=2

from cpython cimport array
from image cimport rect,point
import os
import types
from os.path import expanduser
from ..gif.decode import decode
from image import image
from libc.stdint cimport uint32_t, int64_t,uint16_t,uint8_t,int32_t,int16_t





cdef class layer:
    def __cinit__(self):
        self.z_index=0
        self.name=''
        self.file=None
        self.mode='scale'
        self.outer =rect(0,0,0,0)
        self.inner =rect(0,0,0,0)
        self.bounds=rect(0,0,0,0)
        self.dst   =rect(0,0,-1,-1)
        self.transparent=-1
        self.path  =None
        
        

    cdef load_file(self,array.array palette):
        cdef uint8_t[1] clear_1=[0]
        autoloader=None        
        # try the image given, otherwise tryin the layers folder in the module
        
        if self.path:
            if os.path.isdir(self.path)==True:
                path=os.path.join(self.path,'layers',self.file) 
                if os.path.exists(path)==False:
                    err="Invalid image file: {0}".format(path)
                    raise Exception(err)
        else:
            path=self.file

        cdef image temp_image
        underlay_image=decode(path)
        gif_raw=underlay_image.get()
        
        
        
        gif_width =gif_raw['header'].ScreenWidth
        gif_height=gif_raw['header'].ScreenHeight

        
        for frame in gif_raw['frames']:
            if frame['image']:
                attribs=frame['descriptor']
                
                # if not set auto set...
                if self.outer.top==0 and self.outer.left==0 and self.outer.right==0 and self.outer.bottom==0:
                    self.outer =rect(0,0,gif_width-1,gif_height-1)
                if self.bounds.top==0 and self.bounds.left==0 and self.bounds.right==0 and self.bounds.bottom==0:
                    self.bounds =rect(0,0,gif_width-1,gif_height-1)
        
                self.image=image(1,attribs.Width,attribs.Height,array.array('B',gif_raw['global_color_table'].colors),clear_1)
                self.image.data=frame['image'].data
                if frame['gc']==None:
                        self.image.transparent=-1
                else:
                    if frame['gc'].TransparentColorFlag==0:
                        self.image.transparent=-1
                    if frame['gc'].TransparentColorFlag==1:
                        self.image.transparent=frame['gc'].ColorIndex
                self.image.remap_image(palette,self.image.transparent)
                return
              


    cdef debug(self):
        print("Layer")
        print("  name:      {0}".format(self.name))
        print("  z_index:   {0}".format(self.z_index))
        print("  file:      {0}".format(self.file))
        print("  mode:      {0}".format(self.mode))
        print("copy-mode:   {0}".format(self.copy_mode))
        print("transparent: {0}".format(self.transparent))
        print("Outer: ")
        self.outer.debug()
        print("Inner: ")
        self.inner.debug()
        print("Bounds: ")
        self.bounds.debug()
        print("Dst: ")
        self.dst.debug()
        


cdef class theme:
    
    def __cinit__(self,name,width,height):
        self.width=width
        self.height=height
        self.name=name
        self.background=0
        self.foreground=15
        self.default_background=0
        self.default_foreground=15
        self.palette=array.array('B')
        self.padding=rect(0,0,0,0)
        self.transparent=-1
        self.title_x=45
        self.title_y=13
        self.title_background=self.background
        self.title_foreground=self.foreground
        self.title_font_size=1
        self.init()
    
    cdef update_layer(self, layer temp):

        temp.load_file(self.palette)


        cdef int total_width =self.width -1+self.padding.left+self.padding.right
        cdef int total_height=self.height-1+self.padding.top +self.padding.bottom

        # the source  rectangle's
        if temp.outer.left   <0: temp.outer.left    +=temp.image.dimentions.width 
        if temp.outer.top    <0: temp.outer.top     +=temp.image.dimentions.height
        if temp.outer.right  <0: temp.outer.right   +=temp.image.dimentions.width 
        if temp.outer.bottom <0: temp.outer.bottom  +=temp.image.dimentions.height

        if temp.inner.left   <0: temp.inner.left    +=temp.image.dimentions.width 
        if temp.inner.top    <0: temp.inner.top     +=temp.image.dimentions.height
        if temp.inner.right  <0: temp.inner.right   +=temp.image.dimentions.width 
        if temp.inner.bottom <0: temp.inner.bottom  +=temp.image.dimentions.height

        # the source  rectangle for COPY
        if temp.bounds.left  <0: temp.bounds.left   +=temp.image.dimentions.width 
        if temp.bounds.top   <0: temp.bounds.top    +=temp.image.dimentions.height
        if temp.bounds.right <0: temp.bounds.right  +=temp.image.dimentions.width 
        if temp.bounds.bottom<0: temp.bounds.bottom +=temp.image.dimentions.height

        # the destination rectangle
        if temp.dst.right     <0 : temp.dst.right     +=total_width
        if temp.dst.bottom    <0 : temp.dst.bottom    +=total_height
        if temp.dst.left      <0 : temp.dst.left      +=total_width
        if temp.dst.top       <0 : temp.dst.top       +=total_height

#temp.outer.get_x_percent(33)
#temp.outer.get_y_percent(33)
#temp.outer.get_x_percent(66)
#temp.outer.get_y_percent(33)


#     |--------------|
#     |l,t        r,t|
#     |              |
#     |              |
#     |l,b        r,b|
#     |--------------|

#     Dest
# n>=0 
#   l,t,r,b=exact positioning
# auto 
#   l,t,r,b=total width-1

# n<0, snaps to right,bottom with n padding
#   l,t,r,b=total width-1-n



        temp.outer.update()
        temp.inner.update()
        temp.bounds.update()
        temp.dst.update()




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
            path=os.path.join(self.name+".theme")
            if os.path.exists(path)==False:
            
                home = os.path.join(expanduser("~"),'.ttygif')
                path=os.path.join(home,'themes',self.name+".theme")
                self.path=home
            
                if os.path.exists(path)==False:
                    raise Exception("Invalid theme file")
  
        print(" - theme: {0}".format(self.name))
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
                section=key

                if value==None and section=='layer':
                    
                    theme_layer=layer()
                    theme_layer.path=self.path           

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
                else:
                    theme_layer=None        
                    

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
                elif key=='font':
                    self.font=value

            if section=='title':
                if   key=='x':
                    self.title_x=int(value)
                elif key=='y':
                    self.title_y=int(value)
                elif key=='foreground':
                    self.title_foreground=int(value)
                elif key=='background':
                    self.title_background=int(value)
                elif key=='font':
                    self.title_font=value
                elif key=='font_size':
                    self.title_font_size=float(value)

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
                if   key=='depth':
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
                elif key=='dst-right':
                    theme_layer.dst.right=int(value)
                elif key=='dst-bottom':
                    theme_layer.dst.bottom=int(value)
                elif key=='center':
                    theme_layer.center=value
                elif key=='copy-mode':
                    theme_layer.copy_mode=value
                elif key=='transparent':
                    theme_layer.transparent=int(value)
           

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
            
            

        if len(self.palette)==0:
            array.resize(self.palette,256*3)

            color_table=[  # 16 System Colors
                0,0,0 , 128,0,0 , 0,128,0 , 128,128,0,
                0,0,128 , 128,0,128 , 0,128,128 , 192,192,192,
                128,128,128 , 255,0,0 , 0,255,0 , 255,255,0,
                0,0,255 , 255,0,255 , 0,255,255 , 255,255,255,
                # xterm palette
                0,0,0 , 0,0,95 , 0,0,135 , 0,0,175 , 0,0,215 , 0,0,255,
                0,95,0 , 0,95,95 , 0,95,135 , 0,95,175 , 0,95,215 , 0,95,255,
                0,135,0 , 0,135,95 , 0,135,135 , 0,135,175 , 0,135,215 , 0,135,255,
                0,175,0 , 0,175,95 , 0,175,135 , 0,175,175 , 0,175,215 , 0,175,255,
                0,215,0 , 0,215,95 , 0,215,135 , 0,215,175 , 0,215,215 , 0,215,255,
                0,255,0 , 0,255,95 , 0,255,135 , 0,255,175 , 0,255,215 , 0,255,255,
                95,0,0 , 95,0,95 , 95,0,135 , 95,0,175 , 95,0,215 , 95,0,255,
                95,95,0 , 95,95,95 , 95,95,135 , 95,95,175 , 95,95,215 , 95,95,255,
                95,135,0 , 95,135,95 , 95,135,135 , 95,135,175 , 95,135,215 , 95,135,255,
                95,175,0 , 95,175,95 , 95,175,135 , 95,175,175 , 95,175,215 , 95,175,255,
                95,215,0 , 95,215,95 , 95,215,135 , 95,215,175 , 95,215,215 , 95,215,255,
                95,255,0 , 95,255,95 , 95,255,135 , 95,255,175 , 95,255,215 , 95,255,255,
                135,0,0 , 135,0,95 , 135,0,135 , 135,0,175 , 135,0,215 , 135,0,255,
                135,95,0 , 135,95,95 , 135,95,135 , 135,95,175 , 135,95,215 , 135,95,255,
                135,135,0 , 135,135,95 , 135,135,135 , 135,135,175 , 135,135,215 , 135,135,255,
                135,175,0 , 135,175,95 , 135,175,135 , 135,175,175 , 135,175,215 , 135,175,255,
                135,215,0 , 135,215,95 , 135,215,135 , 135,215,175 , 135,215,215 , 135,215,255,
                135,255,0 , 135,255,95 , 135,255,135 , 135,255,175 , 135,255,215 , 135,255,255,
                175,0,0 , 175,0,95 , 175,0,135 , 175,0,175 , 175,0,215 , 175,0,255,
                175,95,0 , 175,95,95 , 175,95,135 , 175,95,175 , 175,95,215 , 175,95,255,
                175,135,0 , 175,135,95 , 175,135,135 , 175,135,175 , 175,135,215 , 175,135,255,
                175,175,0 , 175,175,95 , 175,175,135 , 175,175,175 , 175,175,215 , 175,175,255,
                175,215,0 , 175,215,95 , 175,215,135 , 175,215,175 , 175,215,215 , 175,215,255,
                175,255,0 , 175,255,95 , 175,255,135 , 175,255,175 , 175,255,215 , 175,255,255,
                215,0,0 , 215,0,95 , 215,0,135 , 215,0,175 , 215,0,215 , 215,0,255,
                215,95,0 , 215,95,95 , 215,95,135 , 215,95,175 , 215,95,215 , 215,95,255,
                215,135,0 , 215,135,95 , 215,135,135 , 215,135,175 , 215,135,215 , 215,135,255,
                215,175,0 , 215,175,95 , 215,175,135 , 215,175,175 , 215,175,215 , 215,175,255,
                215,215,0 , 215,215,95 , 215,215,135 , 215,215,175 , 215,215,215 , 215,215,255,
                215,255,0 , 215,255,95 , 215,255,135 , 215,255,175 , 215,255,215 , 215,255,255,
                255,0,0 , 255,0,95 , 255,0,135 , 255,0,175 , 255,0,215 , 255,0,255,
                255,95,0 , 255,95,95 , 255,95,135 , 255,95,175 , 255,95,215 , 255,95,255,
                255,135,0 , 255,135,95 , 255,135,135 , 255,135,175 , 255,135,215 , 255,135,255,
                255,175,0 , 255,175,95 , 255,175,135 , 255,175,175 , 255,175,215 , 255,175,255,
                255,215,0 , 255,215,95 , 255,215,135 , 255,215,175 , 255,215,215 , 255,215,255,
                255,255,0 , 255,255,95 , 255,255,135 , 255,255,175 , 255,255,215 , 255,255,255,
                8,8,8 , 18,18,18 , 28,28,28 , 38,38,38 , 48,48,48 , 58,58,58 , 68,68,68,
                78,78,78 , 88,88,88 , 98,98,98 , 108,108,108 , 118,118,118 , 128,128,128,
                138,138,138 , 148,148,148 , 158,158,158 , 168,168,168 , 178,178,178 , 188,188,188,
                198,198,198 , 208,208,208 , 218,218,218 , 228,228,228 , 238,238,238 ]
            for i in range(256*3):
                self.palette[i]=color_table[i]

        self.auto()

        if 1==0:
            print("name:                {0}".format(self.name))
            print("background:          {0}".format(self.background))
            print("foreground:          {0}".format(self.foreground))
            print("default_background:  {0}".format(self.default_background))
            print("default_foreground:  {0}".format(self.default_foreground))
            print("colors:              {0}".format(self.colors))
            self.padding.debug()
            
            
        
            if self.layer1: self.layer1.debug();
            if self.layer2: self.layer2.debug();
            if self.layer3: self.layer3.debug();
            if self.layer4: self.layer4.debug();
            if self.layer5: self.layer5.debug();
            #exit(0)



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