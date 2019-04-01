class ImageData:
    def __init__(self,stream,colors):
        self.LZ_BITS         =12
        self.NOT_A_CODE      =4096
        self.colors=colors
        # where the data is stored as its pulled out of the stream
       
        self.internal_position=stream.pos
        self.blocks=[]
        self.DataLength=0
        self.stream=stream
        self.LWZ_MIN_BYTE_SIZE=self.stream.byte()
        
        self.buffer=0
        self.bytes_in_buffer=0
        
        print ("Start")

        block_size=self.stream.byte()
        self.init_lookup_table()
        self.get_first_code_in_data_sub_block()           # always an init table

        #self.init_lookup_table()
        
        while block_size>0:
            gif_index=self.read_block(block_size)
            self.init_lookup_table()
            block_size=self.stream.byte()
            self.buffer=0
            self.bytes_in_buffer=0
            #self.LWZ_ByteSize=self.LWZ_MIN_BYTE_SIZE
            print("Block Size: {0}".format(block_size))
            print("Leftover bytes:{0}".format(self.bytes_in_buffer))

        #print ("Offset: {0:02X}, Size: {1:02X}".format(stream.pos,block_size))
        self.blocks.append({'size':block_size,'data':gif_index,'offset':self.DataLength})
        self.DataLength+=block_size

    def debug(self):
        print("ImageData")
        print("  Offset: {0:02X}".format(self.internal_position))
        print("  DataLength: {0:02X}".format(self.DataLength))
        print("  LWZ_ByteSize: {0:02X}".format(self.LWZ_ByteSize))
        print("Data: {0}".format(self.blocks))

    def init_lookup_table(self):
        
        # reset these
        self.LWZ_ByteSize=self.LWZ_MIN_BYTE_SIZE+1
        self.CLEAR=1<<(self.LWZ_MIN_BYTE_SIZE)
        self.END_OF_INFORMATION=self.CLEAR+1
        self.set_max_code_size()
       # print("LWZ_ByteSize: {0:02x}".format(self.LWZ_ByteSize))
        print("CLEAR: {0:02x}".format(self.CLEAR))
        print("END_OF_INFORMATION: {0:02x}".format(self.END_OF_INFORMATION))
       # print("MAX_CODE_SIZE:{0:02x}".format(self.MAX_CODE_SIZE))
        #self.lookup=[self.NOT_A_CODE]*(self.END_OF_INFORMATION+1)
        self.lookup=[self.NOT_A_CODE]*(self.MAX_CODE_SIZE+2)
        for index in range(0,self.MAX_CODE_SIZE):
            self.lookup[index]=[index]

        self.lookup[self.CLEAR]=[self.CLEAR]
        self.lookup[self.END_OF_INFORMATION]=[self.END_OF_INFORMATION]
        self.next_table_index=self.END_OF_INFORMATION+1
        self.block_index=0
        self.code_index=0
        
    def set_max_code_size(self):
        self.MAX_CODE_SIZE=(1<<(self.LWZ_ByteSize))-2
        print ("MAX CODE SIZE: {0}".format(self.MAX_CODE_SIZE))
   
    def get_first_code_in_data_sub_block(self):
        code=self.read_code()
        if code==self.CLEAR:
            self.init_lookup_table()
            #print ("Setting up new lookup table")
        else:
            raise Exception("First code data sub block should be a clear. LZW data is bad bro.")

    def add_code_list_to_lookup(self,code_list):
       
        if self.next_table_index>self.MAX_CODE_SIZE and self.LWZ_ByteSize<self.LZ_BITS: #
            self.LWZ_ByteSize+=1
            #print ("Bit size increase: {0}".format(self.LWZ_ByteSize))
            self.set_max_code_size()
            #print ("MAXCODE: {0:02X}".format(self.MAX_CODE_SIZE))
            self.lookup=self.lookup+ [self.NOT_A_CODE]*(self.MAX_CODE_SIZE-len(self.lookup)+2)

        
        this_code_index=self.next_table_index
        #print("Table index",self.next_table_index)
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
        #print( self.bytes_in_buffer, self.LWZ_ByteSize)
        while self.bytes_in_buffer < self.LWZ_ByteSize:
            next_byte =self.stream.byte()
            
            # print ("Pulled: 0x{0:02x}".format(next_byte))
            self.buffer =self.buffer  | next_byte << self.bytes_in_buffer
            self.bytes_in_buffer += 8
            self.block_index+=1
        

        # woo hoo. extract the code from the buffer
        #print("Code Mask", code_masks[self.LWZ_ByteSize])
        #self.stream.print_bit(self.buffer,self.bytes_in_buffer)
            
        code = self.buffer & code_masks[self.LWZ_ByteSize]
        #self.stream.print_bit(self.buffer,self.bytes_in_buffer)
        #self.stream.print_bit(code)
            
        # Shift the buffer by the number of bits extracted.
        self.buffer  >>= self.LWZ_ByteSize
        self.bytes_in_buffer-= self.LWZ_ByteSize
        #self.stream.print_bit(self.buffer,self.bytes_in_buffer)
        
        
        self.code_index+=1
       
        return code
 
    def read_block(self,block_size):
        #Read first code
        self.last_code=self.read_code()
        gif_index=[self.last_code] 
        while self.block_index < block_size:
            
            # pull another code from the compressed srream
            #print(self.lookup)
            code=self.read_code()
            print("Index: 0x{0:02x}, Code: {1:02x}, Max code: {2:02x} Lookup Index {3:02X} BI:{4},BS:{5}".
                    format(self.code_index,code,self.MAX_CODE_SIZE,self.next_table_index,self.block_index,block_size))
            #if self.block_index==block_size-1:
            #    break                
            if code==self.CLEAR:
                print ("Processing CLEAR")
                self.init_lookup_table()
                continue

            elif code==self.END_OF_INFORMATION:
                print ("Processing EOI")
                break
             
            
            if self.last_code>=len(self.lookup):
                raise Exception ("Last Code out of bounds: lookup length: {0}. Code: {1}".format(len(self.lookup),self.last_code))
            
            
            if self.lookup[self.last_code]==self.NOT_A_CODE:
                raise Exception ("Last Code has no value: lookup length: {0}. Code: {1} , Next Code Index: {2}".format(len(self.lookup),self.last_code,self.next_table_index))
            # is the index in the lookup table?
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
        # terminator=self.read_code()
            #print ("Terminator: {0:02x}".format(terminator))
        print ("End of read Block")
    