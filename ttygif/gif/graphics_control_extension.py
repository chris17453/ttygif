# cython: profile=True
# cython: linetrace=True
# cython: binding=True
# cython: language_level=2


class graphics_control_extension:
    def __init__(self,stream):
        self.stream=stream
        self.internal_position=self.stream.pos

    def read(self):
        self.internal_position  = self.stream.pos
        self.Introducer         = self.stream.byte(value=0x21)        # Extension Introducer (always 21h) 
        self.Label              = self.stream.byte(value=0xF9)        # Graphic Control Label (always F9h) 
        self.BlockSize          = self.stream.byte(value=0x04)        # Size of remaining fields (always 04h) 
        self.Packed             = self.stream.byte()                  # Method of graphics disposal to use 
        self.DelayTime          = self.stream.word()                  # Hundredths of seconds to wait	
        self.ColorIndex         = self.stream.byte()                  # Transparent Color Index 
        self.Terminator         = self.stream.byte(value=0x00)        # Block Terminator (always 0) 

        # computed
        self.unpack()  

    def write(self):
        self.internal_position=self.stream.pos
        self.pack()
        self.stream.write_byte(self.Introducer)
        self.stream.write_byte(self.Label)
        self.stream.write_byte(self.BlockSize)
        self.stream.write_byte(self.Packed)
        #print ("THE DEALY:{0}".format(self.DelayTime))
        self.stream.write_word(self.DelayTime)
        self.stream.write_byte(self.ColorIndex)
        self.stream.write_byte(self.Terminator)

    def pack(self):
        self.Packed=0
        self.Packed =self.Reserved             <<3
        self.Packed+=self.DisposalMethod       <<2
        self.Packed+=self.UserInputFlag        <<1
        self.Packed+=self.TransparentColorFlag

    def unpack(self):
        self.TransparentColorFlag =self.stream.bit(self.Packed,0)
        self.UserInputFlag        =self.stream.bit(self.Packed,1)
        self.DisposalMethod       =self.stream.bit(self.Packed,2,3)
        self.Reserved             =self.stream.bit(self.Packed,3)

    # is no color index is passed, nothing is transparent. 
    # if so flag is set to transparent available and the index is set
    def new(self,   DelayTime=1,
                    ColorIndex=None,
                    UserInputFlag=0,
                    DisposalMethod=0):

        self.Introducer= 0x21
        self.Label      =0xF9
        self.BlockSize  =0x04
        self.DelayTime  =DelayTime
        self.Terminator= 0x00

        if ColorIndex:
            TransparentColorFlag=1
            self.ColorIndex =ColorIndex
        else:
            TransparentColorFlag=0
            self.ColorIndex =0




        self.TransparentColorFlag =TransparentColorFlag
        self.UserInputFlag        =UserInputFlag
        self.DisposalMethod       =DisposalMethod
        self.Reserved             =0x00
        self.pack()


    def debug(self):
        print("Graphics Control Extension Block")
        print("  Offset:               {0:02X}".format(self.internal_position))
        print("  Introducer:           {0:02X}".format(self.Introducer))
        print("  Label:                {0:02X}".format(self.Label))
        print("  BlockSize:            {0}".format(self.BlockSize))
        print("  Packed:               {0}".format(self.Packed))
        print("  DelayTime:            {0}".format(self.DelayTime))
        print("  ColorIndex:           {0}".format(self.ColorIndex))
        print("  Terminator:           {0}".format(self.Terminator))
        print("  TransparentColorFlag: {0}".format(self.TransparentColorFlag))
        print("  UserInputFlag:        {0}".format(self.UserInputFlag))
        print("  DisposalMethod:       {0}".format(self.DisposalMethod))
        print("  Reserved:             {0}".format(self.Reserved))
    