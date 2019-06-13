from cpython cimport array
import array
import re

from .font cimport font_map
from .fonts cimport font
#import font

# Reference
# http://man7.org/linux/man-pages/man4/console_codes.4.html


cdef class viewer:
    cdef public int         debug
    cdef public int         viewport_px_width
    cdef public int         viewport_px_height
    cdef public int         viewport_char_height
    cdef public int         viewport_char_width
    cdef public int         background_color
    cdef public int         foreground_color
    cdef public object       window_style
    cdef public object       stream
    cdef public int         video_length
    cdef object video
    cdef object color_table
    cdef object buffer
    
    cdef info(self,text):
        if self.debug:
            print(text)

    cdef init_video(self):
        self.video                =[0]*self.viewport_px_width*self.viewport_px_height
        
    def __init__(self,width=640,height=480,char_width=None,char_height=None,stream='',debug=None):
        self.debug                =debug
        self.viewport_px_width    =width
        self.viewport_px_height   =height
        self.viewport_char_height =self.viewport_px_width/font.font_width
        self.viewport_char_width  =self.viewport_px_height/font.font_height
        self.init_video()
        self.video_length         =len(self.video)
        self.background_color     =0
        self.foreground_color     =3
        self.window_style         ="BOTTOM"
        self.stream               =stream
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
        fs= font.width
        fw= font.font_width
        fh= font.font_height
        fox=font.offset_x
        foy=font.offset_y
        fsx=font.spacing_x
        fsy=font.spacing_y
        transparent=font.transparent
        cx=int(character%font.chars_per_line)
        cy=int(character/font.chars_per_line)

        pre_x=fox+cx*fw
        pre_y=(foy+cy*fh)*fs
        pre=pre_x+pre_y
        pre_y2=0
        for fy in range(0,fh): 
            sy=fy+(y*(fh+fsy))
            sx=(x*(fw+fsx))
            screen_pos=sx+(sy-offset)*self.viewport_px_width
            if screen_pos<0 or screen_pos>=self.video_length:
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
        print("buffer_len:     {0}".format(len(self.buffer)))

    
        
    cdef shift_buffer(self,buffer):
        index=self.viewport_char_width
        for i in range(0,index):
            buffer.pop(0)
            buffer.pop(0)
        buffer+=[[0,0],0]*self.viewport_char_width


    cdef write_buffer(self,x,y,c,buffer,fg,bg):
        pos=x*2+y*self.viewport_char_width*2
        #if pos>= len(buffer):
        #print (pos,x,y,len(buffer),self.viewport_char_width,self.viewport_char_height)
        buffer[pos]=[fg,bg]
        buffer[pos+1]=c




    cdef stream_to_buffer(self):
        
        pos=0
        # pre buffer
        buffer=[[0,0],0]*self.viewport_char_width*self.viewport_char_height
        overflow=None


        cursor = 0
        
        ANSI_OSC_RE = re.compile('\001?\033\\]((?:.|;)*?)(\x07)\002?')        # Operating System Command
        text=""
        for match in ANSI_OSC_RE.finditer(self.stream):
            start, end = match.span()
            text+=self.stream[cursor:start]
            cursor=end
            #text = text[:start] + text[end:]
            #print "--"
            #text=self.stream[start:end]
            #text=text.replace(u"\001b]",'BAR').replace("\x07",'BELL')
            #print("=="+text+"==")
            #paramstring, command = match.groups()
            #if command in '\x07':       # \x07 = BEL
            #    params = paramstring.split(";")
                # 0 - change title and icon (we will only change title)
                # 1 - change icon (we don't support this)
                # 2 - change title
                #if params[0] in '02':
                #    winterm.set_title(params[1])
        text+=self.stream[cursor:]
        self.stream=text

        ANSI_SINGLE='[\001b|\033]([cDEHMZ78>=])'
        ANSI_CHAR_SET = '[\001b|\033]\\%([@G*])'
        ANSI_G0 = '[\001b|\033]\\(([B0UK])'
        ANSI_G1 = '[\001b|\033]\\)([B0UK])'
        ANSI_CSI_RE = '[\001b|\033]\\[((?:\\d|;|<|>|=|\?)*)([a-zA-Z])\002?'
        
        ANSI_REGEX=[ANSI_SINGLE,ANSI_CHAR_SET,ANSI_G0,ANSI_G1,ANSI_CSI_RE]

        buffer_len=0
        x=0
        y=0
        def_fg=15
        def_bg=0
        fg=def_fg
        bg=def_bg
        ANSI_REGEX="("+")|(".join(ANSI_REGEX)+")"
        #print ANSI_REGEX.replace("\001b","^").replace("\033","^")
        
        
        ANSI=re.compile(ANSI_REGEX)
        #print("-----")
        cursor=0
        for match in ANSI.finditer(self.stream):
            start, end = match.span()

            self.info(u"{0},{1}:{2}".format(fg,bg,self.stream[cursor:start]))
            for i in range(cursor,start):
                # new line or wrap
                character=self.stream[i]
                char_ord=ord(character)
                # handle non printable codes here
                #print char_ord
                if char_ord<32:
                    if char_ord==0x08:
                        x-=1
                    if char_ord==0x0A:
                        x=0
                        y+=1
                        if y>=self.viewport_char_height:
                            y-=1
                            self.shift_buffer(buffer)
                        continue
                    if x>=self.viewport_char_width:
                        x=0
                        y+=1
                        if y>=self.viewport_char_height:
                            y-=1
                            self.shift_buffer(buffer)
                    continue
                if x>=self.viewport_char_width:
                    x=0
                    y+=1
                    if y>=self.viewport_char_height:
                        y-=1
                        self.shift_buffer(buffer)
                    #print x,y,character,fg,bg
                # print the space...
                self.write_buffer(x,y,char_ord,buffer,fg,bg)
                x+=1            


            #print cursor,start, end
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
                command=ord(command)
                
                if command==109:
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
                                self.info("RESET All:{0}".format(params))
                            elif cmd==1:
                                bold=True
                                self.info("Set BOLD:{0}".format(params))
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
                    if command==ord('A'): # move cursor up
                        self.info("Cursor Up:{0}".format(params[0]))
                        y=-params[0]
                        if y<0:
                            y=0
                    elif command==ord('B'): # move cursor down
                        self.info("Cursor Down:{0}".format(params[0]))
                        y=+params[0]
                        #if y<0:
                        #    y=0
                    elif command==ord('C'): # move cursor back
                        self.info("Cursor Left:{0}".format(params[0]))
                        x=-params[0]
                        if x<0:
                            x+=self.viewport_char_width
                    elif command==ord('D'): # move cursor right
                        self.info("Cursor Right:{0}".format(params[0]))
                        x=+params[0]
                        if x>=self.viewport_char_width:
                            x-=self.viewport_char_width
                    elif command==ord('E'): # move cursor next line
                        self.info("Cursor Next Line:{0}".format(params[0]))
                        x=0
                        y+=params[0]
                        if y>=self.viewport_char_height:
                            while y>=self.viewport_char_height:
                                y-=1
                                self.shift_buffer(buffer)

                    elif command==ord('F'): # move cursor previous  line
                        self.info("Cursor Previous Line:{0}".format(params[0]))
                        x=0
                        y-=params[0]
                        if y<0:
                            y=0
                    elif command==ord('G'): # move cursor to HORIZONTAL pos X
                        self.info("Cursor X:{0}".format(params[0]))
                        x=params[0]
                    elif command==ord('H') or command==ord('f'): # move cursor to x,y pos
                        self.info("Cursor Pos:{0},{1}".format(params[0],params[1]))
                        x=params[0]
                        y=params[1]
                        if y>=self.viewport_char_height:
                            y=self.viewport_char_height-1

                    elif command==ord('J'): # erase display
                        self.info("Erase Display")
                        x=0
                        y=0
                        pos=0
                        buffer=[[0,0],0]*self.viewport_char_width*self.viewport_char_height
                        buffer_len=len(buffer)
                    elif command==ord('K'): # erase line
                        self.info("Erase Line: {0}".format(params[0]))
                        if params[0]==0:
                            for x2 in range(x,self.viewport_char_width):
                                self.write_buffer(x2,y,32,buffer,fg,bg)
                        elif params[0]==1:
                            for x2 in range(0,x):
                                self.write_buffer(x2,y,32,buffer,fg,bg)
                        elif params[0]==2:
                            for x2 in range(0,self.viewport_char_width):
                                self.write_buffer(x2,y,32,buffer,fg,bg)
                    else:
                        self.info("Impliment: Start: {5} pos x:{3},Y:{4} - {0}-{1}-{2}".format(command,params,paramstring,x,y,start))
#            print( esc_type,command,params)
            
        for i in range(cursor,len(self.stream)):
            character=self.stream[i]
            char_ord=ord(character)
            # handle non printable codes here
            #print char_ord
            if char_ord<32:
                if char_ord==0x08:
                    x-=1
                if char_ord==0x0A:
                    x=0
                    y+=1
                    if y>=self.viewport_char_height:
                        y-=1
                        self.shift_buffer(buffer)

                if x>=self.viewport_char_width:
                    x=0
                    y+=1
                    if y>=self.viewport_char_height:
                        y-=1
                        self.shift_buffer(buffer)
                continue
            if x>=self.viewport_char_width:
                x=0
                y+=1
                if y>=self.viewport_char_height:
                    y-=1
                    self.shift_buffer(buffer)
            self.write_buffer(x,y,char_ord,buffer,fg,bg)
            x+=1        
        
        

        self.buffer_rows=self.viewport_char_height
        self.buffer=buffer
   

    cdef get(self):
        return {'width':self.viewport_px_width,'height':self.viewport_px_height,'data':self.video,'color_table':self.color_table}

    def add_event(self,event):
        timestamp=event[0]
        event_type=event[1]
        event_io=event[2]
        if event_type=='o':
            self.stream+=event_io

        #udata=event_io.decode("utf-8")
        #asciidata=udata.encode("ascii","ignore")
        #self.stream+=asciidata

    cdef save_screen(self):
        # todo save as gif..
        # pre test with canvas extension
        x=1



