# cython: profile=True
# cython: linetrace=True
# cython: binding=True
# cython: language_level=2


class image_descriptor:
    def __init__(self,stream):
        self.stream=stream
        self.internal_position=self.stream.pos


    def read(self):
        self.internal_position=self.stream.pos
        self.Separator = self.stream.byte(value=0x2C)             # Image Descriptor identifier
        self.Left      = self.stream.word()                       # X position of image on the display
        self.Top       = self.stream.word()                       # Y position of image on the display
        self.Width     = self.stream.word()                       # Width of the image in pixels
        self.Height    = self.stream.word()                       # Height of the image in pixels
        self.Packed    = self.stream.byte()                       # Image and Color Table Data Information

        # computed
        self.unpack()

    def write(self):
        self.internal_position=self.stream.pos
        self.pack()
        self.stream.write_byte(self.Separator)
        self.stream.write_word(self.Left     )
        self.stream.write_word(self.Top      )
        self.stream.write_word(self.Width    )
        self.stream.write_word(self.Height   )
        self.stream.write_byte(self.Packed   )

    def new(self,   Separator=0x2C,
                    Left=0,
                    Top=0,
                    Width=300,
                    Height=240,
                    LocalColorTableFlag=0,
                    InterlaceFlag=0,
                    SortFlag=0,
                    Reserved=0,
                    LocalColorTableSize=0):
        self.Separator=Separator
        self.Left     =Left
        self.Top      =Top
        self.Width    =Width
        self.Height   =Height
        # computed
        self.LocalColorTableFlag  =LocalColorTableFlag
        self.InterlaceFlag        =InterlaceFlag
        self.SortFlag             =SortFlag
        self.Reserved             =Reserved
        self.LocalColorTableSize  =LocalColorTableSize

        self.pack()

    def unpack(self):
        self.LocalColorTableFlag  =self.stream.bit(self.Packed,7)
        self.InterlaceFlag        =self.stream.bit(self.Packed,6)
        self.SortFlag             =self.stream.bit(self.Packed,5)
        self.Reserved             =self.stream.bit(self.Packed,3,2)
        self.LocalColorTableSize  =self.stream.bit(self.Packed,0,3)
        self.ColorTableLength     =1 << (self.LocalColorTableSize + 1)

    def pack(self):
        self.Packed=0
        self.Packed+=self.LocalColorTableFlag  <<7
        self.Packed+=self.InterlaceFlag        <<6
        self.Packed+=self.SortFlag             <<5
        self.Packed+=self.Reserved             <<3
        self.Packed+=self.LocalColorTableSize
        

        #Group 1 : Every 8th. row, starting with row 0.              (Pass 1)
        #Group 2 : Every 8th. row, starting with row 4.              (Pass 2)
        #Group 3 : Every 4th. row, starting with row 2.              (Pass 3)
        #Group 4 : Every 2nd. row, starting with row 1.              (Pass 4)
    
    def debug(self):
        print("Image Descriptor Block")
        print("  Offset:              {0:02X}".format(self.internal_position))
        print("  Separator:           {0:02X}".format(self.Separator))
        print("  Left:                {0:02X}".format(self.Left))
        print("  Top:                 {0:02X}".format(self.Top))
        print("  Width:               {0:02X}".format(self.Width))
        print("  Height:              {0:02X}".format(self.Height))
        print("  Packed:              {0:02X}".format(self.Packed))
        print("  LocalColorTableFlag: {0}".format(self.LocalColorTableFlag))
        print("  InterlaceFlag:       {0}".format(self.InterlaceFlag))
        print("  SortFlag:            {0}".format(self.SortFlag))
        print("  Reserved:            {0:02X}".format(self.Reserved))
        print("  LocalColorTableSize: {0:02X}".format(self.LocalColorTableSize))
