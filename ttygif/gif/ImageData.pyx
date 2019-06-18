# cython: linetrace=True
# cython: language_level=2
import bitarray

# TODO block size -> self

class ImageData:
    def __init__(self,stream):
        self.stream=stream
        self.internal_position=self.stream.pos


    def new(self,min_code_size=8,data=None):
        self.image_data=data
        self.min_code_size=min_code_size


    def write(self):

        if None==self.image_data or len(self.image_data)==0:
            raise Exception("Image data empty")
        #self.image_data=[0,1,2,3,4,5,6,7,8,9,10]
        byte_data=compress(self.image_data, self.min_code_size)
        byte_len=len(byte_data)
        #print ("LENGTH: {0}".format(byte_len))
        self.stream.write_byte(self.min_code_size)
        


        
        byte_data_length=len(byte_data)
        
        index=0
        #while byte_data_length>0:
        #    if byte_data_length>0xFF:
        #        length=255
        #    else:
        #         length=byte_data_length
        #    self.stream.write_byte(length)
        #    self.stream.write_bytes(byte_data[index:index+length])
        #    byte_data_length-=length
        
        for byte in byte_data:
            if index%255==0:
                if byte_data_length-index>=255:
                    length=255
                else:
                    length=byte_data_length-index
                self.stream.write_byte(length)    
            self.stream.write_byte(byte)
            index+=1
        self.stream.write_byte(0)
    
        

    def read(self,image_byte_length,interlace,width):
      self.internal_position = self.stream.pos
      self.LZ_BITS           = 12
      self.NOT_A_CODE        = 4096
      self.pixels            = image_byte_length
      self.interlace         = interlace
      self.LWZ_MIN_BYTE_SIZE = self.stream.byte()
      self.buffer            = 0
      self.bytes_in_buffer   = 0
      self.block_index       = 0
      self.block_size        = self.stream.byte()
      self.DataLength        = self.block_size

      gif_index=[]
      data=[]

      while self.block_size>0:
        fragment=self.stream.byte(self.block_size)
        if self.block_size==1:
          data+=[fragment]
        else:
          data+=fragment
        self.block_size=self.stream.byte()
      
      gif_index=self.lzw_decode(self.LWZ_MIN_BYTE_SIZE,data,image_byte_length)
      
      if interlace==True:
        gif_index=self.deinterlace(gif_index,width)
     
      self.data    =gif_index
      self.end_pos =self.stream.pos
     
    def debug(self):
      print("ImageData")
      #print("  Start Offset:  {0:02X}".format(self.internal_position))
      #print("  DataLength:    {0:02X}".format(self.DataLength))
      #print("  MIN_BYTE_SIZE: {0:02X}".format(self.LWZ_MIN_BYTE_SIZE))
      #print("  Data Len:      {0}".format(len(self.data)))
      #print("  End Offset:    {0:02X}".format(self.end_pos))


    def lzw_decode(self,minCodeSize, data,pixelCount) :
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
        



    

class Encode:
    def __init__(self):
        self.buf=[]

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
        print(cur_key)
        
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
      self.emit_code(self.eoi_code)
      self.emit_bytes_to_buffer(1)

      if self.cur_subblock + 1 == self.p:
        self.buf[self.cur_subblock] = 0
      else:
        self.buf[self.cur_subblock] = self.p - self.cur_subblock - 1
        self.buf[self.p] = 0
        self.p+=1
      



class LZWDecompressionTable(object):
    """LZW Decompression Code Table"""

    def __init__(self, lzw_min):
        self.lzw_min = lzw_min
        self.codes = None
        self.clear_code = None
        self.end_code = None
        self.next_code = None
        self.reinitialize()

    def reinitialize(self):
        """Re-initialize the code table.
        Should only be called (again) when you encounter a CLEAR CODE.
        """
        cdef int next_code = 2 ** self.lzw_min
        self.codes = self._make_codes(next_code)
        self.clear_code = self.codes[next_code] = next_code
        self.end_code = self.codes[next_code + 1] = next_code + 1
        self.next_code = next_code + 2

    def _make_codes(self, next_code):
        return {i: chr(i) for i in xrange(next_code)}

    def __contains__(self, key):
        try:
            if self.codes[key]:
                return key
        except:
            return None
        return key in self.codes

    def show(self):
        """Print the code table."""
        for key in sorted(self.codes):
            print (key, '|', repr(self.codes[key]))

    @property
    def code_size(self):
        """Returns the # bits required to represent the largest code so far."""
        return (self.next_code - 1).bit_length()

    @property
    def next_code_size(self):
        """Returns the # bits required to represent the next code."""
        return self.next_code.bit_length()

    def get(self, key):
        """Returns the code associated with key."""
        return self.codes[key]

    def add(self, value):
        """Maps the next largest code to value."""
        self.codes[self.next_code] = value
        self.next_code += 1


class LZWCompressionTable(LZWDecompressionTable):
    """LZW Compression Code Table"""

    def _make_codes(self, next_code):
        return {chr(i): i for i in xrange(next_code)}

    def add(self, key):
        """Maps key to the next largest code."""
        self.codes[key] = self.next_code
        self.next_code += 1


def compress(data, lzw_min, max_code_size=12):
    """Return compressed data using LZW."""
    table = LZWCompressionTable(lzw_min)

    def _compress():
        # Always emit a CLEAR CODE first
        yield table.get(table.clear_code)

        prev = ''
        for char in data:
            c=chr(char)
            if prev + c in table:
                prev += c
            else:
                yield table.get(prev)
                table.add(prev + c)
                prev = c

                if table.next_code_size > max_code_size:
                    yield table.get(table.clear_code)
                    table.reinitialize()

        if prev:
            yield table.get(prev)

        # Always emit an END OF INFORMATION CODE last
        yield table.get(table.end_code)

    # Pack variably-sized codes into bytes
    codes = bitarray.bitarray(endian='little')
    for code in _compress():
        # Convert code to bits, and append it
        #print code,table.code_size
        codes.extend(            bin(code)
                [2:].rjust(table.code_size, '0')[::-1])
    return codes.tobytes()

