# cython: linetrace=True

from cpython cimport array
import array
import re

from .font cimport font_map
from .fonts cimport font
#import font

# Reference
# http://man7.org/linux/man-pages/man4/console_codes.4.html


cdef class viewer:
    cdef public int         viewport_px_width
    cdef public int         viewport_px_height
    cdef public int         viewport_char_height
    cdef public int         viewport_char_width
    cdef public int         background_color
    cdef public int         foreground_color
    cdef public object      window_style
    cdef public object      stream
    cdef public int         video_length
    cdef        object      video
    cdef        object      color_table
    cdef        object      buffer
    cdef public int         buffer_rows
    cdef        object      debug_mode
    cdef public object      sequence
    cdef public object      sequence_pos

    cdef public object      x
    cdef public object      y
    cdef public object      def_fg
    cdef public object      def_bg
    cdef public object      fg
    cdef public object      bg
    cdef public object      reverse_video
    cdef public object      bold
    cdef public object      extra_text
    
    cdef ascii_safe(self,text):
        return ''.join([i if ord(i) < 128 else '*' for i in text])

    cdef info(self,text):
        if self.debug_mode:
            print(self.ascii_safe(text))

    def __init__(self,width=640,height=480,char_width=None,char_height=None,stream='',debug=None):
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

        self.clear_sequence()
        self.video                =[0]*self.viewport_px_width*self.viewport_px_height
        self.buffer               =[[0,0],0]*self.viewport_char_width*self.viewport_char_height
        self.sequence_pos         =0
        self.video_length         =len(self.video)
        self.background_color     =0
        self.foreground_color     =3
        self.window_style         ="BOTTOM"
        self.stream               =stream
        self.extra_text           =""

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




   
    # only level 1 optomised for reduced calculations in inner loops
    # TODO: runtime calculation
    cdef draw_character(self,character,x,y,offset,color):
        #print character
        if character>255:
            if character==8216:
                character=39
            elif character==8217:
                character=39
            elif character==9472:
                character=196
            elif character==9474:
                character=179
            elif character==9484:
                character=218
            elif character==9488:
                character=191
            elif character==9492:
                character=192
            elif character==9496:
                character=217
            elif character==9600:
                character=223
            elif character==9604:
                character=220
            elif character==9608:
                character=219
            elif character==9612:
                character=221
            elif character==9616:
                character=222
            elif character==9617:
                character=176
            elif character==9618:
                character=177
            elif character==10140:
                character=26
            else:
                print ("Missing character: {0}".format(character))
                return

        #print "FOUND"
        cdef int fs= font.width
        cdef int fw= font.font_width
        cdef int fh= font.font_height
        cdef int fox=font.offset_x
        cdef int foy=font.offset_y
        cdef int fsx=font.spacing_x
        cdef int fsy=font.spacing_y
        cdef int transparent=font.transparent
        cdef int cx=int(character%font.chars_per_line)
        cdef int cy=int(character/font.chars_per_line)
        cdef int pre_x=fox+cx*fw
        cdef int pre_y=(foy+cy*fh)*fs
        cdef int pre=pre_x+pre_y
        cdef int pre_y2=0
        cdef int screen_pos
        cdef int screen_pos2
        cdef int pos
        cdef int pos2
        if y<0 or x<0:
         return
        for fy in range(0,fh): 
            sy=fy+(y*(fh+fsy))
            sx=(x*(fw+fsx))
            screen_pos=sx+(sy-offset)*self.viewport_px_width
            if screen_pos>=self.video_length:
                continue
            pos=pre+pre_y2
            for fx in range(0,fw):
                screen_pos2=screen_pos+fx
                if screen_pos2<0 or screen_pos2>=self.video_length:
                    continue
                pos2=pos+fx
                pixel=font.graphic[pos2]
                if pixel!=transparent:
                    self.video[screen_pos2]=color[0]
                else:
                    self.video[screen_pos2]=color[1]
            pre_y2+=fs
            

    cdef get_buffer_height(self):
        #print self.buffer_rows,"ROWS"
        height=self.buffer_rows*font.font_height
        return height

    # todo save as gif..
    # pre test with canvas extension    
    def render(self):
        self.stream_to_buffer()
        #self.clear_screen(self.bg,255) x
        self.video=[self.background_color]*(self.viewport_px_width*self.viewport_px_height)
        self.video_length=len(self.video)

        
        #buffer_height=self.get_buffer_height()
        #if self.window=="BOTTOM":
        #   if  self.buffer_rows<=self.viewport_char_height:
        #       offset=0
        #   else:
        #       offset=buffer_height-self.viewport_px_height

        #if self.window=="TOP":
        #    offset=0

        #print offset,buffer_height
        buffer_len=len(self.buffer)
        buffer_size_needed=self.viewport_char_width*self.viewport_char_height*2
        #print("Buffer - Have:{0}, Need: {1}".format(buffer_len,buffer_size_needed))
        if buffer_len<self.viewport_char_width*self.viewport_char_height*2:
            err_msg="Buffer underflow: buffersize to small Have:{0}, Need: {1}".format(buffer_len,buffer_size_needed)
            raise Exception(err_msg)
        
        index=0
        for y in range(0,self.viewport_char_height):
            for x in range(0,self.viewport_char_width):
                #if y<offset:
                #    continue
                color=self.buffer[index]
                character=self.buffer[index+1]
                self.draw_character(character,x,y,0,color)
                index+=2
  
    # convert the text stream to a text formated grid
    cdef debug(self): 
        print("VIEWPORT:")
        print("  px height:      {0}".format(self.viewport_px_height))
        print("  px width:       {0}".format(self.viewport_px_width))
        print("  char height:    {0}".format(self.viewport_char_height))
        print("  char width:     {0}".format(self.viewport_char_width))
        print("  buffer size:    {0}".format(self.viewport_char_width*self.viewport_char_height*2))

        print("Buffer:")
        print("buffer char height: {0}".format(self.buffer_rows))

    
        
    cdef shift_buffer(self,buffer):
        cdef int index=self.viewport_char_width
        for i in range(0,index):
            buffer.pop(0)
            buffer.pop(0)
        buffer+=[[0,0],0]*self.viewport_char_width


    cdef write_buffer(self,x,y,c,buffer,fg,bg,reverse):
        cdef int pos=x*2+y*self.viewport_char_width*2
        #if pos>= len(buffer):
        #print (pos,x,y,len(buffer),self.viewport_char_width,self.viewport_char_height)
        if reverse:
            buffer[pos]=[bg,fg]
        else:
            buffer[pos]=[fg,bg]
        buffer[pos+1]=c




    # commands pre parsed on add_event
    cdef stream_to_buffer(self):
        
        cdef int pos=0
        cdef int cursor = 0
        # pre buffer
        buffer=self.buffer
        overflow=None

        
        x=self.x
        y=self.y
        def_fg=self.def_fg
        def_bg=self.def_bg
        fg=self.fg
        bg=self.bg
        reverse_video=self.reverse_video
        bold=self.bold

        cursor=0
        new_sequence_pos=self.sequence_pos
        for event in self.sequence[self.sequence_pos:]:
            new_sequence_pos+=1
            if event['type']=='text':
                self.info(u"X:{0:<2} {1:<2},FG:{2:<2},BG:{3},Text: {3}".format(x,y,fg,bg,event['data']))
                for character in event['data']:
                    # new line or wrap
                    char_ord=ord(character)
                    # handle non printable codes here
                    #print char_ord
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
                        continue
                    if x>=self.viewport_char_width:
                        x=0
                        y+=1
                        if y>=self.viewport_char_height:
                            y=self.viewport_char_height-1
                            self.shift_buffer(buffer)
                    self.write_buffer(x,y,char_ord,buffer,fg,bg,reverse_video)
                    x+=1
                continue


            #print cursor,start, end
            params   =event['params']
            command  =event['command']
            esc_type =event['esc_type']
            groups   =event['groups']

            if esc_type=='OSC':
                self.info("OSC")
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
                            fg=params[2] # rgb
                        if params[1]==5:
                            fg=params[2]
                        self.info("Set FG:{0}".format(params))
                    elif 48 in params:
                            if params[1]==2:
                                bg=params[2] #rgb
                            if params[1]==5:
                                bg=params[2]
                            self.info("Set BG:{0}".format(params))
                    else:
                        for cmd in params:
                            if cmd==0:
                                fg=def_fg
                                bg=def_bg
                                bold=None
                                reverse_video=None
                                self.info("RESET All:{0}".format(params))
                            elif cmd==1:
                                bold=True
                                self.info("Set BOLD:{0}".format(params))
                            elif cmd==7:
                                self.info("Reverse Video On:{0}".format(params))
                                reverse_video=True
                            elif cmd==27:
                                self.info("Reverse Video Off:{0}".format(params))
                                reverse_video=None
                            elif cmd>=30 and cmd<=37:
                                fg=cmd-30
                                if bold:
                                    fg+=8
                                self.info("Set FG:{0}".format(params))
                            elif cmd==39:
                                fg=def_fg
                                self.info("Set Default FG:{0}".format(params))
                            elif cmd>=40 and cmd<=47:
                                bg=cmd-40
                                if bold:
                                    fg+=8
                                self.info("Set BG:{0}".format(params))
                            elif cmd==49:
                                bg=def_bg
                                self.info("Set Default BG:{0}".format(params))
                            elif cmd>=90 and cmd<=97:
                                fg=cmd-90+8
                                self.info("Set High INTENSITY FG:{0}".format(params))
                            elif cmd>=100 and cmd<=107:
                                bg=cmd-100+8
                                self.info("Set High INTENSITY BG:{0}".format(params))
                else:
                    if command=='A': # move cursor up
                        self.info("Cursor Up:{0}".format(params[0]))
                        y=-params[0]
                        if y<0:
                            y=0
                    elif command=='B': # move cursor down
                        self.info("Cursor Down:{0}".format(params[0]))
                        y=+params[0]
                        #if y<0:
                        #    y=0
                    elif command=='C': # move cursor back
                        self.info("Cursor Right:{0}".format(params[0]))
                        x=+params[0]
                        if x<0:
                            x==0
                    elif command=='D': # move cursor right
                        self.info("Cursor Left:{0}".format(params[0]))
                        x=-params[0]
                        if x>=self.viewport_char_width:
                            x=self.viewport_char_width-1
                    elif command=='E': # move cursor next line
                        self.info("Cursor Next Line:{0}".format(params[0]))
                        x=0
                        y+=params[0]
                        if y>=self.viewport_char_height:
                            while y>=self.viewport_char_height:
                                y-=1
                                self.shift_buffer(buffer)

                    elif command=='F': # move cursor previous  line
                        self.info("Cursor Previous Line:{0}".format(params[0]))
                        x=0
                        y-=params[0]
                        if y<0:
                            y=0
                    elif command=='G': # move cursor to HORIZONTAL pos X
                        self.info("Cursor X:{0}".format(params[0]))
                        x=params[0]
                    elif command=='H' or command==ord('f'): # move cursor to x,y pos
                        self.info("Cursor Pos:{0},{1}".format(params[1],params[0]))
                        x=params[1]-1
                        y=params[0]-1
                        if y>=self.viewport_char_height:
                            y=self.viewport_char_height-1

                    elif command=='J': # erase display
                        if params[0]==1:
                            self.info("Erase Display to cursor")
                            x=0
                            y=0
                            pos=0
                            buffer=[[0,0],0]*self.viewport_char_width*self.viewport_char_height
                            buffer_len=len(buffer)
                            self.info("buffer_len: {0}".format(buffer_len))
                        if params[0]==2:
                            self.info("Erase Display")
                            x=0
                            y=0
                            pos=0
                            buffer=[[0,0],0]*self.viewport_char_width*self.viewport_char_height
                            buffer_len=len(buffer)
                            self.info("buffer_len: {0}".format(buffer_len))
                        if params[0]==3:
                            self.info("Erase Display and buffer")
                            x=0
                            y=0
                            pos=0
                            buffer=[[0,0],0]*self.viewport_char_width*self.viewport_char_height
                            buffer_len=len(buffer)
                            self.info("buffer_len: {0}".format(buffer_len))

                    elif command=='K': # erase line
                        self.info("Erase Line: {0}".format(params[0]))
                        if params[0]==0:
                            for x2 in range(x,self.viewport_char_width):
                                self.write_buffer(x2,y,32,buffer,fg,bg,reverse_video)
                        elif params[0]==1:
                            for x2 in range(0,x):
                                self.write_buffer(x2,y,32,buffer,fg,bg,reverse_video)
                        elif params[0]==2:
                            for x2 in range(0,self.viewport_char_width):
                                self.write_buffer(x2,y,32,buffer,fg,bg,reverse_video)
                    else:
                        self.info("Impliment: pos x:{2},Y:{3} - {0}-{1}".format(command,params,x,y))
            
        
        

        self.buffer_rows=self.viewport_char_height
        self.buffer=buffer
        self.sequence_pos=new_sequence_pos

        self.x=x
        self.y=y
        self.def_fg=def_fg
        self.def_bg=def_bg
        self.fg=fg
        self.bg=bg
        self.reverse_video=reverse_video
        self.bold=bold


   

    def get(self):
        return {'width':self.viewport_px_width,'height':self.viewport_px_height,'data':self.video,'color_table':self.color_table}

    def add_event(self,event):
        timestamp=event[0]
        event_type=event[1]
        event_io=event[2]
        if event_type=='o':
            print (self.ascii_safe(self.extra_text))
            self.stream_2_sequence(self.extra_text+event_io,timestamp)
            #self.stream+=event_io

        #udata=event_io.decode("utf-8")
        #asciidata=udata.encode("ascii","ignore")
        #self.stream+=asciidata

    cdef save_screen(self):
        # todo save as gif..
        # pre test with canvas extension
        x=1



    
    cdef stream_2_sequence(self,text,timestamp):
        ANSI_OSC_RE = re.compile('\001?\033\\]((?:.|;)*?)(\x07)\002?')        # Operating System Command
        # stripping OS Commands
        replacment_text=""
        cdef cursor=0
        for match in ANSI_OSC_RE.finditer(text):
            start, end = match.span()
            replacment_text+=text[cursor:start]
            cursor=end
            groups= match.groups()
            paramstring, command = match.groups()
            self.sequence.append({'type':'command','timestamp':timestamp,'esc_type':'OSC','command':command,'params':paramstring,'groups':groups,'name':""})
        replacment_text+=text[cursor:]
        text=replacment_text
        
        # patterns for filtering out commands from the stream
        ANSI_SINGLE   ='[\001b|\033]([cDEHMZ78>=])'
        ANSI_CHAR_SET = '[\001b|\033]\\%([@G*])'
        ANSI_G0       = '[\001b|\033]\\(([B0UK])'
        ANSI_G1       = '[\001b|\033]\\)([B0UK])'
        ANSI_CSI_RE   = '[\001b|\033]\\[((?:\\d|;|<|>|=|\?)*)([a-zA-Z])\002?'
        
        ESC_SEQUENCES=[ANSI_SINGLE,ANSI_CHAR_SET,ANSI_G0,ANSI_G1,ANSI_CSI_RE]
        
        ANSI_REGEX="("+")|(".join(ESC_SEQUENCES)+")"
        
        
        ANSI=re.compile(ANSI_REGEX)
        cursor=0
        for match in ANSI.finditer(text):
            name=""
            start, end = match.span()
            self.add_text_sequence(text[cursor:start],timestamp)
            cursor = end
            command=None
            params=None
            esc_type=None
            groups=match.groups()
            if groups[0]:
                esc_type='SINGLE'
                command=groups[1]
            if groups[2]:
                esc_type='CHAR_SET'
                command=groups[3]
            if groups[4]:
                esc_type='G0'
                command=groups[5]
            if groups[6]:
                esc_type='G1'
                command=groups[7]
            if groups[8]:
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
                self.add_command_sequence(esc_type,command,params,groups,name,timestamp)
        
        
        self.extra_text=text[cursor:]

    def clear_sequence(self):
        self.sequence=[]

    def add_text_sequence(self,text,timestamp):
        if len(text)==0:
            return
        self.info ("Text: '{0}' Length:{1} Timestamp:{2}".format(self.ascii_safe(text),len(text),timestamp))
        self.sequence.append({'type':'text','data':text,'timestamp':timestamp})

    def add_command_sequence(self,esc_type,command,params,groups,name,timestamp):
        self.info("CMD:  '{0}', Name:'{3}', Command:{1}, Params:{2}  Timestamp:{4}".format(
                                                esc_type,
                                                command,
                                                params,
                                                name,
                                                timestamp))
        self.sequence.append({'type':'command','esc_type':esc_type,'command':command,'params':params,'groups':groups,'name':name,'timestamp':timestamp})

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
