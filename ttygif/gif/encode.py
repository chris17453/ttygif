from .stream import DataStream
from .header import gif_header
from .ImageDescriptor import ImageDescriptor
from .ImageData import ImageData
from .GraphicsControlExtension import GraphicsControlExtension
from .ApplicationExtension import ApplicationExtension
from .CommentExtension import CommentExtension
from .PlainTextExtension import PlainTextExtension
from .Trailer import Trailer
from .ColorTable import ColorTable



class encode_gif:
    def __init__(self):
        self.stream=stream
        self.header =None
        self.global_color_table=None
  
    def write(self):
        # auto computes packed values on write
        self.header.write()

        # write GTC if available
        if self.global_color_table:
          self.global_color_table.write()

        #process frames
        for frame in self.frames:
            if frame['gce']: 
              frame['gce'].write()
            if frame['descriptor']:
              frame['descriptor'].write()
            if frame['color_table']:
              frame['color_table'].write()
            if frame['image']:
              frame['image'].write()

        # write terminator
        self.trailer=Trailer(self.stream)
        self.trailer.new()
        self.trailer.write()
        self.stream.close()


  
    def create(self,filename,
            width,
            height,
            default_palette=True,
            palette=None):
        
        self.stream=DataStream(filename)
        
        self.add_header(width=width,height=height,default_palette=default_palettte)

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

    # STEP 2 adding a global palette to the gif 
    def add_ct(self,palette,default_palette=True):
        if palette or default_palette:
            color_table =ColorTable(self.stream)
            color_table.new(palette=palette)
            color_table_size=0
            if len(color_table)>0  : color_table_size+=1
            if len(color_table)>2  : color_table_size+=1
            if len(color_table)>4  : color_table_size+=1
            if len(color_table)>8  : color_table_size+=1
            if len(color_table)>16 : color_table_size+=1
            if len(color_table)>32 : color_table_size+=1
            if len(color_table)>64 : color_table_size+=1
            if len(color_table)>128: color_table_size+=1
            if color_table_size==0:
              color_table_flag=0
            else:
              color_table_flag=1

        return {'table':color_table,
                'flag':color_table_flag,
                'size':color_table_size }
        
    
    
    def add_frame(self,disposal_method=0,delay=1, transparent=None,top=0,left=0,width=None,Height=None,palette=None,image_data=None):
        if None==width:
            width=self.header.ScreenWidth
        if None==Height:
            height=self.header.ScreenHeight


        gce=GraphicsControlExtension(self.stream)
        gce.new(    DelayTime=delay,
                    ColorIndex=transparent,
                    DisposalMethod=disposal_method)

        descriptor=ImageDescriptor(self.stream)

        if palette:
            res=self.add_ct(palette)
            local_color_table    = res['table']
            LocalColorTableSize  = res['size']
            LocalColorTableFlag  = res['flag']

        else:
            local_color_table= None
            LocalColorTableFlag =0
            LocalColorTableSize =0
        
        descriptor.new(left=left,top=top,width=width,height=height,LocalColorTableFlag=LocalColorTableFlag,LocalColorTableSize=LocalColorTableSize)
        
        image_data=None
        #e=Encode()
        #data_buffer=[]
        #image_data=data['data']
        #min_code_size=8
        #data_buffer=e.compress(min_code_size,[4,3,2,65,76,5,47,65,7,65,47,6,5,4,7,65,47,65,47,6,5,65,43,5,34,15,3,24,32,14,2,31,42,31,4])
            

        self.frames.append({'gce':gce,'descriptor':descriptor,'color_table':local_color_table,'image':image_data})




class Encode:
    def __init__(self):
        x=1

    def emit_bytes_to_buffer(self,bit_block_size):
        while self.cur_shift >= bit_block_size:
          self.buf.append(self.cur & 0xff)
          self.p+=1
          self.cur >>= 8;
          self.cur_shift -= 8;
          if self.p == self.cur_subblock + 256:
            self.buf[self.cur_subblock] = 255
            self.cur_subblock = self.p
            self.p+=1

    def emit_code(self,c):
        self.cur |= c << self.cur_shift
        self.cur_shift += self.cur_code_size
        self.emit_bytes_to_buffer(8)
    

    def compress(self,min_code_size,index_stream):

      self.buf=[min_code_size]
      self.p=1
      self.cur_subblock = self.p
      self.p+=1

      self.clear_code = 1 << min_code_size
      self.code_mask = self.clear_code - 1
      self.eoi_code = self.clear_code + 1
      self.next_code = self.eoi_code + 1
      self.cur_code_size = min_code_size + 1
      self.cur_shift = 0
      self.cur = 0


      ib_code = index_stream[0] & self.code_mask
      code_table = [4096]*4095
      for ct in range(0,256):
        code_table[ct]=ct

      self.emit_code(self.clear_code);
      # length of pixel data
      il=len(index_stream)
      for i in range (1,il):
        k = index_stream[i] & self.code_mask
        cur_key = ib_code << 8 | k
        print cur_key
        
        if code_table[cur_key]==4096: # TODO
          self.cur |= ib_code << self.cur_shift
          self.cur_shift += self.cur_code_size
          while self.cur_shift >= 8:
            self.buf.append(self.cur & 0xff)
            self.p+=1
            self.cur >>= 8;
            self.cur_shift -= 8;
            if self.p == self.cur_subblock + 256:
              self.buf[self.cur_subblock] = 255
              self.cur_subblock = self.p
              self.p+=1

          if self.next_code == 4096:
              self.emit_code(self.clear_code)
              self.next_code = self.eoi_code + 1
              self.cur_code_size = min_code_size + 1
              code_table = [4096]*4095
              for ct in range(0,256):
                code_table[ct]=ct

          else:
            code_table[cur_key] = self.next_code
            self.next_code+=1

          ib_code = k
        else:
          #print cur_key,code_table
          cur_code=code_table[cur_key]
          ib_code = cur_code

      self.emit_code(ib_code)
      self.emit_code(eoi_code)
      self.emit_bytes_to_buffer(1)

      if self.cur_subblock + 1 == self.p:
        self.buf[self.cur_subblock] = 0
      else:
        self.buf[self.cur_subblock] = self.p - self.cur_subblock - 1
        self.buf[self.p] = 0
        self.p+=1
      


