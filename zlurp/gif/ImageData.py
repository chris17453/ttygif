class ImageData:
    def __init__(self,stream):
        self.internal_position=stream.pos
        self.blocks=[]
        self.DataLength=0
        block_size=1
        row=0
        self.LWZ_ByteSize=stream.byte()
            
        while block_size!=0:
            block_size=stream.byte()
            if block_size==0:
               # print ("Row: {0:02X},".format(row))
               # row+=1
               # if row>=self.Height:
               break
               # block_size=1
               # continue
            data=stream.byte(block_size)
            #print ("Offset: {0:02X}, Size: {1:02X}".format(stream.pos,block_size))
            self.blocks.append({'size':block_size,'data':data,'offsef':self.DataLength})
            self.DataLength+=block_size

    def debug(self):
        print("ImageData")
        print("  Offset: {0:02X}".format(self.internal_position))
        print("  DataLength: {0:02X}".format(self.DataLength))
        print("  LWZ_ByteSize: {0}".format(self.LWZ_ByteSize))
