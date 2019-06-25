

cdef class terminal_graphics:
    cdef array.array data
    cdef image viewport
    cdef image character_buffer
    cdef display_state character_buffer_state

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
            
        self.character_buffer_state=display_state(char_width,char_height)
        self.character_buffer= image(width= char_width ,height= char_height ,init_value=0                    ,bytes_per_pixel=3)
        self.rendered_screen = image(width= px_width   ,height= px_height   ,init_value=self.state.background,bytes_per_pixel=1)


        # set default screen state

    # write a character to the text buffer with the curent text attributes
    cdef write(self,int character):
        cdef int x=self.character_buffer_state.cursor_x
        cdef int y=self.character_buffer_state.cursor_y

        if character>255:
            err_msg="Charactrer out of range -{0}".format(character)
            raise Exception(err_msg)

        if self.character_buffer_state.reverse_video:
            self.character_buffer.put_pixel(x,y,[self.character_buffer_state.background,
                                            self.character_buffer_state.foreground,
                                            character])
        else:
            self.character_buffer.put_pixel(x,y,[self.character_buffer_state.foreground,
                                            self.character_buffer_state.background,
                                            character])

    def draw_string(self,x,y,data):
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

    def get_text(self):
        text=""
        for y in range(0,self.character_buffer.dimentions.height):
            for x in range(0,self.character_buffer.dimentions.width):
                pixel=self.character_buffer.get_pixel(x,y)
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



    #def render_underlay(self,underlay,frame):
    #    self.underlay_flag=True
    #    
    #    for frame in underlay['frames']:
    #        if frame['image'] and frame['descriptor']:
    #            descriptor=frame['descriptor']
    #            src_image =frame['image'].data
    #            #print ("got stuff")
    #            break
#
    #    if None==descriptor or None == src_image:
    #        self.underlay_flag=None
    #        #print("BOM")
    #        return
#
    #    dst_x1=0
    #    dst_y1=0
    #    dst_x2=self.viewport_px_width-1
    #    dst_y2=self.viewport_px_height-1
    #    dst_width=self.viewport_px_width
    #    dst_height=self.viewport_px_height
    #    #print ("copy stuff")
    #    memset(self.video.data.as_voidptr, self.background_color, self.video_length * sizeof(char))
#
#
    #    self.remap(underlay['global_color_table'].colors,src_image,self.color_table)
#
    #    self.copy_image( src_image  = src_image,
    #                src_x1      = 0,
    #                src_y1      = 0,
    #                src_x2      = descriptor.Width-1,
    #                src_y2      = descriptor.Height-1,
    #                src_width  = descriptor.Width,
    #                src_height = descriptor.Height,
    #                dst_image  = self.video,
    #                dst_x1      = dst_x1,
    #                dst_y1      = dst_y1,
    #                dst_x2      = dst_x2,
    #                dst_y2      = dst_y2,
    #                dst_width  = dst_width,
    #                dst_height = dst_height)
#
    def foreground_from_rgb(self,r,g,b):
        cdef int color=match_color_index(r,g,b,self.viewport.palette)
        self.set_foreground(color)

    def background_from_rgb(self,r,g,b):
        cdef int color=match_color_index(r,g,b,self.viewport.palette)
        self.set_background(color)

    def set_foreground(self,color):
        self.state.foreground=color
    
    def set_background(self,color):
        self.state.background=color
    
    def render(self):
        #if None==self.underlay_flag:
        self.viewport.clear(self.state.background);
        cdef int fg =0
        cdef int bg =0
        cdef int x  =0
        cdef int y  =0
        cdef int character=0

        for y in range(0,self.character_buffer.dimentions.height):
            for x in range(0,self.character_buffer.dimentions.width):
                pixel=self.character_buffer.get_pixel(x,y)
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
    