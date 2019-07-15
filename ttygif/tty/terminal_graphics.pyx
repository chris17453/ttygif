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

        self.theme      = theme_loader(theme_name,px_width,px_height)
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
                        self.screen.put_pixel_3byte(x,y,pixel)
            else:
                for y in xrange(bottom,top-1):
                    for x in xrange(0,self.screen.dimentions.width):
                        if y+length<top or y+length>bottom:
                            pixel=[self.state.foreground,self.state.background,0]
                        else:
                            pixel=self.screen.get_pixel(x,y+length)
                        self.screen.put_pixel_3byte(x,y,pixel)
            
        self.state.scroll=0
        #cdef int row_pos=buffer_length-src_image.dimentions.stride
        #array.resize(src_image.data,buffer_length)  
        #memset(&src_image.data.data.as_uchars[row_pos],init_value,src_image.dimentions.length)        

    # write a character to the text buffer with the curent text attributes
    cdef write(self,uint8_t character):
        cdef int x=self.state.cursor_x
        cdef int y=self.state.cursor_y
        cdef uint8_t[3]  pix=[0,0,0]
        if character>255:
            err_msg="Charactrer out of xrange -{0}".format(character)
            raise Exception(err_msg)

        if self.state.reverse_video:
            pix=[self.state.background,self.state.foreground,character]
        else:
            pix=[self.state.foreground,self.state.background,character]    
        #print("PIX",pix)
        self.screen.put_pixel_3byte(x,y,pix)

    cdef draw_string(self,x,y,data):
        cdef uint8_t[3] element= [0,15,0]
        for i in data:
            element[2]=ord(i)
            self.draw_character(x,y,element)
            x+=1

    cdef draw_character(self,int x,int y,uint8_t[3] element):
        cdef int screen_pos    
        cdef int char_pos  =self.font.offset[element[2]]
        cdef uint8_t  pixel
        cdef int screen_base=self.theme.padding.left+x*self.font.width+(self.theme.padding.top+y*self.font.height)*self.viewport.dimentions.width
        cdef int screen_base2=0
        #screen_pos=self.theme.padding.left+x*self.font.width+fx+(self.theme.padding.top+fy+self.font.height*y)*self.viewport.dimentions.width
                
        for fy in xrange(0,self.font.height):
            screen_base2=screen_base+fy*self.viewport.dimentions.width
            for fx in xrange(0,self.font.width):
                screen_pos=screen_base2+fx
                pixel=self.font.graphic[char_pos]
                if pixel==1:
                    self.viewport.data[screen_pos]=element[0]
                else:
                    if element[1]!=self.theme.transparent:
                        self.viewport.data[screen_pos]=element[1]
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
            temp.image.copy_9slice(self.viewport,temp.outer,temp.inner,temp.dst,,temp.transparent,temp.copy_mode)
        if  temp.mode=="3slice":
            temp.image.copy_3slice(self.viewport,temp.outer,temp.inner,temp.dst,temp.transparent,temp.copy_mode)
        elif temp.mode=="copy":
            temp.image.copy(self.viewport,temp.bounds,temp.dst ,temp.transparent)


    cdef render(self):
        cdef int zindex=-10
        #if self.state.default_background==self.theme.transparent:
         #   self.viewport.clear(0);
        ##lse:
        cdef uint8_t[3] clear_pixel=[0,0,0]
        cdef uint8_t[3] element=[0,0,0]
        self.viewport.clear(clear_pixel)
        self.copy(self.theme.layer1)
        self.copy(self.theme.layer2)
        
        
        cdef uint16_t x  =0
        cdef uint16_t y  =0
        try:
            for y in xrange(0,self.screen.dimentions.height):
                for x in xrange(0,self.screen.dimentions.width):
                    
                    self.screen.get_pixel_3byte(x,y,element)
                    self.draw_character(x,y,element)
        except Exception as ex:
            print ex

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
    