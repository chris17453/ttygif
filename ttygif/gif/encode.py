
class Encode:
    def __init__(self):
        x=1

    def emit_bytes_to_buffer(self,bit_block_size):
        while self.cur_shift >= bit_block_size:
          self.buf[self.p] = self.cur & 0xff
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
    

    def compress(buf, p, min_code_size, index_stream):
      self.buf[self.p] = min_code_size
      self.p+=1
      self.cur_subblock = self.p
      self.p+=1

      self.clear_code = 1 << min_code_size
      self.code_mask = self.clear_code - 1
      self.eoi_code = self.clear_code + 1
      self.next_code = self.eoi_code + 1
      self.cur_code_size = min_code_size + 1
      self.cur_shift = 0
      self.cur = 0


      ib_code = index_stream[0] & code_mask
      code_table = {}

      self.emit_code(clear_code); 

      for (var i = 1, il = index_stream.length; i < il; ++i:
        k = index_stream[i] & code_mask
        cur_key = ib_code << 8 | k
        cur_code = code_table[cur_key];

        if cur_code == undefined: # TODO
          self.cur |= ib_code << self.cur_shift
          self.cur_shift += self.cur_code_size
          while (self.cur_shift >= 8) {
            self.buf[self.p] = self.cur & 0xff;
            self.p+=1
            self.cur >>= 8;
            self.cur_shift -= 8;
            if self.p == self.cur_subblock + 256:
              self.buf[self.cur_subblock] = 255
              self.cur_subblock = self.p
              self.p+=1
            }
          }

          if self.next_code === 4096:
            self.emit_code(self.clear_code)
            self.next_code = self.eoi_code + 1
            self.cur_code_size = min_code_size + 1
            code_table = {}
          else:
            code_table[cur_key] = self.next_code
            self.next_code+=1

          ib_code = k
        else:
          ib_code = cur_code

      self.emit_code(ib_code)
      self.emit_code(eoi_code)
      self.emit_bytes_to_buffer(1)

      if self.cur_subblock + 1 === self.p:
        self.buf[self.cur_subblock] = 0
      else:
        self.buf[self.cur_subblock] = self.p - self.cur_subblock - 1
        self.buf[self.p] = 0
        self.p+=1
      return p