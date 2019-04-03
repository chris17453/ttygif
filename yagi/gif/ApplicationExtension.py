class ApplicationExtension:
    def __init__(self,stream):
        self.internal_position=stream.pos
        self.Introducer= stream.byte(value=0x21)         # Extension Introducer (always 21h) 
        self.Label= stream.byte(value=0xFF)              # Extension Label (always FFh) 
        self.BlockSize= stream.byte(value=0x0B)          # Size of Extension Block (always 0Bh) 
        self.Identifier= stream.string(8)                  # Application Identifier 
        self.AuthentCode= stream.string(3)                 # Application Authentication Code 
        
        self.SubBlockDataSize=0
        self.data_sub_blocks=[]
        SubBlockDataSize= stream.byte()
        while SubBlockDataSize!=0:
            self.SubBlockDataSize+=SubBlockDataSize
            self.data_sub_blocks+=stream.byte(SubBlockDataSize)      # Point to Application Data sub-blocks 
            SubBlockDataSize= stream.byte()
        

        #self.SubBlockID= stream.byte()
        #self.LoopCount= stream.word()
        self.Terminator= SubBlockDataSize #stream.byte(value=0x00)         # Block Terminator (always 0) 

        
    
    def debug(self):
        print("Application Extension Block")
        print("  Offset: {0:02X}".format(self.internal_position))
        print("  Introducer: {0}".format(self.Introducer))
        print("  Label: {0}".format(self.Label))
        print("  BlockSize: {0}".format(self.BlockSize))
        print("  Identifier: {0}".format(self.Identifier))
        print("  AuthentCode: {0}".format(self.AuthentCode))
        #print("  ApplicationData: {0}".format(self.ApplicationData))
        print("  SubBlockDataSize: {0:02X}".format(self.SubBlockDataSize))
        #print("  SubBlockID: {0:02X}".format(self.SubBlockID))
        #print("  LoopCount: {0:02X}".format(self.LoopCount))

        print("  Terminator: {0:02X}".format(self.Terminator))
    