
# array..
# ColorTableSize = 3L * (1L << (SizeOfGlobalColorTable + 1));
class ColorTable:
    def __init__(self,stream,entries):
        self.internal_position=stream.pos
        self.colors=[]
        for i in range(0,entries):
            red= stream.byte()                           # Red Color Element 
            green= stream.byte()                         # Green Color Element 
            blue= stream.byte()                          # Blue Color Element 
            self.colors.append([red,green,blue])
    
    def debug(self):
        index=0
        print("Color Table Block")
        print("  Offset: {0:02X}".format(self.internal_position))

        for i in self.colors:
            print("  Index:{3:3}, R:0x{0:02X}, G:0x{1:02X}, B:0x{2:02X}".format(i[0],i[1],i[2],index))
            index+=1
