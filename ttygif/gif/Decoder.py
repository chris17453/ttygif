from .stream import DataStream
from .header import gif_header
from .ImageDescriptor import ImageDescriptor
from .ImageData import ImageData
from .graphics_control_extension import graphics_control_extension
from .application_extension import application_extension
from .CommentExtension import CommentExtension
from .PlainTextExtension import PlainTextExtension
from .trailer import trailer
from .color_table import gif_color_table

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
        self.header       =gif_header(self.stream)
        self.header.read()
        self.comments     =[]
        self.frames       =[]
        self.applications =[]
        if self.header.GlobalColorTableFlag==True:
            print self.header.GlobalColorTableLength
            print self.header.GlobalColorTableSize
            self.global_color_table=self.load_color_table(self.header.GlobalColorTableLength)
        else:
            # TODO default global color table
            self.global_color_table=None

        #if self.debug:
        self.header.debug()
        print ("{0:02X}".format(self.stream.pos))
        loop=True
        frame=0
        old_pos=-1
        info={}
        while loop:
            # try for an image
            gc=self.load_graphics_control_extension()
            if gc:
                gc.debug()
                print ("GC")
                descriptor=None
                local_color_table=None
                imagedata=None
                info={'frame':frame,'type':'image','gc':gc,'descriptor':descriptor,'color_table':local_color_table,'image':imagedata}
                continue

            descriptor =self.load_image_descriptor()
            if descriptor:
                descriptor.debug()
                if descriptor.LocalColorTableFlag==True:
                    print ("Has color table")
                    local_color_table=self.load_color_table(descriptor.ColorTableLength)
                else:
                    print ("No color table")
                    local_color_table=None
                pixels=descriptor.Height*descriptor.Width
                imagedata=self.load_image_data(pixels,descriptor.InterlaceFlag,descriptor.Width)
                print ("Image Data")
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
            _trailer=self.load_trailer()
            if _trailer:
                print ("Trailer")
                #print ("END POSITION: {0:02X}".format(self.stream.pos))
                break
            if self.debug:
                print ("POSITION: {0:02X}".format(self.stream.pos))
            if old_pos==self.stream.pos:
                print ("POSITION: {0:02X}".format(self.stream.pos))
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
            print("Trying:{0}".format(ex))
            self.stream.rewind()

    def load_comment_extension(self):
        try:
            self.stream.pin()
            comment=CommentExtension(self.stream)
            if self.debug:
                comment.debug()
            return comment
        except Exception as ex:
            #print("Trying:{0}".format(ex))
            self.stream.rewind()
            
    def load_graphics_control_extension(self):
        try:
            self.stream.pin()
            graphiccontrol=graphics_control_extension(self.stream)
            graphiccontrol.read()
            if self.debug:
                graphiccontrol.debug()
            return graphiccontrol
        except Exception as ex:
            print("Trying:{0}".format(ex))
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

            applicaitonextension=application_extension(self.stream)
            applicaitonextension.read()
            if self.debug:
                applicaitonextension.debug()
            return applicaitonextension
        except Exception as ex:
            #print("Trying:{0}".format(ex))
            self.stream.rewind()

    def load_trailer(self):
        try:
            self.stream.pin()
            _trailer=trailer(self.stream)
            _trailer.read()
            if self.debug:
                _trailer.debug()
            return _trailer
        except Exception as ex:
            #print("Trying:{0}".format(ex))
            self.stream.rewind()

    def load_color_table(self,entries):
        try:
            self.stream.pin()
            colortable=gif_color_table(self.stream)
            colortable.read(entries)
            if self.debug:
                colortable.debug()
            return colortable
        except Exception as ex:
            print("Trying:{0}".format(ex))
            self.stream.rewind()

    def load_image_data(self,pixels,interlace,width):
        #try:
            self.stream.pin()
            imagedata=ImageData(self.stream)
            imagedata.read(pixels,interlace,width)
            if self.debug:
                imagedata.debug()
            return imagedata
        #except Exception as ex:
        #    #print("Trying:{0}".format(ex))
        #    self.stream.rewind()
