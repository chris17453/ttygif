# cython: profile=True
# cython: binding=True
# cython: language_level=2


from cpython cimport array
from libc.string cimport memset

from .graphics cimport match_color_index, create_default_palette
from libc.stdint cimport uint32_t, int64_t,uint16_t,uint8_t,int32_t
from .image cimport image
from .font cimport font
from .theme cimport theme as theme_loader
from .display_state cimport display_state


cdef class terminal_graphics:


    def __cinit__(self,int character_width=-1,int character_height=-1,theme_name=None,
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
            px_width    =character_width  * image_font.width
            px_height   =character_height * image_font.height
        
        # define displays by screen dimentions and calculate characters
        else:
            px_width    =viewport_width
            px_height   =viewport_height

            char_width  = viewport_width  / image_font.height
            char_height = viewport_height / image_font.width

        self.theme      = theme_loader(theme_name)
        self.state      = display_state(char_width,char_height,user_theme=self.theme)
        self.alt_state  = display_state(char_width,char_height,user_theme=self.theme)
        self.screen     = image(3,char_width ,char_height ,self.theme.palette,0               )
        self.alt_screen = image(3,char_width ,char_height ,self.theme.palette,0                )
        self.viewport   = image(1,px_width  + self.theme.padding.left + self.theme.padding.right   ,
                                  px_height + self.theme.padding.top  + self.theme.padding.bottom,
                                  self.theme.palette,self.state.background)
        self.display_alt_screen = None


    cdef alternate_screen_on(self):
        cdef image temp_image
        cdef display_state temp_state
        if self.display_alt_screen==None:
            self.display_alt_screen=True
            temp_image=self.screen
            self.screen=self.alt_screen
            self.alt_screen=temp_image
        
            temp_state=self.state
            self.state=self.alt_state
            self.alt_state=temp_state
        

    cdef alternate_screen_off(self):
        cdef image temp_image
        cdef display_state temp_state
        if self.display_alt_screen==True:
            self.display_alt_screen=None
            temp_image=self.screen
            self.screen=self.alt_screen
            self.alt_screen=temp_image

            temp_state=self.state
            self.state=self.alt_state
            self.alt_state=temp_state

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
            self.draw_character(ord(i),x,y,0,15)
            x+=1

    cdef draw_character(self,int character,int x,int y,int foreground_color,int background_color):
        cdef int screen_pos    
        cdef int char_pos  =self.font.offset[character]
        cdef uint8_t  pixel
        for fy in xrange(0,self.font.height):
            for fx in xrange(0,self.font.width):
                screen_pos=self.theme.padding.left+x*self.font.width+fx+(self.theme.padding.top+fy+self.font.height*y)*self.viewport.dimentions.width
                pixel=self.font.graphic[char_pos]
                if pixel==1:
                    self.viewport.data[screen_pos]=foreground_color
                else:
                    if background_color!=self.theme.transparent:
                        self.viewport.data[screen_pos]=background_color
                char_pos+=1

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
    
    cdef copy(self,layer temp):
        
        if temp==None:
            return
        if  temp.mode=="9slice":
            temp.image.copy_9slice(self.viewport,temp.outer,temp.inner,self.viewport.get_rect(),temp.copy_mode)
        elif temp.mode=="copy":
            temp.image.copy(self.viewport,temp.bounds,temp.dst)


    cdef render(self):
        cdef int zindex=-10
        #if self.state.default_background==self.theme.transparent:
         #   self.viewport.clear(0);
        ##lse:
        cdef uint8_t[3] clear_pixel=[self.state.default_foreground,self.state.default_background,0xFF]
        self.viewport.clear(clear_pixel)
        self.copy(self.theme.layer1)
        self.copy(self.theme.layer2)
        
        
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
                self.draw_character(character,x,y,fg,bg)

        self.copy(self.theme.layer3)
        self.copy(self.theme.layer4)
        self.copy(self.theme.layer5)
        
  
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
    