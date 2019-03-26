class Header:
    def __init__(self,stream):
        self.internal_position=stream.pos
        gif_sig='GIF'
        gif_sig_ver=['87a','89a']
        # Header
        self.Signature= stream.string(3,value=gif_sig)        # Header Signature (always "GIF") 
        self.Version= stream.string(3,value=gif_sig_ver)      # GIF format version("87a" or "89a")
        # Logical Screen Descriptor
        self.ScreenWidth= stream.word()                       # Width of Display Screen in Pixels
        self.ScreenHeight= stream.word()                      # Height of Display Screen in Pixels
        self.Packed= stream.byte()                            # Screen and Color Map Information
        self.BackgroundColor= stream.byte()                   # Background Color Index
        self.AspectRatio= stream.byte()                       # Pixel Aspect Ratio

        # computed
        self.GlobalColorTableSize=stream.bit(self.Packed,0,3)
        self.ColorTableSortFlag=stream.bit(self.Packed,3)
        self.ColorResolution=stream.bit(self.Packed,4,3)
        self.GlobalColorTableFlag=stream.bit(self.Packed,7)
        self.NumberOfGlobalColorTableEntries=1 << (self.GlobalColorTableSize + 1)


    def debug(self):
        print("Header")
        print("  Offset: {0:02X}".format(self.internal_position))
        print("  Signature: {0}".format(self.Signature))
        print("  Version: {0}".format(self.Version))
        print("  ScreenWidth: {0}".format(self.ScreenWidth))
        print("  ScreenHeight: {0}".format(self.ScreenHeight))
        print("  Packed: {0}".format(self.Packed))
        print("  BackgroundColor: {0}".format(self.BackgroundColor))
        print("  AspectRatio: {0}".format(self.AspectRatio))
        print("  GlobalColorTableSize: {0}".format(self.GlobalColorTableSize))
        print("  ColorTableSortFlag: {0}".format(self.ColorTableSortFlag))
        print("  ColorResolution: {0}".format(self.ColorResolution))
        print("  GlobalColorTableFlag: {0}".format(self.GlobalColorTableFlag))
        print("  NumberOfGlobalColorTableEntries: {0}".format(self.NumberOfGlobalColorTableEntries))

