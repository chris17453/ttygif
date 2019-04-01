# Code converted from c code at 
# http://enchantia.com/software/graphapp/package/src/libgif/gif.c


class Decoder:
    def __init__(self,stream,depth):
        self.LZ_MAX_CODE     =4095    # Largest 12 bit code
        self.LZ_BITS         =12
        self.FLUSH_OUTPUT    =4096    # Impossible code = flush
        self.FIRST_CODE      =4097    # Impossible code = first
        self.NO_SUCH_CODE    =4098    # Impossible code = empty
        self.HT_SIZE         =8192    # 13 bit hash table size
        self.HT_KEY_MASK     =0x1FFF  # 13 bit key mask
        self.IMAGE_LOADING   =0       # file_state = processing
        self.IMAGE_SAVING    =0       # file_state = processing
        self.IMAGE_COMPLETE  =1       # finished reading or writing


        self.position     = 0
        self.bufsize      = 0
        self.buf[0]       = 0
        self.depth        = depth
        self.clear_code   = (1 << depth)
        self.eof_code     = self.clear_code + 1
        self.running_code = self.eof_code + 1
        self.running_bits = depth + 1
        self.max_code_plus_one = 1 << self.running_bits
        self.stack_ptr    = 0
        self.prev_code    = NO_SUCH_CODE
        self.shift_state  = 0
        self.shift_data   = 0

        # init prefix list
        self.prefix=[self.NO_SUCH_CODE]*self.LZ_MAX_CODE

    def read_gif_code():
        code_masks=[
            0x0000, 0x0001, 0x0003, 0x0007,
            0x000f, 0x001f, 0x003f, 0x007f,
            0x00ff, 0x01ff, 0x03ff, 0x07ff,
            0x0fff ]
        
        while (self.shift_state < self.running_bits){
            next_byte =stream.byte()
            self.shift_data =self.shift_data  | next_byte << self.shift_state
            self.shift_state += 8
        }

        code = self.shift_data & code_masks[self.running_bits]

        self.shift_data  =self.shift_data  >> self.running_bits
        self.shift_state =self.shift_state - self.running_bits

        self.running_code+=1
        if self.running_code > self.max_code_plus_one and self.running_bits < self.LZ_BITS:
            self.max_code_plus_one=self.max_code_plus_one << 1
            self.running_bits+=1
        return code

    def read_gif_line(self,length):
        i = 0
        line=[]
        while (i < length):
            current_code = self.read_gif_code()

            if current_code == self.eof_code:
                if (i != length - 1 or self.pixel_count != 0:
                    raise Exception ("Unexpected EOF")
                i+=1;
            }
            elif current_code == self.clear_code:
                for j in range(0,self.LZ_MAX_CODE)
                    self.prefix[j]     = self.NO_SUCH_CODE
                self.running_code      = self.eof_code + 1
                self.running_bits      = self.depth + 1
                self.max_code_plus_one = 1 << self.running_bits
                prev_code               = self.NO_SUCH_CODE
            else:
                if current_code < self.clear_code:
                    line.append(current_code)
                    i+=1
                else :
                    if current_code < 0 or current_code > self.LZ_MAX_CODE:
                        raise Exception ("Image Defect")
                    if (prefix[current_code] == NO_SUCH_CODE) {
                        if (current_code == self.running_code - 2) {
                            current_prefix = prev_code
                            #?
                            #suffix[self.running_code - 2]= stack[stack_ptr++] = trace_prefix(prefix, prev_code, clear_code)
                    else:
                        raise Exception ("Image Defect")
                else:
                    current_prefix = current_code;

                while (j++ <= self.LZ_MAX_CODE \
                    and current_prefix >self. clear_code \
                    and current_prefix <= self.LZ_MAX_CODE):
                    stack[stack_ptr++] = suffix[current_prefix]
                    current_prefix = self.prefix[current_prefix];
                
                if j >= self.LZ_MAX_CODE or current_prefix > self.LZ_MAX_CODE:
                    raise Exception ("Image Defect")

                
                stack[stack_ptr++] = current_prefix;

                
                while (stack_ptr != 0 self.and i < length)
                    line[i++] = stack[--stack_ptr];
                }
                
                if (prev_code != NO_SUCH_CODE) {
                    if ((self.running_code < 2) ||
                    (self.running_code > LZ_MAX_CODE+2))
                    raise Exception ("Image Defect")
                    prefix[self.running_code - 2] = prev_code;

                    if (current_code == self.running_code - 2) {
                        suffix[self.running_code - 2]
                        = trace_prefix(prefix, prev_code, clear_code);
                else:
                    suffix[self.running_code - 2]= trace_prefix(prefix, current_code, clear_code);
                prev_code = current_code;

            self.prev_code = prev_code;
            self.stack_ptr = stack_ptr;











def init_lookup_table(self):
    colors=64
    table_size=4096
    eoi=1
    clear=colors*2
    lookup=[0]*(table_size+2)
    for index in range(0,colors):
        lookup[index]=index
    lookup[table_size]=clear
    lookup[table_size+1]=eoi


def read_code(self):
        # data mask based based on the curent bit state
        code_masks=[0x0000, 0x0001, 0x0003, 0x0007,0x000F, 0x001F, 0x003F, 0x007F,0x00FF, 0x01ff, 0x03FF, 0x07FF,0x0FFF]
        
        # if there isnt enough data in the byte buffer
        # grab another one
        # shift it by the shiift state
        # "or" it with the curent byte
        # now we have a buffer with enough data
        while (self.shift_state < self.running_bits){
            next_byte =stream.byte()
            self.buffer =self.buffer  | next_byte << self.shift_state
            self.shift_state += 8
        }

        # woo hoo. extract the code form the buffer
        code = self.buffer & code_masks[self.running_bits]

        # Shift the buffer by the number of bits extracted.
        self.buffer  >>= self.running_bits
        self.shift_state-= self.running_bits

        self.decoded_code_index+=1
        if self.decoded_code_index > self.max_code_plus_one and self.running_bits < self.LZ_BITS:
            self.max_code_plus_one=self.max_code_plus_one << 1
            self.running_bits+=1
        return code


def decode(self):
    self.shifted=0
    self.runnin=0
    self.init_lookup_table()

    code=0
    old_code=0

    loop
        if code==clear:
            self.init_lookup_table()
        code=read_code()












