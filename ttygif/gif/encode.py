
class LZWEncoder:

    def __init__(self,width, height, pixels, colorDepth):
        self.EOF = -1
        self.BITS = 12
        self.HSIZE = 5003
        self.masks = [0x0000, 0x0001, 0x0003, 0x0007, 0x000F, 0x001F,
                    0x003F, 0x007F, 0x00FF, 0x01FF, 0x03FF, 0x07FF,
                    0x0FFF, 0x1FFF, 0x3FFF, 0x7FFF, 0xFFFF]

        self.initCodeSize = colorDepth
        self.accum = [0]*256
        self.htab = [0]*self.HSIZE
        self.codetab =[0]*self.HSIZE
        self.cur_bits = 0
        self.free_ent = 0
        self.clear_flg = False
        
        self.cur_accum=0
        #a_count
        #maxcode
        g_init_bits=0
        #ClearCode
        #EOFCode

    def char_out(self,c, outs):
        self.accum[self.a_count] = c
        self.a_count+=1
        if (a_count >= 254) self.flush_char(outs)
    
    def cl_block(self,outs):
        self.cl_hash(self.HSIZE)
        self.free_ent = self.ClearCode + 2
        self.clear_flg = True
        self.output(self.ClearCode, outs)
    
    def cl_hash(self,hsize) :
        for i in range (0,hsize):
            self.htab[i] = -1
    
    def compress(self,init_bits, outs) :
        #fcode, c, i, ent, disp, hsize_reg, hshift

        g_init_bits = init_bits

        self.clear_flg = False
        n_bits = g_init_bits
        maxcode = MAXCODE(n_bits)

        ClearCode = 1 << (init_bits - 1)
        EOFCode = ClearCode + 1
        free_ent = ClearCode + 2

        a_count = 0 // clear packet

        ent = nextPixel()

        hshift = 0
        for (fcode = HSIZE fcode < 65536 fcode *= 2) ++hshift
        hshift = 8 - hshift // set hash code range bound
        hsize_reg = HSIZE
        cl_hash(hsize_reg) // clear hash table

        output(ClearCode, outs)

        outer_loop: while ((c = nextPixel()) != EOF) :
        fcode = (c << BITS) + ent
        i = (c << hshift) ^ ent // xor hashing
        if (htab[i] === fcode) :
            ent = codetab[i]
            continue
         else if (htab[i] >= 0) : // non-empty slot
            disp = hsize_reg - i // secondary hash (after G. Knott)
            if (i === 0) disp = 1
            do :
            if ((i -= disp) < 0) i += hsize_reg
            if (htab[i] === fcode) :
                ent = codetab[i]
                continue outer_loop
            
             while (htab[i] >= 0)
        
        output(ent, outs)
        ent = c
        if (free_ent < 1 << BITS) :
            codetab[i] = free_ent++ // code -> hashtable
            htab[i] = fcode
         else :
            cl_block(outs)
        
        

        // Put out the final code.
        output(ent, outs)
        output(EOFCode, outs)
    
    def encode(outs) :
        self.writeByte(self.initCodeSize) 
        self.remaining = self.width * self.height 
        self.curPixel = 0
        self.compress(self.initCodeSize + 1, outs)
        self.writeByte(0)
    
    def flush_char(outs) :
        if (self.a_count > 0) :
        self.writeByte(self.a_count)
        self.writeBytes(self.accum, 0, self.a_count)
        self.a_count = 0        

    def MAXCODE(self,n_bits) :
        return (1 << n_bits) - 1
    
    def nextPixel(self):
        if self.remaining == 0:
            return self.EOF
        self.remaining-=1
        pix = self.pixels[self.curPixel]
        self.curPixel+=1
        return pix & 0xff
    
    def output(self,code, outs) :
        self.cur_accum &= self.masks[self.cur_bits]

        if (self.cur_bits > 0) self.cur_accum |= (code << self.cur_bits)
        else self.cur_accum = code

        self.cur_bits += self.n_bits

        while (self.cur_bits >= 8) :
            self.char_out((self.cur_accum & 0xff), outs)
            self.cur_accum >>= 8
            self.cur_bits -= 8
        

        if self.free_ent > self.maxcode or self.clear_flg:
        if self.clear_flg :
            self.maxcode = self.MAXCODE(n_bits = self.g_init_bits)
            self.clear_flg = False
         else :
            self.n_bits+=1
            if self.n_bits == self.BITS:
                self.maxcode = 1 << self.BITS
            else:
                self.maxcode = self.MAXCODE(self.n_bits)
        
        

        if (code == self.EOFCode) :
        while (self.cur_bits > 0) :
            self.char_out((self.cur_accum & 0xff), outs)
            self.cur_accum >>= 8
            self.cur_bits -= 8
        
        self.flush_char(outs)
        
