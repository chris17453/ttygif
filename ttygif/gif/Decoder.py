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

class Decoder:
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

    # PixelAspectRatio = (AspectRatio + 15) / 64;
    # GlobalColorTableLength = 	 (2L << (SizeOfTheGlobalColorTable + 1));

    def __init__(self,file=None,debug=None):
        self.stream   =DataStream(file)
        self.stream.open()
        self.debug        =debug
        self.file         =file
        self.header       =Header(self.stream)
        self.header.read()
        self.comments     =[]
        self.frames       =[]
        self.applications =[]
        if self.header.GlobalColorTableFlag==True:
            self.global_color_table=self.load_color_table(self.header.GlobalColorTableLength)
        else:
            # TODO default global color table
            self.global_color_table=None

        if self.debug:
            self.header.debug()

        loop=True
        frame=0
        old_pos=-1
        info={}
        while loop:
            # try for an image
            gc=self.load_graphics_control_extension()
            if gc:
                descriptor=None
                local_color_table=None
                imagedata=None
                info={'frame':frame,'type':'image','gc':gc,'descriptor':descriptor,'color_table':local_color_table,'image':imagedata}
                continue

            descriptor =self.load_image_descriptor()
            if descriptor:
                if descriptor.LocalColorTableFlag==True:
                    local_color_table=self.load_color_table(descriptor.NumberOfColorTableEntries)
                else:
                    local_color_table=None
                pixels=descriptor.Height*descriptor.Width
                imagedata=self.load_image_data(pixels,descriptor.InterlaceFlag,descriptor.Width)
                info['descriptor']=descriptor
                info['color_table']=local_color_table
                info['image']=imagedata
                self.frames.append(info)
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
                #print ("END POSITION: {0:02X}".format(self.stream.pos))
                break
            if self.debug:
                print ("POSITION: {0:02X}".format(self.stream.pos))
            if old_pos==self.stream.pos:
                raise Exception ("Forever loop. Death.")
            old_pos=self.stream.pos
                        #break
        
        self.frame_count=frame
        self.stream.close()
        self.stream=None
        if self.debug:
            self.stats()
    
    def get(self):
        return {'header':self.header,
                'global_color_table':self.global_color_table,
                'frame_count':self.frame_count,
                'frames':self.frames,
                'comments':self.comments,
                'applications':self.applications}

    def stats(self):
        print("Stats")
        print("  Frames: {0}".format(self.frame_count))

    def load_image_descriptor(self):
        try:
            self.stream.pin()
            descriptor=ImageDescriptor(self.stream)
            descriptor.read()
            if self.debug:
                descriptor.debug()
            return descriptor
        except Exception as ex:
            #print("Trying:{0}".format(ex))
            self.stream.rewind()

    def load_comment_extension(self):
        try:
            self.stream.pin()
            comment=CommentExtension(self.stream)
            if self.debug:
                comment.debug()
            return comment
        except Exception as ex:
            print("Trying:{0}".format(ex))
            self.stream.rewind()
            
    def load_graphics_control_extension(self):
        try:
            self.stream.pin()
            graphiccontrol=GraphicsControlExtension(self.stream)
            graphiccontrol.read()
            if self.debug:
                graphiccontrol.debug()
            return graphiccontrol
        except Exception as ex:
            #print("Trying:{0}".format(ex))
            self.stream.rewind()

    def load_plain_text_extension(self):
        try:
            self.stream.pin()
            plaintext=PlainTextExtension(self.stream)
            if self.debug:
                plaintext.debug()
            return plaintext
        except Exception as ex:
            #print("Trying:{0}".format(ex))
            self.stream.rewind()
    
    def load_application_extension(self):
        try:
            self.stream.pin()
            applicaitonextension=ApplicationExtension(self.stream)
            if self.debug:
                applicaitonextension.debug()
            return applicaitonextension
        except Exception as ex:
            #print("Trying:{0}".format(ex))
            self.stream.rewind()

    def load_trailer(self):
        try:
            self.stream.pin()
            trailer=Trailer(self.stream)
            trailer.read()
            if self.debug:
                trailer.debug()
            return trailer
        except Exception as ex:
            #print("Trying:{0}".format(ex))
            self.stream.rewind()

    def load_color_table(self,entries):
        try:
            self.stream.pin()
            colortable=ColorTable(self.stream)
            colortable.read(entries)
            if self.debug:
                colortable.debug()
            return colortable
        except Exception as ex:
            #print("Trying:{0}".format(ex))
            self.stream.rewind()

    def load_image_data(self,pixels,interlace,width):
        #try:
            self.stream.pin()
            imagedata=ImageData(self.stream,pixels,interlace,width)
            if self.debug:
                imagedata.debug()
            return imagedata
        #except Exception as ex:
        #    #print("Trying:{0}".format(ex))
        #    self.stream.rewind()
