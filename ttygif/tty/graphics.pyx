from .display_state cimport display_state
from .image cimport image

from cpython cimport array
from libc.string cimport memset
from .font cimport font


cdef create_default_palette():
    cdef array.array palette=array.array('B',[  # 16 System Colors
        [0,0,0],[128,0,0],[0,128,0],[128,128,0],
        [0,0,128],[128,0,128],[0,128,128],[192,192,192],
        [128,128,128],[255,0,0],[0,255,0],[255,255,0],
        [0,0,255],[255,0,255],[0,255,255],[255,255,255],
        # xterm palette
        [0,0,0],[0,0,95],[0,0,135],[0,0,175],[0,0,215],[0,0,255],
        [0,95,0],[0,95,95],[0,95,135],[0,95,175],[0,95,215],[0,95,255],
        [0,135,0],[0,135,95],[0,135,135],[0,135,175],[0,135,215],[0,135,255],
        [0,175,0],[0,175,95],[0,175,135],[0,175,175],[0,175,215],[0,175,255],
        [0,215,0],[0,215,95],[0,215,135],[0,215,175],[0,215,215],[0,215,255],
        [0,255,0],[0,255,95],[0,255,135],[0,255,175],[0,255,215],[0,255,255],
        [95,0,0],[95,0,95],[95,0,135],[95,0,175],[95,0,215],[95,0,255],
        [95,95,0],[95,95,95],[95,95,135],[95,95,175],[95,95,215],[95,95,255],
        [95,135,0],[95,135,95],[95,135,135],[95,135,175],[95,135,215],[95,135,255],
        [95,175,0],[95,175,95],[95,175,135],[95,175,175],[95,175,215],[95,175,255],
        [95,215,0],[95,215,95],[95,215,135],[95,215,175],[95,215,215],[95,215,255],
        [95,255,0],[95,255,95],[95,255,135],[95,255,175],[95,255,215],[95,255,255],
        [135,0,0],[135,0,95],[135,0,135],[135,0,175],[135,0,215],[135,0,255],
        [135,95,0],[135,95,95],[135,95,135],[135,95,175],[135,95,215],[135,95,255],
        [135,135,0],[135,135,95],[135,135,135],[135,135,175],[135,135,215],[135,135,255],
        [135,175,0],[135,175,95],[135,175,135],[135,175,175],[135,175,215],[135,175,255],
        [135,215,0],[135,215,95],[135,215,135],[135,215,175],[135,215,215],[135,215,255],
        [135,255,0],[135,255,95],[135,255,135],[135,255,175],[135,255,215],[135,255,255],
        [175,0,0],[175,0,95],[175,0,135],[175,0,175],[175,0,215],[175,0,255],
        [175,95,0],[175,95,95],[175,95,135],[175,95,175],[175,95,215],[175,95,255],
        [175,135,0],[175,135,95],[175,135,135],[175,135,175],[175,135,215],[175,135,255],
        [175,175,0],[175,175,95],[175,175,135],[175,175,175],[175,175,215],[175,175,255],
        [175,215,0],[175,215,95],[175,215,135],[175,215,175],[175,215,215],[175,215,255],
        [175,255,0],[175,255,95],[175,255,135],[175,255,175],[175,255,215],[175,255,255],
        [215,0,0],[215,0,95],[215,0,135],[215,0,175],[215,0,215],[215,0,255],
        [215,95,0],[215,95,95],[215,95,135],[215,95,175],[215,95,215],[215,95,255],
        [215,135,0],[215,135,95],[215,135,135],[215,135,175],[215,135,215],[215,135,255],
        [215,175,0],[215,175,95],[215,175,135],[215,175,175],[215,175,215],[215,175,255],
        [215,215,0],[215,215,95],[215,215,135],[215,215,175],[215,215,215],[215,215,255],
        [215,255,0],[215,255,95],[215,255,135],[215,255,175],[215,255,215],[215,255,255],
        [255,0,0],[255,0,95],[255,0,135],[255,0,175],[255,0,215],[255,0,255],
        [255,95,0],[255,95,95],[255,95,135],[255,95,175],[255,95,215],[255,95,255],
        [255,135,0],[255,135,95],[255,135,135],[255,135,175],[255,135,215],[255,135,255],
        [255,175,0],[255,175,95],[255,175,135],[255,175,175],[255,175,215],[255,175,255],
        [255,215,0],[255,215,95],[255,215,135],[255,215,175],[255,215,215],[255,215,255],
        [255,255,0],[255,255,95],[255,255,135],[255,255,175],[255,255,215],[255,255,255],
        [8,8,8],[18,18,18],[28,28,28],[38,38,38],[48,48,48],[58,58,58],[68,68,68],
        [78,78,78],[88,88,88],[98,98,98],[108,108,108],[118,118,118],[128,128,128],
        [138,138,138],[148,148,148],[158,158,158],[168,168,168],[178,178,178],[188,188,188],
        [198,198,198],[208,208,208],[218,218,218],[228,228,228],[238,238,238]
        ])
    return palette


# returns a byte array set with an initial value
cdef create_array(int size,int init_value):
    data=array.array('B')
    array.resize(data,size)
    memset(data.data.as_voidptr, init_value, len(data) * sizeof(char))

    # super fast memory copy
cdef copy_image(image src_image,src_x1,src_y1,src_x2,src_y2,
                image dst_image,dst_x1,dst_y1,dst_x2,dst_y2,mode='simple'):
    cdef int x3
    cdef int y3

    if mode=='simple':
        
        for y in range(src_y1,src_y2):
            for x in range(src_x1,src_x2):
                pixel=src_image.get_pixel(x,y)
                #print x,y,pixel
                x3=x+dst_x1-src_x1
                y3=y+dst_y1-src_y1
                dst_image.put_pixel(x3,y3,pixel)


# shifts an image buffer up 1 line and fills the newly created space with x value
cdef shift_buffer(image src_image,int init_value=0):
    cdef int buffer_length=src_image.dimentions.length
    cdef int index=src_image.dimentions.width
    
    for i in range(0,index):
        buffer.pop(0)
        buffer.pop(0)
        buffer.pop(0)
    cdef int row_pos=buffer_length-src_image.dimentions.stride
    array.resize(buffer,buffer_length)  
    memset(&buffer.data.as_uchars[row_pos],init_value,src_image.dimentions.length)

def match_color_index(r,g,b,color_table):
    last_distance=-1
    mappeded_color=-1

    color_table_len=len(color_table)
    for i in range(0,color_table_len):
        color=color_table[i]
        color_distance=(r-color[0])*(r-color[0])+(g-color[1])*(g-color[1])+(b-color[2])*(b-color[2])
        if last_distance==-1 or color_distance<last_distance:
            last_distance=color_distance
            mappeded_color=i

    return mappeded_color


# todo account for color table size mismatch, crud on new table, and reindexing for best color palette...
def remap(src_color_table,src_pixels,dst_color_table):
    hash_map=[0]*len(src_color_table)
    # remap the colors from the source to the dest
    for i in range(0,len(src_color_table)):
        src_color=src_color_table[i]
        new_index=self.match_color_index(src_color[0],src_color[1],src_color[2],dst_color_table)
        hash_map[i]=new_index

    # reindex the pixels
    src_pixel_len=len(src_pixels)
    for i in range(0,src_pixel_len):
        original_index=src_pixels[i]
        #replace srrc data pixel...
        src_pixels[i]=hash_map[original_index]



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
            px_width    =width
            px_height   =height

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
            character_buffer.put_pixel(x,y,[self.character_buffer_state.background,
                                            self.character_buffer_state.foreground,
                                            character])
        else:
            character_buffer.put_pixel(x,y,[self.character_buffer_state.foreground,
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
        frame.state.foreground=color
    
    def set_background(self,color):
        frame.state.background=color
    
    def render(self):
        #if None==self.underlay_flag:
        self.viewport.clear();
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
    