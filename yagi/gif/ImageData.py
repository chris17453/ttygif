# TODO block size -> self

class ImageData:
  def __init__(self,stream,image_pixels):
      self.LZ_BITS         =12
      self.NOT_A_CODE      =4096
      #self.colors=colors
      # where the data is stored as its pulled out of the stream
      
      self.internal_position=stream.pos
      self.DataLength=0
      self.stream=stream
      self.LWZ_MIN_BYTE_SIZE=self.stream.byte()
      
      self.buffer=0
      self.bytes_in_buffer=0
      self.block_index=0
      #self.init_lookup_table()
      #self.get_first_code_in_data_sub_block()           # always an init table
      gif_index=[]
      self.block_size=self.stream.byte()
      self.DataLength+=self.block_size
      data=[]
      while self.block_size>0:
        print("READING {0}".format(self.block_size))
        
          
        fragment=stream.byte(self.block_size)
        if self.block_size==1:
          data+=[fragment]
        else:
          data+=fragment
        self.block_size=self.stream.byte()
        #print self.block_size
      gif_index=self.lzw(self.LWZ_MIN_BYTE_SIZE,data,image_pixels)
              

      
          #gif_index+=self.read_block()
          #self.init_lookup_table()
          #self.block_size=self.stream.byte()
          #self.DataLength+=self.block_size
          #self.block_index=0
          #self.buffer=0
          #self.bytes_in_buffer=0
      #print (self.stream.byte())
      self.data=gif_index
      self.end_pos=self.stream.pos
      self.stream=None
      self.lookup=None

  def debug(self):
      print("ImageData")
      print("  Start Offset: {0:02X}".format(self.internal_position))
      print("  DataLength: {0:02X}".format(self.DataLength))
      print("  MIN_BYTE_SIZE: {0:02X}".format(self.LWZ_MIN_BYTE_SIZE))
      print("  Data Len: {0}".format(len(self.data)))
      print("  End Offset: {0:02X}".format(self.end_pos))
      #print("  Data: {0}".format(self.data))

  def init_lookup_table(self):
      self.DATA_BIT_MIN_SIZE=1<<self.LWZ_MIN_BYTE_SIZE
      self.DATA_BIT_SIZE=self.LWZ_MIN_BYTE_SIZE+1
      self.CLEAR=1<<(self.LWZ_MIN_BYTE_SIZE)
      self.END_OF_INFORMATION=self.CLEAR+1
      self.set_max_code_size()
    
      self.lookup=[self.NOT_A_CODE]*(self.MAX_CODE_SIZE)
      for index in range(0,self.DATA_BIT_MIN_SIZE):
          self.lookup[index]=[index]
      self.next_table_index=self.END_OF_INFORMATION+1
      
  def set_max_code_size(self):
      self.MAX_CODE_SIZE=(1<<(self.DATA_BIT_SIZE))
      #print ("MAX CODE SIZE: {0}".format(self.MAX_CODE_SIZE))
  
  def get_first_code_in_data_sub_block(self):
      code=self.read_code()
      if code==self.CLEAR:
          self.init_lookup_table()
          #print ("Setting up new lookup table")
      else:
          raise Exception("First code data sub block should be a clear. LZW data is bad bro.")

  def add_code_list_to_lookup(self,code_list):
      if self.next_table_index==self.MAX_CODE_SIZE-1 and self.DATA_BIT_SIZE<self.LZ_BITS: #
          self.DATA_BIT_SIZE+=1
          #print ("Bit size increase: {0}".format(self.DATA_BIT_SIZE))
          self.set_max_code_size()
          #print ("MAXCODE: {0:02X}".format(self.MAX_CODE_SIZE))
          self.lookup=self.lookup+ [self.NOT_A_CODE]*(self.MAX_CODE_SIZE-len(self.lookup)+300)

      this_code_index=self.next_table_index
      #print("Table index",self.next_table_index)
      #print(self.next_table_index,len(self.lookup))
      self.lookup[self.next_table_index]=code_list
      #print (self.code_index,self.MAX_CODE_SIZE,code)
      self.next_table_index+=1
      return this_code_index

  def is_code_in_the_lookup(self,code):
      if self.lookup[code]==self.NOT_A_CODE:
          return None
      return True

  def read_code(self):
      # data mask based based on the curent bit state
      code_masks=[0x0000, 0x0001, 0x0003, 0x0007,0x000F, 0x001F, 0x003F, 0x007F,0x00FF, 0x01ff, 0x03FF, 0x07FF,0x0FFF]
      # if there isnt enough data in the byte buffer
      # grab another one
      # shift it by the shiift state
      # "or" it with the curent byte
      # now we have a buffer with enough data
      while self.bytes_in_buffer < self.DATA_BIT_SIZE and self.block_index<self.block_size:
          next_byte =self.stream.byte()
          
          # print ("Pulled: 0x{0:02x}".format(next_byte))
          self.buffer =self.buffer  | next_byte << self.bytes_in_buffer
          self.bytes_in_buffer += 8
          self.block_index+=1
      
      if self.bytes_in_buffer < self.DATA_BIT_SIZE :
          #print ("NO bits in buffer")
          return None
      code = self.buffer & code_masks[self.DATA_BIT_SIZE]
          
      # Shift the buffer by the number of bits extracted.
      self.buffer  >>= self.DATA_BIT_SIZE
      self.bytes_in_buffer-= self.DATA_BIT_SIZE
      
      return code

  def read_block(self):
      start_pos=self.stream.pos
      if self.debug:
          print("BLOCK SIZE: {0}".format(self.block_size))
      #Read first code
      code=self.read_code()
      gif_index=[code] 
      self.last_code=code
      while code!=None:
          # pull another code from the compressed srream
          code=self.read_code()
          if code==self.CLEAR:
              if self.debug:
                  print ("Processing CLEAR")
                  last_code=self.NOT_A_CODE
              self.init_lookup_table()
              continue

          elif code==self.END_OF_INFORMATION:
              if self.debug:
                  print ("Processing EOI")
              break
          if None ==code:
              if self.debug:
                  print ("LAST BIT")
              continue
          #if self.last_code>=len(self.lookup):
          #    raise Exception ("Last Code out of bounds: lookup length: {0}. Code: {1}".format(len(self.lookup),self.last_code))
          #
          #
          #if self.lookup[self.last_code]==self.NOT_A_CODE:
          #    raise Exception ("Last Code has no value: lookup length: {0}. Code: {1} , Next Code Index: {2}".format(len(self.lookup),self.last_code,self.next_table_index))
          # is the index in the lookup table?
          if self.debug:
              print("C{0}:LC{1},BI:{2},POS:{3:02X}".format(code,self.last_code,self.block_index,self.stream.pos))
          if self.last_code==self.NOT_A_CODE:
              print "EH"
              print "EH"
              print "EH"
              print "EH"
              print "EH"
              print "EH"
              
          if self.is_code_in_the_lookup(code):
              #if code>=len(self.lookup):
              #    raise Exception ("Code out of bounds: lookup length: {0}. Code: {1}".format(len(self.lookup),code))
          
              #if self.lookup[code]==self.NOT_A_CODE:
              #    raise Exception ("Code has no value: lookup length: {0}. Code: {1}, Next Code Index: {2}".format(len(self.lookup),code,self.next_table_index))

              gif_index+=self.lookup[code]
              prefix=self.lookup[code][0]
              new_code=self.lookup[self.last_code]+[prefix]
          else:
              print(self.lookup)

              prefix=self.lookup[self.last_code][0]
              new_code=self.lookup[self.last_code]+[prefix]
              gif_index+=new_code
          self.add_code_list_to_lookup(new_code)
          self.last_code=code
      
      end_pos=self.stream.pos
      return gif_index
      
      #print ("Start: {0:02X},End: {1:02X},Span:{2:02X}, Block Index:{3:02X}".format(start_pos,end_pos,end_pos-start_pos,self.block_index))
  

  def lzw(self,minCodeSize, data,pixelCount) :
      MAX_STACK_SIZE = 4096
      nullCode = -1
      npix = pixelCount
      # available, clear, code_mask, code_size, end_of_information, in_code, old_code, bits, code, i, datum, data_size, first, top, bi, pi;

      dstPixels =[0] * pixelCount
      prefix = [nullCode] * MAX_STACK_SIZE
      suffix = [nullCode] * MAX_STACK_SIZE
      pixelStack = [0]* (MAX_STACK_SIZE + 1)

      # Initialize GIF data stream decoder.
      data_size = minCodeSize
      clear = 1 << data_size
      end_of_information = clear + 1
      available = clear + 2
      old_code = nullCode
      code_size = data_size + 1
      code_mask = (1 << code_size) - 1
      
      for code in range(0, clear):
          prefix[code] = 0
          suffix[code] = code
      

      # Decode GIF pixel stream.
      datum = 0
      bits  = 0
      count = 0
      first = 0
      top   = 0
      pi    = 0
      bi    = 0
      for i in range (0,npix):
          #print(i)
          if top == 0:
              if bits < code_size:
                  # get the next byte			
                  byte=data[bi]
                  datum += byte << bits
                  bits += 8
                  bi+=1
                  continue
              
              # Get the next code.
              code = datum & code_mask
              datum >>= code_size
              bits -= code_size
              # Interpret the code
              if code > available or code == end_of_information :
                print ("EOI Found")
                break
              
              if code == clear:
                # Reset decoder.
                code_size = data_size + 1
                code_mask = (1 << code_size) - 1
                available = clear + 2
                old_code = nullCode
                print ("Clear Found")
                continue
              
              if old_code == nullCode:
                  pixelStack[top] = suffix[code]
                  top+=1
                  old_code = code
                  first = code
                  print("Old==Null")
                  continue
              
              in_code = code
              if code == available:
                  pixelStack[top] = first
                  top+=1
                  code = old_code

              while code > clear:
                  pixelStack[top] = suffix[code]
                  top+=1
                  code = prefix[code]
              
              first = suffix[code] & 0xff
              pixelStack[top] = first
              top+=1

              # add a new string to the table, but only if space is available
              # if not, just continue with current table until a clear code is found
              # (deferred clear code implementation as per GIF spec)
              if available < MAX_STACK_SIZE:
                  prefix[available] = old_code
                  suffix[available] = first
                  available+=1
                  if (available & code_mask) == 0 and available < MAX_STACK_SIZE:
                      code_size+=1
                      code_mask += available
              old_code = in_code
          
          # Pop a pixel off the pixel stack.
          top-=1
          dstPixels[pi] = pixelStack[top]
          pi+=1
          i+=1
      print ("HI")
      return dstPixels