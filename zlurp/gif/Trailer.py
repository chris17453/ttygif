class Trailer:
    def __init__(self,stream):
        self.internal_position=stream.pos
        self.Trailer= stream.byte(value=0x3B)
    
    def debug(self):
        print("Trailer")
        print("  Offset: {0:02X}".format(self.internal_position))
