# cython: profile=True
# cython: binding=True
# cython: language_level=2


from cpython cimport array
from libc.string cimport memset

from .graphics cimport match_color_index, create_default_palette
from libc.stdint cimport uint32_t, int64_t,uint16_t,uint8_t,int32_t
from .image cimport image
from .font cimport font
from .display_state cimport display_state


cdef class terminal_graphics:


    def __cinit__(self,int character_width=-1,int character_height=-1,
                       int viewport_width=-1,int viewport_height=-1 ,font image_font=None):
        self.font               = image_font

        cdef int px_width
        cdef int px_height
        cdef int char_width
        cdef int char_height
        
        # define displays by chaaracters on screen        
        if character_width>-1 and character_height>-1:
            char_width  =character_width
            char_height =character_height
            px_width    =character_width  * image_font.font_width
            px_height   =character_height * image_font.font_height
        
        # define displays by screen dimentions and calculate characters
        else:
            px_width    =viewport_width
            px_height   =viewport_height

            char_width  = viewport_width  / image_font.font_height
            char_height = viewport_height / image_font.font_width
            
        palette=create_default_palette()
        self.state      = display_state(char_width,char_height)
        self.alt_state  = display_state(char_width,char_height)
        self.screen     = image(3,char_width ,char_height ,palette,0                    )
        self.alt_screen = image(3,char_width ,char_height ,palette,0                    )
        self.viewport   = image(1,px_width   ,px_height   ,palette,self.state.background)
        self.alt_screen = None


    cdef alternate_screen_on(self):
        if self.alt_screen==None:
            cdef image temp_image=self.screen
            self.screen=alt.screen
            self.alt_screen=image
        

    cdef alternate_screen_off(self):
        if self.alt_screen=True:
            cdef image temp_image=self.screen
            self.screen=alt.screen
            self.alt_screen=image

    cdef scroll_buffer(self):
        cdef int top=self.state.scroll_top
        cdef int bottom=self.state.scroll_bottom
        cdef int length=self.state.scroll
        #print "len",length,top,bottom
        if 1==1:
            if length>0:
                for y in xrange(top,bottom+1):
                    for x in xrange(0,self.screen.dimentions.width):
                        if y+length<top or y+length>bottom:
                            pixel=[self.state.foreground,self.state.background,0]
                        else:
                            pixel=self.screen.get_pixel(x,y+length)
                        self.screen.put_pixel(x,y,pixel)
            else:
                for y in xrange(bottom,top-1):
                    for x in xrange(0,self.screen.dimentions.width):
                        if y+length<top or y+length>bottom:
                            pixel=[self.state.foreground,self.state.background,0]
                        else:
                            pixel=self.screen.get_pixel(x,y+length)
                        self.screen.put_pixel(x,y,pixel)
            
        self.state.scroll=0
        #cdef int row_pos=buffer_length-src_image.dimentions.stride
        #array.resize(src_image.data,buffer_length)  
        #memset(&src_image.data.data.as_uchars[row_pos],init_value,src_image.dimentions.length)        

    # write a character to the text buffer with the curent text attributes
    cdef write(self,int character):
        cdef int x=self.state.cursor_x
        cdef int y=self.state.cursor_y

        if character>255:
            err_msg="Charactrer out of xrange -{0}".format(character)
            raise Exception(err_msg)

        if self.state.reverse_video:
            pix=[self.state.background,self.state.foreground,character]
        else:
            pix=[self.state.foreground,self.state.background,character]    
        #print("PIX",pix)
        self.screen.put_pixel(x,y,pix)

    cdef draw_string(self,x,y,data):
        for i in data:
            self.draw_character(ord(i),x,y,0,0,15)
            x+=1

    cdef draw_character(self,int character,int x,int y,int offset,int foreground_color,int background_color):
        cdef int fs            = self.font.width
        cdef int fw            = self.font.font_width
        cdef int fh            = self.font.font_height
        cdef int fox           = self.font.offset_x
        cdef int foy           = self.font.offset_y
        cdef int fsx           = self.font.spacing_x
        cdef int fsy           = self.font.spacing_y
        cdef int transparent   = self.font.transparent
        cdef int cx            = int(character%self.font.chars_per_line)
        cdef int cy            = int(character/self.font.chars_per_line)
        cdef int pre_x         = fox+cx*fw
        cdef int pre_y         = foy+cy*fh*fs
        cdef int pre           = pre_x+pre_y
        cdef int sy            = fh+fsy
        cdef int sx            = fw+fsx
        cdef int screen_pos    = sx*x+sy*y*self.viewport.dimentions.stride
        cdef int char_pos      = pre
        cdef int fx            = 0
        cdef int fy            = 0
        cdef int new_line_stride      =self.viewport.dimentions.stride-(fw+fsx)
        cdef int new_char_line_stride =fs-(fw+fsx)
        cdef uint8_t  pixel
        loop=True
        while loop:
            pixel=self.font.graphic[char_pos]
            if pixel!=transparent:
                self.viewport.data[screen_pos]=foreground_color
            else:
                if background_color!=0:
                    self.viewport.data[screen_pos]=background_color
            char_pos+=1
            fx+=1
            screen_pos+=1
            if fx==sx:
                fx=0
                fy+=1
                char_pos+=new_char_line_stride
                screen_pos+=new_line_stride
                if fy==sy:
                    loop=None

    cdef get_text(self):
        text=""
        for y in xrange(0,self.screen.dimentions.height):
            for x in xrange(0,self.screen.dimentions.width):
                pixel=self.screen.get_pixel(x,y)
                character=pixel[2]
                # convert empty's to spaces
                if character<32:
                    character=32
                text+=unichr(character)
            text+="\n"
        return text
            

    #cdef get_buffer_height(self):
    #    #print self.buffer_rows,"ROWS"
    #    height=self.buffer_rows*font.font_height
    #    return height



   # def render_underlay(self,underlay,frame):
   #     self.underlay_flag=True
   #     
   #     for frame in underlay['frames']:
   #         if frame['image'] and frame['descriptor']:
   #             descriptor=frame['descriptor']
   #             src_image =frame['image'].data
   #             #print ("got stuff")
   #             break
   #     if None==descriptor or None == src_image:
   #         self.underlay_flag=None
   #         #print("BOM")
   #         return
   #     dst_x1=0
   #     dst_y1=0
   #     dst_x2=self.viewport_px_width-1
   #     dst_y2=self.viewport_px_height-1
   #     dst_width=self.viewport_px_width
   #     dst_height=self.viewport_px_height
   #     #print ("copy stuff")
   #     memset(self.video.data.as_voidptr, self.background_color, self.video_length * sizeof(char))
#  #      self.remap(underlay['global_color_table'].colors,src_image,self.color_table)
   #     self.copy_image( src_image  = src_image,
   #                 src_x1      = 0,
   #                 src_y1      = 0,
   #                 src_x2      = descriptor.Width-1,
   #                 src_y2      = descriptor.Height-1,
   #                 src_width  = descriptor.Width,
   #                 src_height = descriptor.Height,
   #                 dst_image  = self.video,
   #                 dst_x1      = dst_x1,
   #                 dst_y1      = dst_y1,
   #                 dst_x2      = dst_x2,
   #                 dst_y2      = dst_y2,
   #                 dst_width  = dst_width,
   #                 dst_height = dst_height)
#

    cdef foreground_from_rgb(self,r,g,b):
        cdef int color=match_color_index(r,g,b,self.viewport.palette)
        self.set_foreground(color)

    cdef background_from_rgb(self,r,g,b):
        cdef int color=match_color_index(r,g,b,self.viewport.palette)
        self.set_background(color)

    cdef set_foreground(self,color):
        self.state.foreground=color
    
    cdef set_background(self,color):
        self.state.background=color
    
    cdef render(self):
        #if None==self.underlay_flag:
        self.viewport.clear(self.state.default_background);
        cdef int fg =0
        cdef int bg =0
        cdef int x  =0
        cdef int y  =0
        cdef int character=0

        for y in xrange(0,self.screen.dimentions.height):
            for x in xrange(0,self.screen.dimentions.width):
                pixel=self.screen.get_pixel(x,y)
                fg=pixel[0]
                bg=pixel[1]
                character=pixel[2]
                self.draw_character(character,x,y,0,fg,bg)
  
    # convert the text stream to a text formated grid
#    cdef debug(self): 
#        print("VIEWPORT:")
#        print("  px height:          {0}".format(self.viewport_px_height))
#        print("  px width:           {0}".format(self.viewport_px_width))
#        print("  video buffer size:  {0}".format(len(self.video)))
#
#        print("Buffer:")
#        print("  char height:        {0}".format(self.viewport_char_height))
#        print("  char width:         {0}".format(self.viewport_char_width))
#        print("  char stride:        {0}".format(self.viewport_char_stride))
#        print("  char buffer size:   {0}".format(len(self.buffer)))
#        print("  buffer char height: {0}".format(self.buffer_rows))
#
    