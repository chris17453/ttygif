from .stream import DataStream
from .Header import Header
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
        self.header=header(self.stream)
        self.header.new()
        self.header.ScreenWidth  = width
        self.header.ScreenHeight = height
        self.global_color_table=None
        if default_palette or palette:
          self.add_gtc(palette=palette,default_palette=default_palette)


    # STEP 2 adding a global palette to the gif 
    def add_gtc(self,palette,default_palette=True):
        if palette or default_palette:
            self.global_color_table =ColorTable(self.stream)
            self.global_color_table.new(palette=palette)
            header.GlobalColorTableSize=0
            if len(self.global_color_table)>0: header.GlobalColorTableSize+=1
            if len(self.global_color_table)>2: header.GlobalColorTableSize+=1
            if len(self.global_color_table)>4: header.GlobalColorTableSize+=1
            if len(self.global_color_table)>8: header.GlobalColorTableSize+=1
            if len(self.global_color_table)>16: header.GlobalColorTableSize+=1
            if len(self.global_color_table)>32: header.GlobalColorTableSize+=1
            if len(self.global_color_table)>64: header.GlobalColorTableSize+=1
            if len(self.global_color_table)>128: header.GlobalColorTableSize+=1
            if header.GlobalColorTableSize==0:
              header.GlobalColorTableFlag=0
              

    def write(self):
        # auto computes packed values on write
        self.header.write()

        # write GTC if available
        if self.global_color_table:
          self.global_color_table.write()

        #process frames
        for frame in self.frames:
          if frame['type']=='GCE':
                if frame['gc']: 
                  frame['gc'].write()
                if frame['descriptor']:
                  frame['descriptor'].write()
                if frame['color_table']:
                  frame['color_table'].write()
                if frame['image']
                  frame['image'].write()

        # write terminator
        self.trailer=Trailer(self.stream)
        self.trailer.new()
        self.trailer.write()
        self.stream.close()



    def add_frame(self,disposal_method=0,delay=1, transparent=None,,top=0,left=0,width=None,Height=None):

        gce=GraphicsControlExtension(self.stream)
        gce.DelayTime            =delay
        if transparent:
          gce.ColorIndex           =transparent
          gce.TransparentColorFlag =0x01
        gce.DisposalMethod       =disposal_method
        #gce.UserInputFlag        =0x00
       
        descriptor=ImageDescriptor(self.stream)
        descriptor.new()
        descriptor.width

        self.Left     =0
        self.Top      =0
        self.Width    =320
        self.Height   =240
        # computed
        self.LocalColorTableFlag  =0
        self.InterlaceFlag        =0
        self.SortFlag             =0
        self.LocalColorTableSize  =0


            gc=self.load_graphics_control_extension()
            if gc:
                descriptor=None
                local_color_table=None
                imagedata=None
                info={'frame':frame,'type':'image','gc':gc,'descriptor':descriptor,'color_table':local_color_table,'image':imagedata}
                continue

            descriptor =self.load_image_descriptor()
            if descriptor:
                if descriptor.LocalColorTableFlag==True:
                    local_color_table=self.load_color_table(descriptor.NumberOfColorTableEntries)
                else:
                    local_color_table=None
                pixels=descriptor.Height*descriptor.Width
                imagedata=self.load_image_data(pixels,descriptor.InterlaceFlag,descriptor.Width)
                info['descriptor']=descriptor
                info['color_table']=local_color_table
                info['image']=imagedata
                self.frames.append(info)
            comment    =self.load_comment_extension()
            plain_text =self.load_plain_text_extension()
                self.frames.append({'frame':frame,'type':'text','data':plain_text})
            application=self.load_application_extension()
            trailer=self.load_trailer()
            if old_pos==self.stream.pos:






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
      


