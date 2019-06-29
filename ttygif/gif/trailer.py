# cython: profile=True
# cython: linetrace=True
# cython: binding=True
# cython: language_level=2


class trailer:
    def __init__(self,stream):
        self.stream=stream
        self.Trailer=None

    def read(self):
        self.internal_position=self.stream.pos
        self.Trailer=self.stream.byte(value=0x3B)
    
    def write(self):
        self.stream.write_byte(0x3B)

    def new(self):
        self.Trailer=0x3B

    def debug(self):
        print("Trailer")
        print("  Offset: {0:02X}".format(self.internal_position))
