class ApplicationExtension:
    def __init__(self,stream):
        self.Introducer= stream.byte(value=0x21)         # Extension Introducer (always 21h) 
        self.Label= stream.byte(value=0xFF)              # Extension Label (always FFh) 
        self.BlockSize= stream.byte(value=0x0B)          # Size of Extension Block (always 0Bh) 
        self.Identifier= stream.char(8)                  # Application Identifier 
        self.AuthentCode= stream.byte(3)                 # Application Authentication Code 
        self.ApplicationData= stream.byte(eod=0x00)      # Point to Application Data sub-blocks 
        self.Terminator= stream.byte(value=0x00)         # Block Terminator (always 0) 
    
    def debug(self):
        print("Application Extension Block")
        print("  Introducer: {0}".format(self.Introducer))
        print("  Label: {0}".format(self.Label))
        print("  BlockSize: {0}".format(self.BlockSize))
        print("  Identifier: {0}".format(self.Identifier))
        print("  AuthentCode: {0}".format(self.AuthentCode))
        print("  ApplicationData: {0}".format(self.ApplicationData))
        print("  Terminator: {0}".format(self.Terminator))
    