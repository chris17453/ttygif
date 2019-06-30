# cython: profile=True
# cython: linetrace=True
# cython: binding=True
# cython: language_level=2

from cpython cimport array
from libc.string cimport memset
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
        while byte_data_length>0:
            if byte_data_length>0xFF:
                length=0xFF
            else:
                 length=byte_data_length
            self.stream.write_byte(length)
            self.stream.write_bytes(byte_data[index:index+length])
            byte_data_length-=length
            index+=length
        
        #for byte in byte_data:
        #    if index%255==0:
        #        if byte_data_length-index>=255:
        #            length=255
        #        else:
        #            length=byte_data_length-index
        #        self.stream.write_byte(length)    
        #    self.stream.write_byte(byte)
        #    index+=1
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
      

      self.data    =array.array('B',gif_index)
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
        rows = pixels_len / width
        fromRow = 0

        offsets = [0,4,2,1]
        steps   = [8,8,4,2]
        for scan in range(0,4):
            for dest in range (offsets[scan],rows,steps[scan]):
                src=fromRow*width
                dst=dest*width
                fromPixels = pixels[src:src+width]
                newPixels[dst:dst+width]=fromPixels
                fromRow+=1
        return newPixels
        




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











    



cdef class lzw_encode:
    cdef array.array image
    cdef int         width
    cdef int         height


    cdef int         bitIndex
    cdef int         byte
    cdef int         chunkIndex
    cdef int         data_index
    cdef array.array chunk
    cdef array_array compressed
    cdef int         min_code_size
    cdef int         bit_depth
    
    def __cinit__(self,array.array image,int width,int height):
      self.image      =image
      self.width      =width
      self.height     =height
      self.data_index =0
      self.bitIndex   =0
      self.byte       =0
      self.chunkIndex =0
      self.chunk      =array.array('B',[0]*256)
      self.compressed =array_array ('B')
      #compress the image and render to array
      self.min_code_size   =8
      self.bit_depth       =self.min_code_size
      self.compress()
    
    cdef increment_bit(self):
      self.bitIndex+=1
      if self.bitIndex > 7 :
        self.chunk[stat.chunkIndex] = stat.byte
        self.chunkIndex+=1
        self.bitIndex = 0
        self.byte = 0
  
  cdef write_bit(uint32_t bit):
      bit = bit & 1
      bit = bit << self.bitIndex
      self.byte |= bit
      self.increment_bit()


  cdef write_chunk(self):
      self.compressed.resize(self.chunkIndex+1)
      compressed_data[data_index]=chunkIndex
      data_index+=1
      for c in chunk:
        compressed_data[data_index]=c
        data_index+=1

      self.bitIndex   = 0
      self.byte       = 0
      self.chunkIndex = 0
  

  cdef write_code(uint32_t code, uint32_t length):
    for i in range (0,length):
        self.write_bit(code)
        code = code >> 1
        if self.chunkIndex == 255:
            self.write_chunk()

  # used to clear the incomplete bits of a chunk, end of line stuff
  cdef empyt_stream():
    while( self.bitIndex>0):
      self.write_bit(0)
    if self.chunkIndex>0:
      self.write_chunk()
    # reset counters
    self.bitIndex   = 0
    self.byte       = 0
    self.chunkIndex = 0
    

  cdef compress (self):
      cdef int y_offset
      cdef int image_pos
      cdef int minCodeSize =self.min_code_size
      cdef int clearCode = 1 << self.bit_depth

      fputc(minCodeSize, f)

      cdef array.array codetree = array.array('I')
      cdef int code_tree_len=2*256*4096
      array.resize(codetree,code_tree_len)
      memset(&codetree.data.data.as_uint,0,code_tree_len)

      
      cdef uint32_t curCode = -1
      cdef uint32_t codeSize = (uint32_t)minCodeSize + 1
      cdef uint32_t maxCode = clearCode+1


      self.write_code(clearCode, codeSize)
      
      #compression loop
      for y in range(0,height):
        y_offset=y*width
        for x in range(0,width):
              image_pos=y_offset+x
              uint8_t nextValue = image[image_pos]

              if curCode < 0:
                  curCode = nextValue
              elif codetree[curCode].m_next[nextValue] :
                  curCode = codetree[curCode].m_next[nextValue]
              else:
                  self.write_code((uint32_t)curCode, codeSize)
                  maxCode+=1
                  codetree[curCode].m_next[nextValue] = (uint16_t)maxCode;

                  if maxCode >= 1 << codeSize:
                      codeSize+=1
                  if maxCode == 4095:
                      self.write_code(learCode, codeSize)
                      memset(&codetree.data.data.as_uint,0,code_tree_len)
                      codeSize = (uint32_t)(minCodeSize + 1)
                      maxCode = clearCode+1
                  curCode = nextValue


      # end of loop cleanup
      self.write_code((uint32_t)curCode, codeSize)
      self.write_code(clearCode, codeSize)
      self.write_code(clearCode + 1, (uint32_t)minCodeSize + 1)
      self.empty_stream()
