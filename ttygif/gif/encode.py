# cython: profile=True
# cython: linetrace=True
# cython: binding=True
# cython: language_level=2


from .stream import DataStream
from .header import gif_header
from .image_descriptor import image_descriptor
from .image import image
from .graphics_control_extension import graphics_control_extension
from .application_extension import application_extension
from .CommentExtension import CommentExtension
from .PlainTextExtension import PlainTextExtension
from .trailer import trailer
from .color_table import gif_color_table



class encode_gif:
    def __init__(self,loop_count=0xFFFF,debug=None,auto=True):
        self.stream                 =None
        self.header                 =None
        self.global_color_table     =None
        self.loop_count             =loop_count
        self.application_extension  =None
        self.frames  =[]
        self.debug   =debug
        self.auto    =auto
  
    def write(self):
        if self.auto:
          return
        # auto computes packed values on write
        self.header.write()
        
        # write GTC if available
        if self.global_color_table:
          self.global_color_table.write()

          self.application_extension.write()
        
        #process frames
        for frame in self.frames:
            if frame['gce']: 
              frame['gce'].write()
              if self.debug: frame['gce'].debug()

            if frame['descriptor']:
              frame['descriptor'].write()
              if self.debug: frame['descriptor'].debug()

            if frame['color_table']:
              frame['color_table'].write()
              if self.debug: frame['color_table'].debug()
            
            if frame['image']:
              frame['image'].write()
              if self.debug: frame['image'].debug()

        # write terminator
        self.trailer.write()
        self.stream.close()

    def close(self):
      if self.auto:
        self.trailer.write()
        self.stream.close()

  
    def create(self,filename,
            width,
            height,
            default_palette=True,
            palette=None):

        self.stream=DataStream(filename,mode='w')
        
        self.add_header(width=width,height=height,palette=palette,default_palette=default_palette)

        # no extension means 1 loop
        # 0 = loop forever
        # any other number is loop + 1
        if self.loop_count!=1:
          self.application_extension=application_extension(self.stream)
          if self.loop_count!=0:
            self.loop_count-=1
          self.application_extension.new_netscape_block(loop_count=self.loop_count)
        
        if self.auto:
          if self.application_extension!=None:
            self.application_extension.write()
            if self.debug: self.application_extension.debug()
        
        self.frames=[]
        
        self.trailer=trailer(self.stream)
        self.trailer.new()

        # create the header
    # Step 1, create a header
    # auto adds a default palette or given palette
    def add_header(self,width=320,height=240,palette=None,default_palette=True):
        self.header=gif_header(self.stream)
        self.header.new()
        self.header.ScreenWidth  = width
        self.header.ScreenHeight = height
        self.global_color_table=None

        if default_palette or palette:
          res=self.add_ct(palette=palette,default_palette=default_palette)
          self.global_color_table             =res['table']
          self.header.GlobalColorTableSize    =res['size']
          self.header.GlobalColorTableFlag    =res['flag']
          self.header.pack()
        if self.debug:
          self.header.debug()
        if self.auto:
          self.header.write()
          if default_palette or palette:
            self.global_color_table.write()
            if self.debug: self.global_color_table.debug()


        
    # STEP 2 adding a global palette to the gif 
    def add_ct(self,palette,default_palette=True):
        if palette or default_palette:
            color_table =gif_color_table(self.stream)
            color_table.new(palette=palette)
            color_table_size=color_table.get_byte_size()
            if color_table_size==0:
              color_table_flag=0
            else:
              color_table_flag=1
        else:
          color_table=None
          color_table_flag=0
          color_table_size=0

        return {'table':color_table,
                'flag':color_table_flag,
                'size':color_table_size }
        
    
    
    def add_frame(self,disposal_method=0,delay=1, transparent=None,top=0,left=0,width=None,height=None,palette=None,image_data=None):
        if None==width:
            width=self.header.ScreenWidth
        if None==height:
            height=self.header.ScreenHeight


        gce=graphics_control_extension(self.stream)
        gce.new(    DelayTime=delay,
                    ColorIndex=transparent,
                    DisposalMethod=disposal_method)
        descriptor=image_descriptor(self.stream)
        

        if palette:
            res=self.add_ct(palette)
            local_color_table    = res['table']
            LocalColorTableSize  = res['size']
            LocalColorTableFlag  = res['flag']
        else:
            local_color_table= None
            LocalColorTableFlag =0
            LocalColorTableSize =0
        
        descriptor.new(Left=left,Top=top,Width=width,Height=height,LocalColorTableFlag=LocalColorTableFlag,LocalColorTableSize=LocalColorTableSize)

        
        imagedata=image(self.stream)
        imagedata.new(data=image_data,min_code_size=self.header.GlobalColorTableSize+1)

        if self.auto:
            if gce:
              gce.write()
              if self.debug: gce.debug()
            if descriptor:
              descriptor.write()
              if self.debug:  descriptor.debug()
            if local_color_table:
              local_color_table.write()
              if self.debug: local_color_table.debug()
            if imagedata:
              imagedata.write()
              if self.debug: imagedata.debug()



        self.frames.append({'gce':gce,'descriptor':descriptor,'color_table':local_color_table,'image':imagedata})



