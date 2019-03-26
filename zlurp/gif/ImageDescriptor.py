class ImageDescriptor:
    def __init__(self,stream):
        self.internal_position=stream.pos
        self.Separator= stream.byte(value=0x2C)                     # Image Descriptor identifier
        self.Left= stream.word()                          # X position of image on the display
        self.Top= stream.word()                           # Y position of image on the display
        self.Width= stream.word()                         # Width of the image in pixels
        self.Height= stream.word()                        # Height of the image in pixels
        self.Packed= stream.byte()                        # Image and Color Table Data Information

        # computed
        self.LocalColorTableFlag=stream.bit(self.Packed,5)
        self.InterlaceFlag=stream.bit(self.Packed,5)
        self.SortFlag=stream.bit(self.Packed,5)
        self.Reserved=stream.bit(self.Packed,3,2)
        self.LocalColorTableSize=stream.bit(self.Packed,5,3)
        self.NumberOfColorTableEntries=1 << (self.LocalColorTableSize + 1)

        #Group 1 : Every 8th. row, starting with row 0.              (Pass 1)
        #Group 2 : Every 8th. row, starting with row 4.              (Pass 2)
        #Group 3 : Every 4th. row, starting with row 2.              (Pass 3)
        #Group 4 : Every 2nd. row, starting with row 1.              (Pass 4)
    
    def debug(self):
        
        print("Image Descriptor Block")
        print("  Offset: {0:02X}".format(self.internal_position))
        print("  Separator: {0:02X}".format(self.Separator))
        print("  Left: {0:02X}".format(self.Left))
        print("  Top: {0:02X}".format(self.Top))
        print("  Width: {0:02X}".format(self.Width))
        print("  Height: {0:02X}".format(self.Height))
        print("  Packed: {0:02X}".format(self.Packed))
        print("  LocalColorTableFlag: {0}".format(self.LocalColorTableFlag))
        print("  InterlaceFlag: {0}".format(self.InterlaceFlag))
        print("  SortFlag: {0}".format(self.SortFlag))
        print("  Reserved: {0:02X}".format(self.Reserved))
        print("  LocalColorTableSize: {0:02X}".format(self.LocalColorTableSize))
