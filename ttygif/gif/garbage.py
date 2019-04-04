#
#    def init_lookup_table(self):
#      self.DATA_BIT_MIN_SIZE=1<<self.LWZ_MIN_BYTE_SIZE
#      self.DATA_BIT_SIZE=self.LWZ_MIN_BYTE_SIZE+1
#      self.CLEAR=1<<(self.LWZ_MIN_BYTE_SIZE)
#      self.END_OF_INFORMATION=self.CLEAR+1
#      self.set_max_code_size()
#    
#      self.lookup=[self.NOT_A_CODE]*(self.MAX_CODE_SIZE)
#      for index in range(0,self.DATA_BIT_MIN_SIZE):
#          self.lookup[index]=[index]
#      self.next_table_index=self.END_OF_INFORMATION+1
#      
#    def set_max_code_size(self):
#      self.MAX_CODE_SIZE=(1<<(self.DATA_BIT_SIZE))
#      #print ("MAX CODE SIZE: {0}".format(self.MAX_CODE_SIZE))
#  
#    def get_first_code_in_data_sub_block(self):
#      code=self.read_code()
#      if code==self.CLEAR:
#          self.init_lookup_table()
#          #print ("Setting up new lookup table")
#      else:
#          raise Exception("First code data sub block should be a clear. LZW data is bad bro.")
#
#    def add_code_list_to_lookup(self,code_list):
#      if self.next_table_index==self.MAX_CODE_SIZE-1 and self.DATA_BIT_SIZE<self.LZ_BITS: #
#          self.DATA_BIT_SIZE+=1
#          #print ("Bit size increase: {0}".format(self.DATA_BIT_SIZE))
#          self.set_max_code_size()
#          #print ("MAXCODE: {0:02X}".format(self.MAX_CODE_SIZE))
#          self.lookup=self.lookup+ [self.NOT_A_CODE]*(self.MAX_CODE_SIZE-len(self.lookup)+300)
#
#      this_code_index=self.next_table_index
#      #print("Table index",self.next_table_index)
#      #print(self.next_table_index,len(self.lookup))
#      self.lookup[self.next_table_index]=code_list
#      #print (self.code_index,self.MAX_CODE_SIZE,code)
#      self.next_table_index+=1
#      return this_code_index
#
#    def is_code_in_the_lookup(self,code):
#      if self.lookup[code]==self.NOT_A_CODE:
#          return None
#      return True
#
#    def read_code(self):
#      # data mask based based on the curent bit state
#      code_masks=[0x0000, 0x0001, 0x0003, 0x0007,0x000F, 0x001F, 0x003F, 0x007F,0x00FF, 0x01ff, 0x03FF, 0x07FF,0x0FFF]
#      # if there isnt enough data in the byte buffer
#      # grab another one
#      # shift it by the shiift state
#      # "or" it with the curent byte
#      # now we have a buffer with enough data
#      while self.bytes_in_buffer < self.DATA_BIT_SIZE and self.block_index<self.block_size:
#          next_byte =self.stream.byte()
#          
#          # print ("Pulled: 0x{0:02x}".format(next_byte))
#          self.buffer =self.buffer  | next_byte << self.bytes_in_buffer
#          self.bytes_in_buffer += 8
#          self.block_index+=1
#      
#      if self.bytes_in_buffer < self.DATA_BIT_SIZE :
#          #print ("NO bits in buffer")
#          return None
#      code = self.buffer & code_masks[self.DATA_BIT_SIZE]
#          
#      # Shift the buffer by the number of bits extracted.
#      self.buffer  >>= self.DATA_BIT_SIZE
#      self.bytes_in_buffer-= self.DATA_BIT_SIZE
#      
#      return code
#
#    def read_block(self):
#      start_pos=self.stream.pos
#      if self.debug:
#          print("BLOCK SIZE: {0}".format(self.block_size))
#      #Read first code
#      code=self.read_code()
#      gif_index=[code] 
#      self.last_code=code
#      while code!=None:
#          # pull another code from the compressed srream
#          code=self.read_code()
#          if code==self.CLEAR:
#              if self.debug:
#                  print ("Processing CLEAR")
#                  last_code=self.NOT_A_CODE
#              self.init_lookup_table()
#              continue
#
#          elif code==self.END_OF_INFORMATION:
#              if self.debug:
#                  print ("Processing EOI")
#              break
#          if None ==code:
#              if self.debug:
#                  print ("LAST BIT")
#              continue
#          #if self.last_code>=len(self.lookup):
#          #    raise Exception ("Last Code out of bounds: lookup length: {0}. Code: {1}".format(len(self.lookup),self.last_code))
#          #
#          #
#          #if self.lookup[self.last_code]==self.NOT_A_CODE:
#          #    raise Exception ("Last Code has no value: lookup length: {0}. Code: {1} , Next Code Index: {2}".format(len(self.lookup),self.last_code,self.next_table_index))
#          # is the index in the lookup table?
#          if self.debug:
#              print("C{0}:LC{1},BI:{2},POS:{3:02X}".format(code,self.last_code,self.block_index,self.stream.pos))
#          if self.last_code==self.NOT_A_CODE:
#              print "EH"
#              print "EH"
#              print "EH"
#              print "EH"
#              print "EH"
#              print "EH"
#              
#          if self.is_code_in_the_lookup(code):
#              #if code>=len(self.lookup):
#              #    raise Exception ("Code out of bounds: lookup length: {0}. Code: {1}".format(len(self.lookup),code))
#          
#              #if self.lookup[code]==self.NOT_A_CODE:
#              #    raise Exception ("Code has no value: lookup length: {0}. Code: {1}, Next Code Index: {2}".format(len(self.lookup),code,self.next_table_index))
#
#              gif_index+=self.lookup[code]
#              prefix=self.lookup[code][0]
#              new_code=self.lookup[self.last_code]+[prefix]
#          else:
#              print(self.lookup)
#
#              prefix=self.lookup[self.last_code][0]
#              new_code=self.lookup[self.last_code]+[prefix]
#              gif_index+=new_code
#          self.add_code_list_to_lookup(new_code)
#          self.last_code=code
#      
#      end_pos=self.stream.pos
#      return gif_index
#      
#      #print ("Start: {0:02X},End: {1:02X},Span:{2:02X}, Block Index:{3:02X}".format(start_pos,end_pos,end_pos-start_pos,self.block_index))
#  