from .stream import DataStream
from .Header import Header
from .ImageDescriptor import ImageDescriptor
from .ImageData import ImageData
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
        self.comments=[]
        self.frames=[]
        self.applications=[]
        if self.header.GlobalColorTableFlag==True:
            self.global_color_table=self.load_color_table(self.header.NumberOfGlobalColorTableEntries)
        else:
            # TODO default global color table
            x=1
        
        loop=True
        frame=0
        while loop:
            # try for an image
            gc=self.load_graphics_control_extension()
            if gc:
                descriptor =self.load_image_descriptor()
                if descriptor:
                    if descriptor.LocalColorTableFlag==True:
                        local_color_table=self.load_color_table(descriptor.NumberOfGlobalColorTableEntries)
                    else:
                        local_color_table=None
                    imagedata=self.load_image_data()
                    self.frames.append({'frame':frame,'type':'image','gc':gc,'descriptor':descriptor,'color_table':local_color_table,'image':imagedata})
                    frame+=1
                continue
            
            # try for extensions
            comment    =self.load_comment_extension()
            if comment:
                self.comments.append(comment)
                continue

            plain_text =self.load_plain_text_extension()
            if plain_text:
                self.frames.append({'frame':frame,'type':'text','data':plain_text})
                frame+=1

                continue
            # stuff at the start of the file... not realy frame dependant?
            application=self.load_application_extension()
            if application:
                self.applications.append(application)
                continue
            
            # EOF
            trailer=self.load_trailer()
            if trailer:
                print ("END POSITION: {0:02X}".format(self.stream.pos))
                break
            print ("POSITION: {0:02X}".format(self.stream.pos))
            break
        self.frames=frame
        print("Stats")
        print("  Frames: {0}".format(self.frames))
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

    def load_trailer(self):
        try:
            self.stream.pin()
            trailer=Trailer(self.stream)
            trailer.debug()
            return trailer
        except Exception as ex:
            print("Trying:{0}".format(ex))
            self.stream.rewind()

    def load_color_table(self,entries):
        try:
            self.stream.pin()
            colortable=ColorTable(self.stream,entries)
            colortable.debug()
            return colortable
        except Exception as ex:
            print("Trying:{0}".format(ex))
            self.stream.rewind()

    def load_image_data(self):
        try:
            self.stream.pin()
            imagedata=ImageData(self.stream)
            imagedata.debug()
            return imagedata
        except Exception as ex:
            print("Trying:{0}".format(ex))
            self.stream.rewind()


   
if __name__=='__main__':
     gif("kermit.gif")
    