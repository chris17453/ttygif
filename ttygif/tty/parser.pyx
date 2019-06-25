
import re


# Reference
# http://man7.org/linux/man-pages/man4/console_codes.4.html

cdef class term_parser:
    cdef object debug_mode
    cdef object sequence
    cdef int    sequence_pos
    cdef object extra_text
    cdef double last_timestamp

    def __init__(self,debug_mode=None):
        self.debug_mode=debug_mode
        self.sequence=[]
        self.sequence_pos=0
        self.last_timestamp=0
        self.extra_text=""

    def clear_sequence(self):
        self.sequence=[]
    
    def rgb_to_palette(self,r,g,b):
        last_distance=-1
        mappeded_color=-1

        for i in range(0,len(self.color_table)):
            color=self.color_table[i]
            
            color_distance=(r-color[0])*(r-color[0])+(g-color[1])*(g-color[1])+(b-color[2])*(b-color[2])
            if last_distance==-1 or color_distance<last_distance:
                last_distance=color_distance
                mappeded_color=i
        
        #print r,g,b,mappeded_color#color_distance,color[0],color[1],color[2]
        return mappeded_color

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

    cdef sequence_to_buffer(self,term_frame frame):
        
        cdef int pos=0
        cdef int cursor = 0
        # pre buffer
        buffer=self.buffer
        overflow=None
        new_sequence_pos=self.sequence_pos #self.sequence_pos:

        for event in self.sequence[self.sequence_pos:]:
            new_sequence_pos+=1
            if event['type']=='text':
                #if self.debug_mode:
                    #self.info(u"X:{0:<2} {1:<2},FG:{2:<2},BG:{3},Text: {4}".format(x,y,self.fg,self.bg,event['data']))
                for character in event['data']:
                    # new line or wrap
                    char_ord=ord(character)
                    # handle non printable codes here
                    if char_ord<32:
                        if char_ord==0x08:
                            frame.state.cursor_left()
                        if char_ord==0x0A:
                            frame.state.cursor_absolute_x(0)
                            frame.state.cursor_down()
                        continue
                    if x>=self.viewport_char_width:
                            frame.state.cursor_right()
                    frame.write(char_ord)
                    frame.state.cursor_right()
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
                            frame.foreground_from_rgb(params[2],params[3],params[4])
                        if params[1]==5:
                            frame.set_foreground(params[2])
                    elif 48 in params:
                            if params[1]==2:
                                self.background_from_rgb(params[2],params[3],params[4])
                            if params[1]==5:
                                frame.set_background(params[2])
                    else:
                        for cmd in params:
                           self.set_mode(cmd)
                else:
                    if command=='A': # move cursor up
                        y-=params[0]
                        if y<0:
                            y=0;
                    elif command=='B': # move cursor down
                        y+=params[0]
                        if y>=self.viewport_char_height:
                            y=self.viewport_char_height-1

                    elif command=='C': # move cursor foreward
                        x+=params[0]
                        if x>=self.viewport_char_width:
                            x=self.viewport_char_width-1

                    elif command=='D': # move cursor back
                        x-=params[0]
                        if x<0:
                            x=0
                    elif command=='E': # move cursor next line
                        x=0
                        y+=params[0]

                    elif command=='F': # move cursor previous  line
                        x=0
                        y-=params[0]
                    elif command=='G': # move cursor to HORIZONTAL pos X
                        x=params[0]-1
                    elif command=='`': # move cursor to HORIZONTAL pos X
                        x=params[0]-1

                    elif command=='H' or command=='f': # move cursor to x,y pos
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
                        y=params[0]-1
                        x=0
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
                    elif command=='P': 
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
                                

                    elif command=='X': 
                        if self.debug_mode:
                            self.info("Delete number of charchters on line:{0},x:{1:<2},y:{2:<2}".format(params[0],x,y))
                        #b=self.bg
                        #self.bg=14
                        for x2 in range(x,x+params[0]):
                            self.write_buffer(x2,y,0,buffer)
                        #self.bg=b
                        
                    else:
                        if self.debug_mode:
                            self.info("Impliment: pos x:{2},Y:{3} - {0}-{1}".format(command,params,x,y))
            
        
        

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
  

