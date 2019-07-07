# cython: profile=True
# cython: linetrace=True
# cython: binding=True
# cython: language_level=2


# Global header of gif file

class gif_header:
    def __init__(self,stream):
        self.stream=stream
        self.internal_position=self.stream.pos

    
    def read(self):
        self.internal_position=self.stream.pos
        gif_sig='GIF'
        gif_sig_ver=['87a','89a']
        # Header
        self.Signature               = self.stream.string(3,value=gif_sig)       # Header Signature (always "GIF") 
        self.Version                 = self.stream.string(3,value=gif_sig_ver)   # GIF format version("87a" or "89a")
        # Logical Screen Descriptor
        self.ScreenWidth             = self.stream.word()                        # Width of Display Screen in Pixels
        self.ScreenHeight            = self.stream.word()                        # Height of Display Screen in Pixels
        self.Packed                  = self.stream.byte()                        # Screen and Color Map Information
        self.BackgroundColor         = self.stream.byte()                        # Background Color Index
        self.AspectRatio             = self.stream.byte()                        # Pixel Aspect Ratio

        # computed
        self.unpack()

    def write(self):
        self.pack()
        self.stream.write_string(self.Signature,3)
        self.stream.write_string(self.Version,3)
        self.stream.write_word  (self.ScreenWidth)
        self.stream.write_word  (self.ScreenHeight)
        self.stream.write_byte  (self.Packed)
        self.stream.write_byte  (self.BackgroundColor)
        self.stream.write_byte  (self.AspectRatio)

    
    def new(self):
        self.Signature              = "GIF"
        self.Version                = "89a"
        self.ScreenWidth            = 320
        self.ScreenHeight           = 240
        self.Packed                 = 0
        self.BackgroundColor        = 0
        self.AspectRatio            = 0
        self.GlobalColorTableSize   = 0
        self.ColorTableSortFlag     = 0
        self.ColorResolution        = 1
        self.GlobalColorTableFlag   = 1
        self.GlobalColorTableLength = 0

        self.pack()

    def unpack(self):
        self.GlobalColorTableSize    = self.stream.bit(self.Packed,0,3)
        self.ColorTableSortFlag      = self.stream.bit(self.Packed,3)
        self.ColorResolution         = self.stream.bit(self.Packed,4,3)
        self.GlobalColorTableFlag    = self.stream.bit(self.Packed,7)
        self.GlobalColorTableLength  = 1 << (self.GlobalColorTableSize + 1)

    def pack(self):
        self.Packed= self.GlobalColorTableFlag <<7
        self.Packed+=self.ColorResolution      <<4
        self.Packed+=self.ColorTableSortFlag   <<3
        self.Packed+=self.GlobalColorTableSize
        self.GlobalColorTableLength  = 1 << (self.GlobalColorTableSize + 1)

        
        

    def debug(self):
        print("Header")
        print("  Offset:                 {0:02X}".format(self.internal_position))
        print("  Signature:              {0}".format(self.Signature))
        print("  Version:                {0}".format(self.Version))
        print("  ScreenWidth:            {0}".format(self.ScreenWidth))
        print("  ScreenHeight:           {0}".format(self.ScreenHeight))
        print("  Packed:                 {0}".format(self.Packed))
        print("  BackgroundColor:        {0}".format(self.BackgroundColor))
        print("  AspectRatio:            {0}".format(self.AspectRatio))
        print("  GlobalColorTableSize:   {0}".format(self.GlobalColorTableSize))
        print("  ColorTableSortFlag:     {0}".format(self.ColorTableSortFlag))
        print("  ColorResolution:        {0}".format(self.ColorResolution))
        print("  GlobalColorTableFlag:   {0}".format(self.GlobalColorTableFlag))
        print("  GlobalColorTableLength: {0}".format(self.GlobalColorTableLength))

