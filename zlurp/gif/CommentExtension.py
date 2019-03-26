class CommentExtension:
    #  5 to 259 bytes in total length
    def __init__(self,stream):
        self.internal_position=stream.pos
        self.Introducer= stream.byte(value=0x21)        # Extension Introducer (always 21h)
        self.Label= stream.byte(value=0xFE)             # Comment Label (always FEh)
        self.CommentData= stream.byte(eod=0x00)         # Pointer to Comment Data sub-blocks
        self.Terminator= stream.byte(value=0x00)       # Block Terminator (always 0)

    def debug(self):
        print("Comment Extension Block")
        print("  Offset: {0:02X}".format(self.internal_position))
        print("  Introducer: {0:02X}".format(self.Introducer))
        print("  Label: {0:02X}".format(self.Label))
        print("  CommentData: {0:02X}".format(self.CommentData))
        print("  Terminator: {0:02X}".format(self.Terminator))
