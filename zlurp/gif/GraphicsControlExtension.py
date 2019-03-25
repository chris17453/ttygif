class GraphicsControlExtension:
    def __init__(self,stream):
        self.Introducer= stream.byte(value=0x21)         # Extension Introducer (always 21h) 
        self.Label= stream.byte(value=0xF9)              # Graphic Control Label (always F9h) 
        self.BlockSize= stream.byte(value=0x04)          # Size of remaining fields (always 04h) 
        self.Packed= stream.byte()                        # Method of graphics disposal to use 
        self.DelayTime= stream.word()                     # Hundredths of seconds to wait	
        self.ColorIndex= stream.byte()                    # Transparent Color Index 
        self.Terminator= stream.byte(value=0x00)         # Block Terminator (always 0) 

        # computed
        self.TransparentColorFlag=stream.bit(self.Packed,0)
        self.UserInputFlag=stream.bit(self.Packed,1)
        self.DisposalMethod=stream.bit(self.Packed,2,3)
        self.Reserved=stream.bit(self.Packed,3)
    
    def debug(self):
        print("Graphics Control Extension Block")
        print("  Introducer: {0}".format(self.Introducer))
        print("  Label: {0}".format(self.Label))
        print("  BlockSize: {0}".format(self.BlockSize))
        print("  Packed: {0}".format(self.Packed))
        print("  DelayTime: {0}".format(self.DelayTime))
        print("  ColorIndex: {0}".format(self.ColorIndex))
        print("  Terminator: {0}".format(self.Terminator))
        print("  TransparentColorFlag: {0}".format(self.TransparentColorFlag))
        print("  UserInputFlag: {0}".format(self.UserInputFlag))
        print("  DisposalMethod: {0}".format(self.DisposalMethod))
        print("  Reserved: {0}".format(self.Reserved))
    