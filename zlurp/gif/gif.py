from .stream import DataStream
from .Header import Header
from .ImageDescriptor import ImageDescriptor
from .GraphicsControlExtension import GraphicsControlExtension
from .ApplicationExtension import ApplicationExtension
from .CommentExtension import CommentExtension
from .PlainTextExtension import PlainTextExtension
from .Trailer import Trailer
from .ColorTable import ColorTable

# GIT 89A
# freehand implimentation of information found at  https://www.fileformat.info/format/gif/egff.htm
# Charles Watkins

class gif:
    #################################3
    # header
    #  - logical screen descriptor
    # global color table
    # comment extension
    # application extension
    # graphic control extension
    # local image descriptor
    # local color table
    # image data
    # comment extension
    # plain test extension
    # trailer

    # 	PixelAspectRatio = (AspectRatio + 15) / 64;
    # NumberOfGlobalColorTableEntries = 	 (1L << (SizeOfTheGlobalColorTable + 1));

    def __init__(self,file=None):
        self.file=file
        self.stream=DataStream(file)
        
        self.stream.open()
        self.header=Header(self.stream)
        self.header.debug()
        if self.header.GlobalColorTableFlag==True:
            self.global_color_table=ColorTable(self.header.NumberOfGlobalColorTableEntries,self.stream)
            self.global_color_table.debug()
        else:
            # TODO default global color table
            x=1
        
        loop=True
        while loop:
            # record where we are before trying...
            image={}
            
            descriptor =self.load_image_descriptor()
            if descriptor:
                continue

            comment    =self.load_comment_extension()
            
            if comment:
                continue
            gc         =self.load_graphics_control_extension()
            if gc:
                continue
            
            plain_text =self.load_plain_text_extension()
            if plain_text:
                continue

            application=self.load_application_extension()
            if application:
                continue
            print ("EH?")
            break

        self.stream.close()



    def load_image_descriptor(self):
        try:
            self.stream.pin()
            descriptor=ImageDescriptor(self.stream)
            descriptor.debug()
            return descriptor
        except Exception as ex:
            #print("Trying:{0}".format(ex))
            self.stream.rewind()

    def load_comment_extension(self):
        try:
            self.stream.pin()
            comment=CommentExtension(self.stream)
            comment.debug()
            return coment
        except Exception as ex:
            #print("Trying:{0}".format(ex))
            self.stream.rewind()
            
    def load_graphics_control_extension(self):
        try:
            self.stream.pin()
            graphiccontrol=GraphicsControlExtension(self.stream)
            graphiccontrol.debug()
            return graphiccontrol
        except Exception as ex:
            #print("Trying:{0}".format(ex))
            self.stream.rewind()

    def load_plain_text_extension(self):
        try:
            self.stream.pin()
            plaintext=PlainTextExtension(self.stream)
            plaintext.debug()
            return plaintext
        except Exception as ex:
            #print("Trying:{0}".format(ex))
            self.stream.rewind()
    
    def load_application_extension(self):
        try:
            self.stream.pin()
            applicaitonextension=ApplicationExtension(self.stream)
            applicaitonextension.debug()
            return applicaitonextension
        except Exception as ex:
            #print("Trying:{0}".format(ex))
            self.stream.rewind()



   
if __name__=='__main__':
     gif("kermit.gif")
    