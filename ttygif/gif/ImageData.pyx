# cython: profile=True
# cython: linetrace=True
# cython: binding=True
# cython: language_level=2

from cpython cimport array
from libc.stdint cimport uint32_t, int64_t,uint16_t,uint8_t,int32_t
from libc.string cimport memset
import bitarray

# TODO block size -> self

class ImageData:
    def __init__(self,stream):
        self.stream=stream
        self.internal_pos=self.stream.pos


    def new(self,min_code_size=8,data=None):
        self.image_data=data
        self.min_code_size=min_code_size


    def write(self):
        if None==self.image_data or len(self.image_data)==0:
            raise Exception("Image data empty")
        
        old=None
        #old=1
        
        if old:
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
        else:
          encoder=lzw_encode(self.image_data,self.min_code_size)
          self.stream.write_bytes(encoder.compressed)
          self.stream.hex(encoder.compressed)

        
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
        exit (0)

    def read(self,image_byte_length,interlace,width):
      self.internal_pos = self.stream.pos
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
      #print("  Start Offset:  {0:02X}".format(self.internal_pos))
      #print("  DataLength:    {0:02X}".format(self.DataLength))
      #print("  MIN_BYTE_SIZE: {0:02X}".format(self.LWZ_MIN_BYTE_SIZE))
      #print("  Data Len:      {0}".format(len(self.data)))
      #print("  End Offset:    {0:02X}".format(self.end_pos))


    def lzw_decode(self,min_code_size, data,pixelCount) :
        MAX_STACK_SIZE = 4096
        nullCode = -1
        npix = pixelCount
       
        dstPixels =[0] * pixelCount
        prefix = [nullCode] * MAX_STACK_SIZE
        suffix = [nullCode] * MAX_STACK_SIZE
        pixelStack = [0]* (MAX_STACK_SIZE + 1)

        # Initialize GIF data stream decoder.
        data_size = min_code_size
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
    cdef array.array chunk
    cdef array.array compressed
    cdef uint32_t     byte
    cdef uint32_t     bit_pos
    cdef uint32_t     chunk_pos
    cdef uint32_t     data_pos
    cdef uint32_t     min_code_size
    cdef uint32_t     code_size
    
    def __cinit__(self,array.array image,min_code_size):
      self.image      =image
      self.byte      = 0
      self.chunk     = array.array('B',[0]*256)
      self.data_pos  = 1
      self.bit_pos   = 0
      self.chunk_pos = 0
      #compress the image and render to array
      self.min_code_size   =min_code_size
      self.code_size       =min_code_size + 1       # because its the color table size pLus 1
      #first byte in array
      self.compressed =array.array ('B',[self.min_code_size])
      self.compress()
    
      
    cdef write_bit(self,uint32_t bit):
        bit = bit & 1
        bit = bit << self.bit_pos
        self.byte |= bit
        self.bit_pos+=1
        if self.bit_pos > 7 :
          self.chunk[self.chunk_pos] = self.byte
          self.chunk_pos+=1
          self.bit_pos = 0
          self.byte = 0
          if self.chunk_pos == 255:
              self.write_chunk()
  

    cdef write_chunk(self):
        if self.chunk_pos==0:
          raise Exception("Cannot write chunk of empty stream")
        cdef int new_compressed_size = len(self.compressed)+self.chunk_pos+1+1
        if 0==0:
          #print "Before",len(self.chunk),len(self.compressed)
          array.resize(self.compressed,new_compressed_size)
          #print "After",len(self.chunk),len(self.compressed)
          
          self.compressed[self.data_pos]=self.chunk_pos
          self.data_pos+=1
          
          for i in range(0,self.chunk_pos+1):
            self.compressed[self.data_pos]=self.chunk[i]
            #print len(self.chunk),len(self.compressed),self.data_pos
            self.data_pos+=1

        self.bit_pos   = 0
        self.byte      = 0
        self.chunk_pos = 0
    

    cdef write_code(self,uint32_t code):
      for i in range (0,self.code_size):
          self.write_bit(code)
          code = code >> 1

    # used to clear the incomplete bits of a chunk, end of line stuff
    cdef empty_stream(self):
      while( self.bit_pos>0):
        self.write_bit(0)
      if self.chunk_pos>0:
        self.write_chunk()
      

    cdef compress (self):
        cdef uint32_t     code_tree_len  = 256*4096
        cdef array.array  codetree       = array.array('i',[0]*code_tree_len)
        cdef uint32_t     image_length   = len(self.image)
        cdef int32_t      min_code_size  = self.min_code_size    
        cdef uint32_t     clear_code     = 1<<self.min_code_size   # the code right after the color table
        cdef uint16_t     end_code       = clear_code+1            # the code right after the clear code
        cdef uint16_t     codes          = clear_code+2
        cdef int32_t      current_code   = -1                      # curent hash lookup code
        cdef uint8_t      next_value     = 0                       # pixel value
        cdef uint16_t     lookup         = 0                       # code  table lookup hash
        cdef uint16_t     lookup_base    = 0
        cdef int32_t      tree_lookup    = 0
        cdef uint32_t     code_max       = 1 << self.code_size

        #f#or i in range(0,clear_code):
        #  codetree[i]=i

        print "CLEAR",clear_code
        print "LEN",image_length
        print "min_code",min_code_size
        print "LOOKUP_LEN",code_tree_len
        memset(codetree.data.as_voidptr,0,2*code_tree_len)
        print ("LEN",image_length)
        self.write_code(clear_code)
        
        #compression loop
        for i in range(0,image_length):
          next_value=self.image[i]
  
          lookup=current_code*256+next_value
          tree_lookup=codetree[lookup]

          #print lookup,len(codetree),code_tree_len
          if current_code < 0:
              current_code = next_value
          elif tree_lookup!=0 :
              current_code = tree_lookup
          else:
              self.write_code(current_code)
              #print "MAX",max_code,lookup,i
              codetree[lookup] = codes
              
              #increase curent bit depth if outsized
              if codes >= code_max:
                  #print ("code size increase",self.code_size,i,max_code,self.chunk_pos)
                  #print("{0:04x}".format(self.chunk_pos))
                  self.code_size+=1
                  code_max=1 << self.code_size
                  print "MAX",code_max


              # end of lookup table
              if codes == 4095:
                  if self.code_size==13:
                    self.code_size=12

                  self.write_code(clear_code)
                  memset(codetree.data.as_voidptr,0,2*code_tree_len)
                  self.code_size = min_code_size + 1
                  codes=clear_code+2
                  #for i in range(0,clear_code):
                  #  codetree[i]=i
              codes+=1

              current_code = next_value
        
        # end of loop cleanup (not sure about this)
        self.write_code(current_code)
        self.write_code(clear_code  )
        self.code_size= min_code_size + 1
        self.write_code(end_code)
        self.empty_stream()
        print "done"
