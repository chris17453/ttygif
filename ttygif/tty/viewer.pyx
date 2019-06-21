# cython: linetrace=True

from cpython cimport array
import array
import re
from libc.string cimport memset


from .font cimport font_map
from .fonts cimport font
#import font

# Reference
# http://man7.org/linux/man-pages/man4/console_codes.4.html


cdef class viewer:
    cdef public object          last_timestamp
    cdef public int             viewport_px_width
    cdef public int             viewport_px_height
    cdef public int             viewport_char_height
    cdef public int             viewport_char_width
    cdef public int             viewport_char_stride
    cdef public int             background_color
    cdef public int             foreground_color
    cdef public object          window_style
    cdef public object          stream
    cdef public int             video_length
    cdef        array.array     video
    cdef        object          color_table
    cdef        array.array     buffer
    cdef public int             buffer_rows
    cdef        object          debug_mode
    cdef public object          sequence
    cdef public object          sequence_pos

    cdef public int             x
    cdef public int             y
    cdef public int             def_fg
    cdef public int             def_bg
    cdef public int             fg
    cdef public int             bg
    cdef public object          reverse_video
    cdef public object          bold
    cdef public object          extra_text
    
    cdef ascii_safe(self,text):
        return ''.join([i if ord(i) < 128 else '*' for i in text])

    cdef info(self,text):
        if self.debug_mode:
            print(self.ascii_safe(text))
    
    cdef new_char_buffer(self):
        cdef array.array buffer=array.array('B')
        array.resize(buffer,self.viewport_char_stride*self.viewport_char_height)
        memset(buffer.data.as_voidptr, self.background_color, len(buffer) * sizeof(char))

        return buffer

    cdef new_video_buffer(self):
        cdef array.array buffer=array.array('B')
        array.resize(buffer,self.viewport_px_width*self.viewport_px_height)
        return buffer
        
    def __init__(self,width=640,height=480,char_width=None,char_height=None,debug=None):
        self.debug_mode                =debug
        self.viewport_px_width    =width
        self.viewport_px_height   =height

        if char_width and char_height:
            self.viewport_char_width  = char_width
            self.viewport_char_height = char_height
            self.viewport_px_width    = self.viewport_char_width*font.font_width
            self.viewport_px_height   = self.viewport_char_height*font.font_height
        else:
            self.viewport_char_height = self.viewport_px_height/font.font_width
            self.viewport_char_width  = self.viewport_px_width/font.font_height
            self.viewport_px_width    = width
            self.viewport_px_height   = height
        #fg,bg,char
        self.viewport_char_stride     =self.viewport_char_width*3  
        self.clear_sequence()
        self.video                =self.new_video_buffer()
        self.buffer               =self.new_char_buffer()
        #self.buffer_length        =self.viewport_char_width*self.viewport_char_height

        self.sequence_pos         =0
        self.video_length         =len(self.video)
        self.background_color     =0
        self.foreground_color     =3
        self.window_style         ="BOTTOM"
        self.extra_text           =""
        self.last_timestamp       =0
        self.x=0
        self.y=0
        self.def_fg=15
        self.def_bg=0
        self.fg=self.def_fg
        self.bg=self.def_bg
        self.reverse_video=None
        self.bold=None


        self.color_table=[  # 16 System Colors
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
        ]

    def draw_string(self,x,y,data):
        for i in data:
            self.draw_character3(ord(i),x,y,0,0,15)
            x+=1

    cdef draw_character3(self,int character,int x,int y,int offset,int foreground_color,int background_color):
        cdef int fs            = font.width
        cdef int fw            = font.font_width
        cdef int fh            = font.font_height
        cdef int fox           = font.offset_x
        cdef int foy           = font.offset_y
        cdef int fsx           = font.spacing_x
        cdef int fsy           = font.spacing_y
        cdef int transparent   = font.transparent
        cdef int cx            = int(character%font.chars_per_line)
        cdef int cy            = int(character/font.chars_per_line)
        cdef int pre_x         = fox+cx*fw
        cdef int pre_y         = foy+cy*fh*fs
        cdef int pre           = pre_x+pre_y
        cdef int sy            = fh+fsy
        cdef int sx            = fw+fsx
        cdef int screen_pos    = sx*x+sy*y*self.viewport_px_width
        cdef int char_pos      = pre
        cdef int fx            = 0
        cdef int fy            = 0
        cdef int new_line_stride      =self.viewport_px_width-(fw+fsx)
        cdef int new_char_line_stride =fs-(fw+fsx)
        
        loop=True
        
        while loop:
            pixel=font.graphic[char_pos]
            if pixel!=transparent:
                self.video[screen_pos]=foreground_color
            else:
                self.video[screen_pos]=background_color
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

            

    cdef get_buffer_height(self):
        #print self.buffer_rows,"ROWS"
        height=self.buffer_rows*font.font_height
        return height

    # todo save as gif..
    # pre test with canvas extension    
    def render(self):
        self.sequence_to_buffer()
        memset(self.video.data.as_voidptr, self.background_color, self.video_length * sizeof(char))
        
        loop=True
        cdef int pos=0
        cdef int buffer_len=len(self.buffer)
        cdef int fg=0
        cdef int bg=0
        cdef int x=0
        cdef int y=0
        cdef int character=0

        while loop:
            fg=self.buffer[pos]
            bg=self.buffer[pos+1]
            character=self.buffer[pos+2]
            self.draw_character3(character,x,y,0,fg,bg)
            x+=1
            if x>=self.viewport_char_width:
                x=0
                y+=1
            pos+=3
            if pos>=buffer_len:
                loop=None
  
    # convert the text stream to a text formated grid
    cdef debug(self): 
        print("VIEWPORT:")
        print("  px height:          {0}".format(self.viewport_px_height))
        print("  px width:           {0}".format(self.viewport_px_width))
        print("  video buffer size:  {0}".format(len(self.video)))

        print("Buffer:")
        print("  char height:        {0}".format(self.viewport_char_height))
        print("  char width:         {0}".format(self.viewport_char_width))
        print("  char stride:        {0}".format(self.viewport_char_stride))
        print("  char buffer size:   {0}".format(len(self.buffer)))
        print("  buffer char height: {0}".format(self.buffer_rows))

    
        
    cdef shift_buffer(self,array.array buffer):
        cdef int buffer_length=len(buffer)
        cdef int index=self.viewport_char_width
        for i in range(0,index):
            buffer.pop(0)
            buffer.pop(0)
            buffer.pop(0)
        cdef int row_pos=buffer_length-self.viewport_char_stride
        array.resize(buffer,buffer_length)  
        memset(&buffer.data.as_uchars[row_pos],0,self.viewport_char_stride)


    def get_text(self):
        loop=True
        cdef int pos=0
        x=0
        y=0
        text=""        
        buffer_length=len(self.buffer)
        while loop:
            character=self.buffer[pos+2]
            text+=unichr(character)
            x+=1
            if x>=self.viewport_char_width:
                text+="\n"
                x=0
                y+=1
            pos+=3
            if pos>=buffer_length:
                loop=None
        text+="\n"
        return text

    #4045017243 2




    cdef write_buffer(self,int x,int y,int c,array.array buffer):
        if c>255:
            err_msg="Charactrer out of range -{0}".format(c)
            raise Exception(err_msg)
        cdef int pos=x*3+y*self.viewport_char_stride
        try:
            #print x,y,pos,len(buffer),c
            
            if self.reverse_video:
                buffer[pos]=self.bg
                buffer[pos+1]=self.fg
                buffer[pos+2]=c
            else:
                buffer[pos]=self.fg
                buffer[pos+1]=self.bg
                buffer[pos+2]=c
        except Exception as ex:
            err_msg="Msg:{0} X:{1},Y:{2},C:{3},FG:{4},BG:{5},Buffer Len:{6}".format(ex,x,y,c,self.fg,self.bg,len(buffer))
            
            raise Exception (err_msg)

    def set_mode(self,cmd):
        dm=self.debug_mode
        self.debug_mode=None
        if cmd==0:
            self.fg=self.def_fg
            self.bg=self.def_bg
            self.bold=None
            self.reverse_video=None
            if self.debug_mode:
                self.info("RESET All")
        elif cmd==1:
            self.bold=True
            if self.debug_mode:
                self.info("Set BOLD")
        elif cmd==7:
            if self.debug_mode:
                self.info("Reverse Video On")
            self.reverse_video=True
        elif cmd==27:
            if self.debug_mode:
                self.info("Reverse Video Off")
            self.reverse_video=None
        elif cmd>=30 and cmd<=37:
            self.fg=cmd-30
            if self.bold:
                self.fg+=8
            if self.debug_mode:
                self.info("Set FG")
        elif cmd==39:
            self.fg=self.def_fg
            if self.debug_mode:
                self.info("Set Default FG")
        elif cmd>=40 and cmd<=47:
            self.bg=cmd-40
            if self.bold:
                self.fg+=8
            if self.debug_mode:
                self.info("Set BG")
        elif cmd==49:
            self.bg=self.def_bg
            if self.debug_mode:
                self.info("Set Default BG")
        elif cmd>=90 and cmd<=97:
            self.fg=cmd-90+8
            if self.debug_mode:
                self.info("Set High INTENSITY FG")
        elif cmd>=100 and cmd<=107:
            self.bg=cmd-100+8
            if self.debug_mode:
                self.info("Set High INTENSITY BG")
        self.debug_mode=dm

    def reset_mode(self,cmd):
        if cmd==0:
            self.fg=self.def_fg
            self.bg=self.def_bg
            self.bold=None
            self.reverse_video=None
            if self.debug_mode:
                self.info("RESET All")
        elif cmd==1:
            self.bold=None
            if self.debug_mode:
                self.info("Set BOLD")
        elif cmd==7:
            self.reverse_video=None



    # commands pre parsed on add_event
    cdef sequence_to_buffer(self):
        
        cdef int pos=0
        cdef int cursor = 0
        # pre buffer
        buffer=self.buffer
        overflow=None

        
        x=self.x
        y=self.y
        

        cursor=0
        new_sequence_pos=self.sequence_pos
        for event in self.sequence[self.sequence_pos:]:
            new_sequence_pos+=1
            if event['type']=='text':
                #if self.debug_mode:
                #    self.info(u"X:{0:<2} {1:<2},FG:{2:<2},BG:{3},Text: {3}".format(x,y,self.fg,self.bg,event['data']))
                for character in event['data']:
                    # new line or wrap
                    char_ord=ord(character)
                    # handle non printable codes here
                    #prinset char_ord
                    if char_ord<32:
                        if char_ord==0x08:
                            x-=1
                            if x<0: 
                                x=0
                        if char_ord==0x0A:
                            x=0
                            y+=1
                            if y>=self.viewport_char_height:
                                y=self.viewport_char_height-1
                                self.shift_buffer(buffer)
                        continue
                    if x>=self.viewport_char_width:
                        x=0
                        y+=1
                        if y>=self.viewport_char_height:
                            y=self.viewport_char_height-1
                            self.shift_buffer(buffer)
                    self.write_buffer(x,y,char_ord,buffer)
                    x+=1
                continue


            #print cursor,start, end
            params   =event['params']
            command  =event['command']
            esc_type =event['esc_type']
            groups   =event['groups']

            if esc_type=='OSC':
                continue
            elif esc_type=='SINGLE':
                command=groups[1]
            elif esc_type=='CHAR_SET':
                command=groups[3]
            elif esc_type=='G0':
                command=groups[5]
            elif esc_type=='G1':
                command=groups[7]
            elif esc_type=='CSI':
                if command=='m':
                    if 38 in params:
                        if params[1]==2:
                            self.fg=params[2] # rgb
                        if params[1]==5:
                            self.fg=params[2]
                        #if self.debug_mode:
                            #self.info("Set FG:{0}".format(params))
                    elif 48 in params:
                            if params[1]==2:
                                self.bg=params[2] #rgb
                            if params[1]==5:
                                self.bg=params[2]
                            #if self.debug_mode:
                                #self.info("Set BG:{0}".format(params))
                    else:
                        for cmd in params:
                           self.set_mode(cmd)
                else:
                    if command=='A': # move cursor up
                        if self.debug_mode:
                            self.info("Cursor Up:{0},x:{1:<2},y:{2:<2}".format(params[0],x,y))
                        y-=params[0]
                    elif command=='B': # move cursor down
                        if self.debug_mode:
                            self.info("Cursor Down:{0},x:{1:<2},y:{2:<2}".format(params[0],x,y))
                        y+=params[0]
                    elif command=='C': # move cursor foreward
                        if self.debug_mode:
                            self.info("Cursor Right:{0},x:{1:<2},y:{2:<2}".format(params[0],x,y))
                        x+=params[0]
                    elif command=='D': # move cursor back
                        if self.debug_mode:
                            self.info("Cursor Left:{0},x:{1:<2},y:{2:<2}".format(params[0],x,y))
                        x-=params[0]
                    elif command=='E': # move cursor next line
                        if self.debug_mode:
                            self.info("Cursor Next Line:{0},x:{1:<2},y:{2:<2}".format(params[0],x,y))
                        x=0
                        y+=params[0]

                    elif command=='F': # move cursor previous  line
                        if self.debug_mode:
                            self.info("Cursor Previous Line:{0},x:{1:<2},y:{2:<2}".format(params[0],x,y))
                        x=0
                        y-=params[0]
                    elif command=='G' or command=='`': # move cursor to HORIZONTAL pos X
                        if self.debug_mode:
                            self.info("Cursor X:{0},x:{1:<2},y:{2:<2}".format(params[0],x,y))
                        x=params[0]-1
                    elif command=='H' or command=='f': # move cursor to x,y pos
                        if self.debug_mode:
                            self.info("Cursor Pos:{0},{1}".format(params[1],params[0]))
                        x=params[1]-1
                        y=params[0]-1

                    elif command=='J': # erase display
                        if params[0]==0:
                            if self.debug_mode:
                                self.info("Erase Display cursor to end")
                            pos=x+y*self.viewport_char_width
                            for x in range(pos,self.viewport_char_height*self.viewport_char_width):
                                buffer[x*3+0]=self.fg
                                buffer[x*3+1]=self.bg
                                buffer[x*3+2]=32
                        if params[0]==1:
                            if self.debug_mode:
                                self.info("Erase Display top til cursor")
                            pos=x+y*self.viewport_char_width
                            for x in range(0,pos+1):
                                buffer[x*3+0]=self.fg
                                buffer[x*3+1]=self.bg
                                buffer[x*3+2]=32

                        if params[0]==2:
                            if self.debug_mode:
                                self.info("Erase Display and buffer")
                            buffer=self.new_char_buffer()

                    elif command=='K': # erase line
                        if self.debug_mode:
                            self.info("Erase Line: {0}".format(params[0]))
                        if params[0]==0:
                            for x2 in range(x,self.viewport_char_width):
                                self.write_buffer(x2,y,32,buffer)
                        elif params[0]==1:
                            for x2 in range(0,x+1):
                                self.write_buffer(x2,y,32,buffer)
                        elif params[0]==2:
                            for x2 in range(0,self.viewport_char_width):
                                self.write_buffer(x2,y,32,buffer)
                    elif command=='d': # move cursor to Vertivcal pos y
                        if self.debug_mode:
                            self.info("Cursor (d) Y{0},x:{1:<2},y:{2:<2}".format(params[0],x,y))
                        y=y-params[0]-1
                        
                    #elif command=='e': 
                    #    if self.debug_mode:
                    #        self.info("Cursor Down rows:{0},x:{1:<2},y:{2:<2}".format(params[0],x,y))
                    #    y+=params[0]
                    elif command=='h': 
                        if self.debug_mode:
                            self.info("Set mode:{0},x:{1:<2},y:{2:<2}".format(params[0],x,y))
                            self.set_mode(params)
                    elif command=='l': 
                        if self.debug_mode:
                            self.info("Set mode:{0},x:{1:<2},y:{2:<2}".format(params[0],x,y))
                            self.reset_mode(params)
                    elif command=='X': 
                        if self.debug_mode:
                            self.info("Erase number of charchters on line:{0},x:{1:<2},y:{2:<2}".format(params[0],x,y))
                        char_to_erase=params[0]
                        stride=self.viewport_char_width-x
                        temp=[0,0,0]*stride
                        for x2 in range(x,stride-char_to_erase):
                            t=(x2-x)*3
                            b=(char_to_erase+x2)*3  +y*self.viewport_char_stride
                            temp[t+0]=buffer[b+0]
                            temp[t+1]=buffer[b+1]
                            temp[t+2]=buffer[b+2]

                        for x2 in range(x,stride):
                            t=(x2-x)*3
                            b=x2*3+y*self.viewport_char_stride
                            buffer[b+0]=temp[t+0]
                            buffer[b+1]=temp[t+1]
                            buffer[b+2]=temp[t+2]
                                

                    elif command=='P': 
                        if self.debug_mode:
                            self.info("Delete number of charchters on line:{0},x:{1:<2},y:{2:<2}".format(params[0],x,y))
                        for x2 in range(x,x+params[0]):
                            self.write_buffer(x2,y,0,buffer)
                        
                    else:
                        if self.debug_mode:
                            self.info("Impliment: pos x:{2},Y:{3} - {0}-{1}".format(command,params,x,y))
            
        
        

        self.buffer_rows=self.viewport_char_height
        self.buffer=buffer
        self.sequence_pos=new_sequence_pos

        self.x=x
        self.y=y
   
    
    cdef stream_2_sequence(self,text,timestamp,delay):
         
        # patterns for filtering out commands from the stream
        ANSI_SINGLE   ='[\001b|\033]([cDEHMZ78>=])'
        ANSI_CHAR_SET = '[\001b|\033]\\%([@G*])'
        ANSI_G0       = '[\001b|\033]\\(([B0UK])'
        ANSI_G1       = '[\001b|\033]\\)([B0UK])'
        ANSI_CSI_RE   = '[\001b|\033]\\[((?:\\d|;|<|>|=|\?)*)([a-zA-Z])\002?'
        # guessed on this one
        #ANSI_OSC_777_REGEX='[\0x1b|\033]\]777[;]([._:A-Za-z0-9\-\s]*)[;]([._:A-Za-z0-9\-\s]*)[;]([._:A-Za-z0-9\-\s]*)'
        ANSI_OSC ='(?:\001?\\]|\x9d).*?(?:\001?\\\\|[\a\x9c])'


        ESC_SEQUENCES=[ANSI_SINGLE,ANSI_CHAR_SET,ANSI_G0,ANSI_G1,ANSI_CSI_RE,ANSI_OSC]
        
        ANSI_REGEX="("+")|(".join(ESC_SEQUENCES)+")"
        
        
        ANSI=re.compile(ANSI_REGEX)
        cursor=0
        for match in ANSI.finditer(text):
            name=""
            start, end = match.span()
            self.add_text_sequence(text[cursor:start],timestamp,delay)
            cursor = end
            command=None
            params=None
            esc_type=None
            groups=match.groups()
            if groups[0]:
                esc_type='SINGLE'
                command=groups[1]
            elif groups[2]:
                esc_type='CHAR_SET'
                command=groups[3]
            elif groups[4]:
                esc_type='G0'
                command=groups[5]
            elif groups[6]:
                esc_type='G1'
                command=groups[7]
            elif groups[11]:
                esc_type='OSC'
                command=groups[11]
                params=[groups[11]]
            
            elif groups[8]:
                esc_type='CSI'
                paramstring=groups[9]
                command=groups[10]
                if command in 'Hf':
                    params = tuple(int(p) if len(p) != 0 else 1 for p in paramstring.split(';'))
                    while len(params) < 2:
                        params = params + (1,)
                #        DEC Private Mode (DECSET/DECRST) sequences
                elif paramstring and len(paramstring)>0 and paramstring[0]=='?':
                    params=['?',paramstring[1:-1],paramstring[-1]]
                else:
                    
                    params = tuple(int(p) for p in paramstring.split(';') if len(p) != 0)
                    if len(params) == 0:
                        if command in 'JKm':
                            params = (0,)
                        elif command in 'ABCD':
                            params = (1,)
                
                if command=='m':
                    if 38 in params:
                        name="Set FG"
                    elif 48 in params:
                        name="Set BG"
                    else:
                        for cmd in params:
                            if cmd==0:
                                name="RESET All"
                                reverse_video=None
                            elif cmd==1:
                                name="Set BOLD"
                            elif cmd==7:
                                name="Reverse Video On"
                            elif cmd==27:
                                name="Reverse Video Off"
                            elif cmd>=30 and cmd<=37:
                                name="Set FG"
                            elif cmd==39:
                                name="Set Default FG"
                            elif cmd>=40 and cmd<=47:
                                name="Set BG"
                            elif cmd==49:
                                name="Set Default BG"
                            elif cmd>=90 and cmd<=97:
                                name="Set High INTENSITY FG"
                            elif cmd>=100 and cmd<=107:
                                name="Set High INTENSITY BG"
                            #self.add_command_sequence(esc_type,command,cmd,groups,name,timestamp)
                        #continue

                else:
                    if command=='A': # move cursor up
                        name="Cursor Up"
                    elif command=='B': # move cursor down
                        name="Cursor Down"
                    elif command=='C': # move cursor back
                        name="Cursor Right"
                    elif command=='D': # move cursor right
                        name="Cursor Left"
                    elif command=='E': # move cursor next line
                        name="Cursor Next Line"
                    elif command=='F': # move cursor previous  line
                        name="Cursor Previous Line"
                    elif command=='G': # move cursor to HORIZONTAL pos X
                        name="Cursor X"
                    elif command=='H' or command=='f': # move cursor to x,y pos
                        name="Cursor Pos"
                    elif command=='J': # erase display
                        name="Erase Display"
                    elif command=='K': # erase line
                        name="Erase Line"
                self.add_command_sequence(esc_type,command,params,groups,name,timestamp,delay)
        
        if self.has_escape(text[cursor:]):
            #print ("EXTRA")
            #print text[cursor:]
            self.extra_text=text[cursor:]
        else:
            #print ("NO EXTRA")
            #print text[cursor:]
            self.extra_text=""
            #print("->",text[cursor:])
            self.add_text_sequence(text[cursor:],timestamp,0)
    
    def last_frame(self):
        self.add_text_sequence(self.extra_text,self.last_timestamp,0)
        self.extra_text=""
    
    def has_escape(self,text):
        for i in text:
            if ord(i)==0x1B:
                return True
        return None

    def clear_sequence(self):
        self.sequence=[]

    cdef remap_character(self,character):
      #print character
        #print character
        cdef int c=ord(character)
        cdef int replacment_char=ord('*')
        if c>255:
            if c==8216:
                c=39
            elif c==8217:
                c=39
            elif c==9472:
                c=196
            elif c==9474:
                c=179
            elif c==9484:
                c=218
            elif c==9488:
                c=191
            elif c==9492:
                c=192
            elif c==9496:
                c=217
            elif c==9600:
                c=223
            elif c==9604:
                c=220
            elif c==9608:
                c=219
            elif c==9612:
                c=221
            elif c==9616:
                c=222
            elif c==9617:
                c=176
            elif c==9618:
                c=177
            elif c==10140:
                c=26
            else:
                print ("Missing character: {0}".format(c))
                return unichr(replacment_char)
        else:
            return character
        return unichr(c)

    def add_text_sequence(self,text,timestamp,delay):
        if len(text)==0:
            return
        #print "1",text
        #remapped=[u' ']*len(text)
        #for i in range(0,len(text)):
        #    c=text[i]
        #    r=chr(self.remap_character(c))
        #    remapped[i]=r
        #text="".join(remapped)
        text=[self.remap_character(i) for i in text]
        #if self.debug_mode:
        #    self.info ("Text: '{0}' Length:{1} Timestamp:{2}".format(self.ascii_safe(text),len(text),timestamp))
        self.sequence.append({'type':'text','data':text,'timestamp':timestamp,'delay':delay})

    def add_command_sequence(self,esc_type,command,params,groups,name,timestamp,delay):
        #if self.debug_mode:
        #    self.info("CMD:  '{0}', Name:'{3}', Command:{1}, Params:{2}  Timestamp:{4}".format(
        #                                        esc_type,
        #                                        command,
        #                                        params,
        #                                        name,
        #                                        timestamp))
        self.sequence.append({'type':'command','esc_type':esc_type,'command':command,'params':params,'groups':groups,'name':name,'timestamp':timestamp,'delay':delay})

    def debug_sequence(self):
        print ("============")
        print ("Sequence List")
        print ("Count:{0}".format(len(self.sequence)))
        for item in self.sequence:
            if item['type']=='text':
                print("Text: '{0}' Length:{1} Timestamp:{2}".format(self.ascii_safe(item['data']),len(item['data']),item['timestamp']))
            else:
                print("CMD:  '{0}', Name:'{3}', Command:{1}, Params:{2}  Timestamp:{4}".format(item['esc_type'],
                                                    item['command'],
                                                    item['params'],
                                                    item['name'],
                                                    item['timestamp']))
   

    def get(self):
        return {'width':self.viewport_px_width,'height':self.viewport_px_height,'data':array.copy(self.video),'color_table':self.color_table}

    def add_event(self,event):
        timestamp=round(float(event[0]),3)
        event_type=event[1]
        event_io=event[2]
        if self.last_timestamp==0:
            delay=0
        else:
            length=len(self.sequence)-1
            if length>0:
                self.sequence[length]['delay']=timestamp-self.last_timestamp
            else:
                delay=0
        if event_type=='o':
            self.stream_2_sequence(self.extra_text+event_io,timestamp,0)
            self.last_timestamp=timestamp
        
    cdef save_screen(self):
        # todo save as gif..
        # pre test with canvas extension
        x=1
