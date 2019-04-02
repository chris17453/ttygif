import os
import struct 

class DataStream:
    def __init__(self,file=None):
        self.pos=0
        self.file_length=None
        self.file=file
        self.FILE_NULL="input file is empty, pebkac"
        self.FILE_NOT_FOUND="input file does not exist, rtfm"
        self.FILE_OBJECT_NULL="file object is null, id10t?"
        self.OUT_OF_BOUNDS="Trying to access a position in the file that does not exist, come on bro."



    def validate_file(self):
        if None == self.file:
            raise Exception(self.FILE_NULL)

        if False == os.path.exists(self.file):
            raise Exception(self.FILE_NOT_FOUND)

    def validate_bounds(self):
        if None == self.file_length:
            self.get_file_size()

        if self.pos>=self.file_length:
            raise  Exception(self.OUT_OF_BOUNDS)

    def open(self):
        self.validate_file()
        self.file_object=open(self.file, "rb")

    def get_file_size(self):
        self.validate_file()
        self.file_length=os.path.getsize(self.file)


    def read(self,length=1,word=None,char=None,byte=None,string=None):
        try:
            start_pos=self.pos
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

                elif char:
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

    def close(self):
        if None== self.file_object:
            raise Exception(FILE_OBJECT_NULL)
        self.file_object.close()
    
    def pin(self):
        self.pinned_position=self.pos
        
    def seek(self,position):
        if self.file_object:
            self.file_object.seek(position)
            #print("Position changed from {0} to {1}".format(self.pos,position))
            self.pos=position
    
    def rewind(self):
        self.seek(self.pinned_position)

        
    def char(self,length=1,ptr=None,value=None):
        chunk=self.read(length,char=True)
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


    