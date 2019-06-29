# cython: profile=True
# cython: linetrace=True
# cython: binding=True
# cython: language_level=2


class CommentExtension:
    #  5 to 259 bytes in total length
    def __init__(self,stream):
        self.internal_position=stream.pos
        self.Introducer= stream.byte(value=0x21)        # Extension Introducer (always 21h)
        self.Label= stream.byte(value=0xFE)             # Comment Label (always FEh)
        self.block_size=stream.byte()
        data=[]
        while self.block_size>0:
            fragment=stream.byte(self.block_size)
            if self.block_size==1:
                data+=[fragment]
            else:
                data+=fragment
            self.block_size=stream.byte()
        self.CommentData=data
        #self.Terminator= stream.byte(value=0x00)       # Block Terminator (always 0)

    def debug(self):
        print("Comment Extension Block")
        print("  Offset: {0:02X}".format(self.internal_position))
        print("  Introducer: {0:02X}".format(self.Introducer))
        print("  Label: {0:02X}".format(self.Label))
        print("  CommentData: {0}".format(self.CommentData))
        #print("  Terminator: {0:02X}".format(self.Terminator))
