from .terminal_graphics cimport terminal_graphics
import re


# Reference
# http://man7.org/linux/man-pages/man4/console_codes.4.html

cdef class term_parser:
    def __init__(self,terminal_graphics terminal_graphics,debug_mode=None):
        self.debug_mode=debug_mode
        self.sequence=[]
        self.sequence_pos=0
        self.last_timestamp=0
        self.extra_text=""
        self.terminal_graphics=terminal_graphics

    cdef ascii_safe(self,text):
        return ''.join([i if ord(i) < 128 else '*' for i in text])

    cdef info(self,text):
        if self.debug_mode:
            print(self.ascii_safe(text))

    cdef clear_sequence(self):
        self.sequence=[]
    
    cdef rgb_to_palette(self,r,g,b):
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


    
    cdef render_to_buffer(self):

        new_sequence_pos=self.sequence_pos #self.sequence_pos:
        for event in self.sequence[self.sequence_pos:]:
            new_sequence_pos+=1
            if   event['type']=='text': 
                self.cmd_render_text(event)
                continue
            params   =event['params']
            command  =event['command']
            esc_type =event['esc_type']
            groups   =event['groups']

            
            if   esc_type=='OSC'      : self.procces_OSC(groups)
            elif esc_type=='SINGLE'   : self.process_DSINGLE(groups[1])
            elif esc_type=='CHAR_SET' : self.process_CHAR_SET(groups[3])
            elif esc_type=='G0'       : self.process_G0(groups[5])
            elif esc_type=='G1'       : self.process_G1(groups[7])
            elif esc_type=='CSI'      : self.process_CSI(command,params)
        self.sequence_pos=new_sequence_pos

    # TODO STUBS
    cdef procces_OSC(self,groups):
        self.info(groups)

    cdef process_DSINGLE(self,groups):
        self.info(groups)

    cdef process_CHAR_SET(self,groups):
        self.info(groups)

    cdef process_G0(self,groups):
        self.info(groups)

    cdef process_G1(self,groups):
        self.info(groups)

    cdef process_CSI(self,command,params):
        if   command=='m':  self.cmd_process_colors(params)
        elif command=='A':  self.cmd_cursor_up(params[0])
        elif command=='B':  self.cmd_cursor_down(params[0])
        elif command=='C':  self.cmd_cursor_right(params[0])
        elif command=='D':  self.cmd_cursor_left(params[0])
        elif command=='E':  self.cmd_next_line(params[0])
        elif command=='F':  self.cmd_previous_line(params[0])
        elif command=='G':  self.cmd_absolute_x(params[0]-1)
        elif command=='H':  self.cmd_absolute_pos(params[1]-1,params[0]-1)
        elif command=='J':  self.cmd_erase_display(params[0])
        elif command=='K':  self.cmd_erase_line(params[0])
        elif command=='P':  self.cmd_erase_chaaracters(params[0])
        elif command=='X':  self.cmd_del_characters(params[0])
        elif command=='`':  self.cmd_absolute_x(params[0]-1)
        elif command=='d':  self.cmd_vert_pos(params[0]-1)
        elif command=='f':  self.cmd_absolute_pos(params[1]-1,params[0]-1)
        elif command=='h':  self.cmd_set_mode(params)
        elif command=='l':  self.cmd_reset_mode(params[0])
        #elif command=='e': 
        #    if self.debug_mode:
        #        self.info("Cursor Down rows:{0},x:{1:<2},y:{2:<2}".format(params[0],x,y))
        #    y+=params[0]
        
        else: self.info("Impliment: {0}-{1}".format(command,params))
        
    cdef cmd_set_mode(self,cmd):
        if cmd==0:
            self.terminal_graphics.state.foreground=self.terminal_graphics.state.default_foreground
            self.terminal_graphics.state.background=self.terminal_graphics.state.default_background
            self.terminal_graphics.state.bold=None
            self.terminal_graphics.state.reverse_video=None
        elif cmd==1:
            self.terminal_graphics.state.bold=True
        elif cmd==7:
            self.terminal_graphics.state.reverse_video=True
        elif cmd==27:
            self.terminal_graphics.state.reverse_video=None
        elif cmd>=30 and cmd<=37:
            self.terminal_graphics.state.foreground=cmd-30
            if self.terminal_graphics.state.bold:
                self.terminal_graphics.state.foreground+=8
        elif cmd==39:
            self.terminal_graphics.state.foreground=self.terminal_graphics.state.default_foreground
        elif cmd>=40 and cmd<=47:
            self.terminal_graphics.state.background=cmd-40
            if self.terminal_graphics.state.bold:
                self.terminal_graphics.state.foreground+=8
        elif cmd==49:
            self.terminal_graphics.state.background=self.terminal_graphics.state.default_background
        elif cmd>=90 and cmd<=97:
            self.terminal_graphics.state.foreground=cmd-90+8
        elif cmd>=100 and cmd<=107:
            self.terminal_graphics.state.background=cmd-100+8

    cdef cmd_reset_mode(self,cmd):
        if cmd==0:
            self.terminal_graphics.state.foreground=self.terminal_graphics.state.default_foreground
            self.terminal_graphics.state.background=self.terminal_graphics.state.default_background
            self.terminal_graphics.state.bold=None
            self.terminal_graphics.state.reverse_video=None
        elif cmd==1:
            self.terminal_graphics.state.bold=None
        elif cmd==7:
            self.terminal_graphics.state.reverse_video=None


    cdef cmd_process_colors(self,params):
        if 38 in params:
            if params[1]==2:
                self.terminal_graphics.foreground_from_rgb(params[2],params[3],params[4])
            if params[1]==5:
                self.terminal_graphics.set_foreground(params[2])
        elif 48 in params:
                if params[1]==2:
                    self.terminal_graphics.background_from_rgb(params[2],params[3],params[4])
                if params[1]==5:
                    self.terminal_graphics.set_background(params[2])
        else:
            for cmd in params:
                self.cmd_set_mode(cmd)

    cdef cmd_render_text(self,event):
        for character in event['data']:
            char_ord=ord(character)
            if char_ord<32:
                if char_ord==0x08:
                    self.terminal_graphics.state.cursor_left(1)
                if char_ord==0x0A:
                    self.terminal_graphics.state.cursor_absolute_x(0)
                    self.terminal_graphics.state.cursor_down(1)
                self.terminal_graphics.state.cursor_right(1)
                continue
            self.terminal_graphics.write(char_ord)
            self.terminal_graphics.state.cursor_right(1)


    cdef cmd_cursor_up(self,distance):
        self.terminal_graphics.state.cursor_up(distance)

    cdef cmd_cursor_down(self,distance):
        self.terminal_graphics.state.cursor_down(distance)

    cdef cmd_cursor_left(self,distance):
        self.terminal_graphics.state.cursor_left(distance)

    cdef cmd_cursor_right(self,distance):
        self.terminal_graphics.state.cursor_right(distance)

    cdef cmd_previous_line(self,distance):
        self.terminal_graphics.state.cursor_absolute_x(0)
        self.terminal_graphics.state.cursor_up(distance)

    cdef cmd_next_line(self,distance):
        self.terminal_graphics.state.cursor_absolute_x(0)
        self.terminal_graphics.state.cursor_up(distance)

    cmd_cdef absolute_pos_x(self,x):
        self.terminal_graphics.state.cursor_absolute_x(x)

    cdef cmd_absolute_pos_y(self,y):
        self.terminal_graphics.state.cursor_absolute_y(y)
    
    cdef cmd_absolute_pos(self,x,y):
        self.terminal_graphics.state.cursor_absolute(x,y)

    cdef cmd_vert_pos(self,position):
        self.terminal_graphics.state.cursor_absoloute(0,position)

    cdef cmd_erase_display(self,mode):
        if mode==0:
            self.terminal_graphics.state.save_cursor_position()
            for x in range(self.terminal_graphics.state.cursor_x,self.terminal_graphics.state.width):
                self.terminal_graphics.state.cursor_absolute_x(x)
                self.terminal_graphics.write(32)
            self.terminal_graphics.state.restore_cursor_position()
        if mode==1:
            self.terminal_graphics.state.save_cursor_position()
            for x in range(0,self.terminal_graphics.state.cursor_x+1):
                self.terminal_graphics.state.cursor_absolute_x(x)
                self.terminal_graphics.write(32)
            self.terminal_graphics.state.restore_cursor_position()

        if mode==2:
            self.terminal_graphics.viewport.clear(self.terminal_graphics.state.background)

    cdef cmd_erase_line(self,mode):
        self.terminal_graphics.state.save_cursor_position()

        if mode==0:
            for x in range(self.terminal_graphics.state.cursor_x,self.terminal_graphics.state.width):
                self.terminal_graphics.state.cursor_absolute_x(x)
                self.terminal_graphics.write(32)
        elif mode==1:
            for x in range(0,self.terminal_graphics.state.cursor_x):
                self.terminal_graphics.state.cursor_absolute_x(x)
                self.terminal_graphics.write(32)
        elif mode==2:
            for x in range(0,self.terminal_graphics.state.width):
                self.terminal_graphics.state.cursor_absolute_x(x)
                self.terminal_graphics.write(32)

        self.terminal_graphics.state.restore_cursor_position()

    cdef cmd_erase_characters(self,distance):
        temp=[]

        cdef int x=self.terminal_graphics.state.cursor_x
        cdef int y=self.terminal_graphics.state.cursor_y
        cdef int width=self.terminal_graphics.state.width
        temp=[]
        #copy elements to buffer
        for x2 in range(x+distance,width):
            temp.append(self.terminal_graphics.character_buffer.get_pixel(x2,y))
        # Move line over x ammount
        for x2 in range(0,width-x-distance):
            c=temp[c]
            self.terminal_graphics.character_buffer.put_pixel(x2+x,y,c)
        # clear the end of the line
        for x2 in range(width-distance,width):
            c=[self.terminal_graphics.state.foreground,self.terminal_graphics.state.background,0]
            self.terminal_graphics.character_buffer.put_pixel(x2,y,c)

    cdef cmd_del_characters(self,length):
        self.terminal_graphics.state.save_cursor_position()
        for x in range(self.terminal_graphics.state.cursor_x,self.terminal_graphics.state.cursor_x+length):
                self.terminal_graphics.state.cursor_absolute_x(x)
                self.terminal_graphics.write(0)
        self.terminal_graphics.state.restore_cursor_position()


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
    
    
    cdef last_frame(self):
        self.add_text_sequence(self.extra_text,self.last_timestamp,0)
        self.extra_text=""
    


    cdef has_escape(self,text):
        for i in text:
            if ord(i)==0x1B:
                return True
        return None    
    
    cdef add_event(self,event):
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
        
    cdef add_text_sequence(self,text,timestamp,delay):
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

    cdef add_command_sequence(self,esc_type,command,params,groups,name,timestamp,delay):
        #if self.debug_mode:
        #    self.info("CMD:  '{0}', Name:'{3}', Command:{1}, Params:{2}  Timestamp:{4}".format(
        #                                        esc_type,
        #                                        command,
        #                                        params,
        #                                        name,
        #                                        timestamp))
        self.sequence.append({'type':'command','esc_type':esc_type,'command':command,'params':params,'groups':groups,'name':name,'timestamp':timestamp,'delay':delay})

    cdef debug_sequence(self):
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
  

