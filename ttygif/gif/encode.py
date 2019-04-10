
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
      