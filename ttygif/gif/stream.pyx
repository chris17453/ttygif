# cython: language_level=2
import os
import struct 

cdef class DataStream:


    def __cinit__(self,file=None,mode="r"):
        self.FILE_NULL        = 'input file is empty, pebkac'
        self.FILE_NOT_FOUND   = 'input file does not exist, rtfm'
        self.FILE_OBJECT_NULL = 'file object is null, id10t?'
        self.OUT_OF_BOUNDS    = 'Trying to access a position in the file that does not exist, come on bro.'
        self.INVALID_POSITION = 'Seek position not within file bounds'


        self.mode=mode
        self.pos=0
        self.file_length=-1
        self.file=file
        self.open()


    cdef validate_file(self):
        if None == self.file:
            raise Exception(self.FILE_NULL)

        if False == os.path.exists(self.file):
            raise Exception(self.FILE_NOT_FOUND)

    cdef validate_bounds(self):
        if self.file_length==-1:
            self.get_file_size()
        
        if self.pos>=self.file_length:
            raise  Exception(self.OUT_OF_BOUNDS)

    cdef open(self):
        if self.mode==b'r':
            self.validate_file()
            self.file_object=open(self.file, "rb")
        if self.mode==b'w':
            self.file_object=open(self.file, "wb")

    cdef close(self):
        if None== self.file_object:
            raise Exception(self.FILE_OBJECT_NULL)
        self.file_object.close()
    
    cdef pin(self):
        self.pinned_position=self.pos
        
    cdef seek(self,position):
        if position and position >-1:
            if self.file_object:
                self.file_object.seek(position)
                #print("Position changed from {0} to {1}".format(self.pos,position))
                self.pos=position
        else:
            raise Exception(self.INVALID_POSITION)
    
    cdef rewind(self):
        self.seek(self.pinned_position)

    cdef get_file_size(self):
        self.validate_file()
        self.file_length=os.path.getsize(self.file)
        print ("FILE SIZE",self.file_length)

    def read(self,length=1,word=None,character=None,byte=None,string=None):
        try:
            #start_pos=self.pos
            self.validate_bounds()
            if self.file_object:
                chunk=[]

                if word:
                    if length==1:
                        read=self.file_object.read(2)
                        chunk=struct.unpack('h', read)[0]
                        self.pos+=2
                    else:
                        for i in range(0,length):
                            chunk.append(struct.unpack('h', self.file_object.read(2))[0])
                            self.pos+=2
                elif string:
                        chunk=self.file_object.read(length)
                        #print (read,length)
                        #results=struct.unpack('p', read)
                        #chunk=results[0]
                        self.pos+=length
                elif byte:
                    if length==1:
                        chunk=struct.unpack('B', self.file_object.read(1))[0]
                        self.pos+=1
                    else:
                        for i in range(0,length):
                            chunk.append(struct.unpack('B', self.file_object.read(1))[0])
                            self.pos+=1

                elif character:
                    if length==1:
                        chunk=struct.unpack('b', self.file_object.read(1))[0]
                        self.pos+=1
                    else:
                        for i in range(0,length):
                            chunk.append(struct.unpack('b', self.file_object.read(1))[0])
                            self.pos+=1

                #print(start_pos,self.pos,chunk)
                #print("Position: {0}".format(self.pos))
                return chunk
        except Exception as ex:
            raise Exception ("Read Error {0}, WORD,{1}".format(ex,word))

    def write_byte(self,byte):
        #print ("'{0}'".format(byte))
        ba=bytearray()
        ba.append(byte)
        self.file_object.write(ba)
        self.pos+=1

    def write_word(self,word):
        ba=bytearray()
        ba.append(word & 0xFF)
        ba.append((word>>8) & 0xFF)
        self.file_object.write(ba)
        self.pos+=1

    def write_string(self,string,length):
        ba=bytearray()
        for i in range(0,length):
            ba.append(ord(string[i]))
        self.file_object.write(ba)
        self.pos+=length
        

    def character(self,length=1,ptr=None,value=None):
        chunk=self.read(length,character=True)
        # if there is a value and the result is not a list...
        if value and  not isinstance(chunk,list):
            if isinstance(value,list):
                found=None
                for i in value:
                    if chunk==value:
                        found=True

                if None == found:
                    raise Exception("Data Fragment Invalid {0},{1}".format(chunk,value))

            else:
                if chunk!=value:
                    raise Exception("Data Fragment Invalid {0},{1}".format(chunk,value))

        return chunk
    
    def byte(self,length=1,ptr=None,value=None,eod=None):
        if eod==0x00:
            chunk=[]
            byte=self.read(length,byte=True)
            while byte:
                print("POS {0}".format(self.pos))
                chunk.append(byte)
                byte=self.read(length,byte=True)
            self.seek(self.pos-1)
        else:
            chunk=self.read(length,byte=True)
            if value and not isinstance(chunk,list):
                if isinstance(value,list):
                    found=None
                    for i in value:
                        if chunk==value:
                            found=True

                    if None == found:
                        raise Exception("Data Fragment Invalid {0},{1}".format(chunk,value))

                else:
                    if chunk!=value:
                        raise Exception("Data Fragment Invalid {0},{1}".format(chunk,value))

        return chunk

    def string(self,length=1,ptr=None,value=None,EOD=None):
        chunk=self.read(length,string=True)
        return chunk

    def word(self,length=1,ptr=None,value=None,EOD=None):
        chunk=self.read(length,word=True)
        return chunk
   
    def print_bit(self,byte,length=8):
        o=" <- 0"
        for i in range(0,length):
            bit_value=byte >> i &1
            o="{0}.".format(bit_value)+o
        o="{0} -> ".format(length)+o
        print(o)

    def bit(self,byte,index,length=None):
    
        if None==length:
            mask=1
            bit_value=byte >> index &mask
            #print ("Bit: {0:02X},Mask:{1:02X},Index:{2},Length:{3}".format(bit_value,mask,index,length))
            if bit_value==1:
                return True
            else:
                 return False
        mask=0
        for i in range(0,length):
            mask=(mask<<1)+1
        bit_value=(byte>>index)&mask
        #self.print_bit(bit_value)
        #print ("Bit: {0:02X},Mask:{1:02X},Index:{2},Length:{3}".format(bit_value,mask,index,length))
        return bit_value
   