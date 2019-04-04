# TODO block size -> self

class ImageData:
    def __init__(self,stream,image_pixels,interlace,width):
      self.LZ_BITS         =12
      self.NOT_A_CODE      =4096
      self.pixels=image_pixels
      self.interlace=interlace

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
        fragment=stream.byte(self.block_size)
        if self.block_size==1:
          data+=[fragment]
        else:
          data+=fragment
        self.block_size=self.stream.byte()
      
      gif_index=self.lzw(self.LWZ_MIN_BYTE_SIZE,data,image_pixels)
      if interlace==True:
        gif_index=self.deinterlace(gif_index,width)
     
      self.data=gif_index
      self.end_pos=self.stream.pos
      self.stream=None
     
    def debug(self):
      print("ImageData")
      print("  Start Offset: {0:02X}".format(self.internal_position))
      print("  DataLength: {0:02X}".format(self.DataLength))
      print("  MIN_BYTE_SIZE: {0:02X}".format(self.LWZ_MIN_BYTE_SIZE))
      print("  Data Len: {0}".format(len(self.data)))
      print("  End Offset: {0:02X}".format(self.end_pos))
      #print("  Data: {0}".format(self.data))


    def lzw(self,minCodeSize, data,pixelCount) :
        MAX_STACK_SIZE = 4096
        nullCode = -1
        npix = pixelCount
       
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
        escape_index=1
        i=0
        while True:
            escape_index+=1
            if escape_index>npix*2:
                break

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
                    break
                
                if code == clear:
                    # Reset decoder.
                    code_size = data_size + 1
                    code_mask = (1 << code_size) - 1
                    available = clear + 2
                    old_code = nullCode
                    continue
                
                if old_code == nullCode:
                    pixelStack[top] = suffix[code]
                    top+=1
                    old_code = code
                    first = code
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

                if available < MAX_STACK_SIZE:
                    prefix[available] = old_code
                    suffix[available] = first
                    available+=1
                    if (available & code_mask) == 0 and available < MAX_STACK_SIZE:
                        code_size+=1
                        code_mask += available
                old_code = in_code
            
            top-=1
            dstPixels[pi] = pixelStack[top]
            pi+=1
            i+=1
        #print dstPixels
        return dstPixels

    def deinterlace(self,pixels, width):
        pixels_len=len(pixels)
        newPixels =[0]*pixels_len
        rows = pixels_len / width;
        fromRow = 0;

        offsets = [0,4,2,1];
        steps   = [8,8,4,2];
        for scan in range(0,4):
            for dest in range (offsets[scan],rows,steps[scan]):
                src=fromRow*width
                dst=dest*width
                fromPixels = pixels[src:src+width]
                newPixels[dst:dst+width]=fromPixels
                fromRow+=1
        return newPixels;
        