# cython: profile=True

class application_extension:
    def __init__(self,stream):
        self.stream=stream



    def read(self):
        self.internal_position = self.stream.pos
        self.Introducer        = self.stream.byte(value=0x21)           # Extension Introducer (always 21h) 
        self.Label             = self.stream.byte(value=0xFF)           # Extension Label (always FFh) 
        self.BlockSize         = self.stream.byte(value=0x0B)           # Size of Extension Block (always 0Bh) 
        self.Identifier        = self.stream.string(8)                  # Application Identifier 
        self.AuthentCode       = self.stream.string(3)                  # Application Authentication Code 
        
        self.SubBlockDataSize=0
        self.data_sub_blocks=[]
        SubBlockDataSize= self.stream.byte()
        while SubBlockDataSize!=0:
            self.SubBlockDataSize+=SubBlockDataSize
            self.data_sub_blocks+=self.stream.byte(SubBlockDataSize)      # Point to Application Data sub-blocks 
            SubBlockDataSize= self.stream.byte()
        

        self.Terminator= SubBlockDataSize #stream.byte(value=0x00)         # Block Terminator (always 0) 


    def write(self):
        self.internal_position=self.stream.pos
        self.stream.write_byte(self.Introducer)
        self.stream.write_byte(self.Label)
        self.stream.write_byte(self.BlockSize)
        self.stream.write_string(self.Identifier,8)
        self.stream.write_string(self.AuthentCode,3)
        
        left=len(self.data_sub_blocks)
        index=0
        while left>0:
            if left>255:
                self.stream.write_byte(255)
                for b in self.data_sub_blocks[index:left]:
                    self.stream.write_byte(b)
                left-=255
            else:
                self.stream.write_byte(left)
                for b in self.data_sub_blocks[index:left]:
                    self.stream.write_byte(b)
                left=0

        
        self.stream.write_byte(self.Terminator)

    def new_netscape_block(self,loop_count=0xFFFF):
        if loop_count>0xFFFF:
            loop_count=0xFFFF
        self.Introducer        = 0x21
        self.Label             = 0xFF
        self.BlockSize         = 0x0B
        self.Identifier        = "NETSCAPE"
        self.AuthentCode       = "2.0"
        self.SubBlockDataSize  = 0x03
        self.data_sub_blocks   = [1,loop_count & 0xFF,(loop_count>>8) & 0xFF]
        self.Terminator        = 0x00
        #print("LOOP",loop_count & 0xFF,(loop_count>>8) & 0xFF)



    
    def debug(self):
        print("Application Extension Block")
        print("  Offset:           {0:02X}".format(self.internal_position))
        print("  Introducer:       {0}".format(self.Introducer))
        print("  Label:            {0}".format(self.Label))
        print("  BlockSize:        {0}".format(self.BlockSize))
        print("  Identifier:       {0}".format(self.Identifier))
        print("  AuthentCode:      {0}".format(self.AuthentCode))
        print("  SubBlockDataSize: {0:02X}".format(self.SubBlockDataSize))
        print("  Terminator:       {0:02X}".format(self.Terminator))
    

# 30D:   21 FF                  Application Extension block
#   0B           11         - eleven bytes of data follow
#   4E 45 54
#       53 43 41
#       50 45        NETSCAPE   - 8-character application name
#       32 2E 30     2.0        - application "authentication code"
#   03           3          - three more bytes of data
#   01           1          - data sub-block index (always 1)
#   FF FF        65535      - unsigned number of repetitions
#   00                      - end of App Extension block