# cython: profile=True
# cython: binding=True
# cython: language_level=2

from .terminal_graphics cimport terminal_graphics
import re
from libc.stdint cimport uint32_t, int64_t,uint16_t,uint8_t,int32_t


# Reference
# http://man7.org/linux/man-pages/man4/console_codes.4.html

cdef class term_parser:
    def __init__(self,terminal_graphics terminal_graphics,debug_mode=None):
        self.debug_mode=debug_mode
        self.sequence=[]
        self.sequence_pos=0
        self.last_timestamp=0
        self.extra_text=""
        self.no_codes=None
        self.bracketed_paste=None
        self.g=terminal_graphics
        self.current_sequence_position=0

    cdef ascii_safe(self,text):
        return ''.join([i if ord(i) < 128 else '*' for i in text])

    cdef ascii_escaped(self,text):
        nt="";
        for t in text:
            i=ord(t)
            if i < 128 and i>=32:
               nt+=t
            elif i==9:
               nt+='\T'
            elif i==8:
               nt+='\BI'
            elif i=='9':
               nt+='\FI'
            elif i==10:
               nt+='\LF'
            elif i==12:
               nt+='\FF'
            else:
               nt+='*'
        return nt

    cdef info(self,text):
        #if self.debug_mode:
            print(self.ascii_safe(text))

    cdef clear_sequence(self):
        self.sequence=[]
    
    cdef rgb_to_palette(self,r,g,b):
        last_distance=-1
        mappeded_color=-1
        palette=self.g.screen.palette
        for i in xrange(0,len(palette),3):
            mr=palette[i]
            mg=palette[i+1]
            mb=palette[i+2]
            
            color_distance=(r-mr)*(r-mr)+(g-mg)*(g-mg)+(b-mb)*(b-mb)
            if last_distance==-1 or color_distance<last_distance:
                last_distance=color_distance
                mappeded_color=i
        if mappeded_color>255:
            print r,g,b,mappeded_color
        return mappeded_color

    
    cdef remap_character(self,character):
    #"""maps a character to ascii"""
      #print character
        #print character
        if character==None:
            return ""

        cdef int c=ord(character)
        #character=character.encode('latin-1')
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
                #print ("Missing character: {0}     ".format(c))
                c=ord('*')
        return chr(c)



    
    cdef render_to_buffer(self):

        new_sequence_pos=self.sequence_pos #self.sequence_pos:
        
        #print(self.sequence)
        for event in self.sequence[self.sequence_pos:]:
            
            self.current_sequence_position=new_sequence_pos
            new_sequence_pos+=1
            if   event['type']=='text': 
                #print event
                self.cmd_render_text(event)
                continue
            params   =event['params']
            command  =event['command']
            esc_type =event['esc_type']
            groups   =event['groups']

            if self.bracketed_paste:
                if  self.no_codes:
                    if esc_type=='CSI' and  command=='~':  
                        self.process_CSI(command,params)
                        continue
                    else:
                        self.cmd_render_text(event)
                        continue
    
                                    
            if   esc_type=='OSC'      : self.procces_OSC(groups)
            elif esc_type=='SINGLE'   : self.process_SINGLE(groups[1])
            elif esc_type=='CHAR_SET' : self.process_CHAR_SET(groups[3])
            elif esc_type=='G0'       : self.process_G0(groups[5])
            elif esc_type=='G1'       : self.process_G1(groups[7])
            elif esc_type=='CSI'      : self.process_CSI(command,params)

            
        self.sequence_pos=new_sequence_pos

    # TODO STUBS
    cdef procces_OSC(self,groups):
        self.info(groups)

    cdef process_SINGLE(self,groups):
        self.info(groups)

    cdef process_CHAR_SET(self,groups):
        self.info(groups)

    cdef process_G0(self,groups):
        self.info(groups)

    cdef process_G1(self,groups):
        self.info(groups)

    cdef process_CSI(self,command,params):
        cdef int param_len=len(params)
        cdef int value1=0
        cdef int value2=0

        # Defaults        
        if param_len>0:
            if isinstance(params[0],int):
                value1=params[0]
            else:
                if command=='r':
                    value1=1

        if param_len>1: 
            if isinstance(params[1],int):
                value2=params[1]
            else:
                if command=='r':
                    value2=self.g.state.height-1

        

        #if self.debug :
        #print("\n\n --- "+command,value1,value1,params,self.g.state.cursor_x,self.g.state.cursor_y,self.g.state.width,self.g.state.height)
        #print(params);
        if   command=='A':  self.cmd_CUU(value1)
        elif command=='B':  self.cmd_CUD(value1)
        elif command=='C':  self.cmd_CUF(value1)
        elif command=='D':  self.cmd_CUB(value1)
        elif command=='E':  self.cmd_CNL(value1)
        elif command=='F':  self.cmd_CPL(value1)
        elif command=='G':  self.cmd_CHA(value1-1)               # abs
        elif command=='H':  self.cmd_CUP(value2-1,value1-1)      # abs
        elif command=='J':  self.cmd_ED(value1)
        elif command=='K':  self.cmd_EL(value1)
        elif command=='P':  self.cmd_DCH(value1)
        elif command=='X':  self.cmd_ECH(value1)
        elif command=='d':  self.cmd_VPA(value1-1)               # abs
        elif command=='`':  self.cmd_HPA(value1-1)               # abs
        elif command=='f':  self.cmd_HVP(value2-1,value1-1)      # abs
        elif command=='h':  
            for cmd in params:
                self.cmd_set_mode(cmd)
        elif command=='l':  self.cmd_reset_mode(value1)
        elif command=='m':  self.cmd_process_colors(params)
        elif command=='r':  self.cmd_DECSTBM(value1-1,value2-1)
        elif command=='s':  self.cmd_SCP()
        elif command=='u':  self.cmd_RCP()
        elif command=='~':  self.cmd_BRACKETED_PASTE(value1)               # abs
        elif command=='?h': self.cmd_DECSET(value1)
        elif command=='?l': self.cmd_DECRST(value1)
        
        #elif command=='e': 
        #    if self.debug_mode:
        #        self.info("Cursor Down rows:{0},x:{1:<2},y:{2:<2}".format(value,x,y))
        #    y+=value
        
        else: self.info("Impliment: {0}-{1}".format(command,params))

   
    cdef cmd_DECSET(self,int code):
        #print "SET",parameters
        if    code==7:
            self.g.state.autowrap_on()
        elif  code==25:
            self.g.state.show_cursor()
        elif  code==1049:
            self.g.alternate_screen_on()
        elif  code==2004:
            self.cmd_bracketed_paste_on()

    cdef cmd_DECRST(self,int code):
        #print "RESET",parameters
        if  code==7:
            self.g.state.autowrap_off()
        elif code==25:
            self.g.state.hide_cursor()
        elif code==1049:
            self.g.alternate_screen_off()
        elif code==2004:
            self.cmd_bracketed_paste_off()
   
    cdef cmd_bracketed_paste_off(self):
        self.bracketed_paste=None
    
    cdef cmd_bracketed_paste_on(self):
        self.bracketed_paste=True

    cdef cmd_BRACKETED_PASTE(self,value):
        #print "eh"
            
        if self.bracketed_paste:
            if value==200:
                self.no_codes=True

            if value==201:
                self.no_codes=None
    
    #TODO cover all codes 0-107
    cdef cmd_set_mode(self,cmd):
        #print(cmd);
        if cmd==0:
            self.set_foreground(self.g.state.default_foreground)
            self.set_background(self.g.state.default_background)
            self.g.state.bold=None
            self.g.state.reverse_video=None
        elif cmd==1:
            self.g.state.bold=True
        elif cmd==7:
            self.g.state.reverse_video=True
        elif cmd==22:
            self.g.state.bold=None
        elif cmd==27:
            self.g.state.reverse_video=None
        elif cmd>=30 and cmd<=37:
            
            if self.g.state.bold:
                self.set_foreground(cmd-30+8)
            else:
                self.set_foreground(cmd-30)
                
        elif cmd==39:
            self.set_foreground(self.g.state.default_foreground)
        elif cmd>=40 and cmd<=47:
            if self.g.state.bold:
                self.set_background(cmd-40+8)
            else:
                self.set_background(cmd-40)
        elif cmd==48:
            self.set_background(self.g.state.default_background)
        elif cmd==49:
            self.set_background(self.g.state.default_background)
        elif cmd>=90 and cmd<=97:
            self.set_foreground(cmd-90+8)
        elif cmd>=100 and cmd<=107:
            self.set_background(cmd-100+8)

    cdef cmd_reset_mode(self,cmd):
        if cmd==0:
            self.g.state.set_foreground(self.g.state.default_foreground)
            self.g.state.set_background(self.g.state.default_background)
            self.g.state.bold=None
            self.g.state.reverse_video=None
        elif cmd==1:
            self.g.state.bold=None
        elif cmd==7:
            self.g.state.reverse_video=None

    cdef set_foreground(self,color):
        if color>=self.g.theme.colors:
            self.g.set_foreground(self.g.state.default_foreground)
        else:
            self.g.set_foreground(color)

    cdef set_background(self,color):
        if color>=self.g.theme.colors:
            self.g.set_background(self.g.state.default_background)
        else:
            self.g.set_background(color)

    cdef cmd_process_colors(self,params):
        if 38 == params[0]:
            if params[1]==2:
                self.g.foreground_from_rgb(params[2],params[3],params[4])
            if params[1]==5:
                    self.set_foreground(params[2])
        elif 48 == params[0]:
                if params[1]==2:
                    self.g.background_from_rgb(params[2],params[3],params[4])
                if params[1]==5:
                    self.set_background(params[2])
        else:
            for cmd in params:
                # print("-->")
                # print(cmd)
                self.cmd_set_mode(cmd)

    # cdef int NULL=0   #   Null character
    # cdef int SOH=1    #   Start of Header
    # cdef int STX=2    #   Start of Text
    # cdef int ETX=3    #   End of Text
    # cdef int EOT=4    #   End of Trans
    # cdef int ENQ=5    #   Enquiry
    # cdef int ACK=6    #   Acknowledgement
    # cdef int BEL=7    #   Bell
    # cdef int HT=9     #   Horizontal Tab
    # cdef int VT=11     #   Vertical Tab
    # cdef int FF=12     #   Form feed
    # cdef int SO=14     #   Shift Out
    # cdef int SI=15     #   Shift In
    # cdef int DLE=16    #   Data link escape
    # cdef int DC1=17    #   Device control 1
    # cdef int DC2=18    #   Device control 2
    # cdef int DC3=19    #   Device control 3
    # cdef int DC4=20    #   Device control 4
    # cdef int NAK=21    #   Negative acknowl.
    # cdef int SYN=22    #   Synchronous idle
    # cdef int ETB=23    #   End of trans. block
    # cdef int CAN=24    #   Cancel
    # cdef int EM=25     #   End of medium
    # cdef int SUB=26    #   Substitute
    # cdef int ESC=27    #   Escape
    # cdef int FS=28     #   File separator
    # cdef int GS=29     #   Group separator
    # cdef int RS=30     #   Record separator
    # cdef int US=31     #   Unit separator                    
    
    
    cdef cmd_render_text(self,event):
        #print event['data']
       
        cdef int BS=8     # x Backspace
        cdef int FI=9     # x Forward Index
        cdef int LF=10     # x Line feed
        cdef int CR=13     # x Carriage return
        self.g.state.text_mode_on()
        for character in event['data']:
            #print(character)
            char_ord=ord(character)
            if char_ord<32 and self.no_codes==None:
                if  char_ord==BS:
                    self.g.state.cursor_left(1)
                if  char_ord==FI:
                    self.g.state.cursor_right(1)
                elif char_ord==LF:
                    self.g.state.cursor_down(1)
                    if self.g.state.mode=="linux":
                        self.g.state.cursor_absolute_x(0)

                elif char_ord==CR:
                    self.g.state.cursor_absolute_x(0)
            else:
                if self.g.state.pending_wrap:
                    self.g.state.cursor_right(1)
                self.g.write(char_ord)
                self.g.state.cursor_right(1)
            while self.g.state.scroll!=0:
                #print("Scroll at {0:005x}".format(self.current_sequence_position))
                self.g.scroll_buffer()
        self.g.state.text_mode_off()
        

    cdef cmd_DECSTBM(self,int top,int bottom):
        self.g.state.set_scroll_region(top,bottom)

    cdef cmd_CUU(self,distance):
        self.g.state.cursor_up(distance)

    cdef cmd_CUD(self,distance):
        self.g.state.cursor_down(distance)

    cdef cmd_CUB(self,distance):
        self.g.state.cursor_left(distance)

    cdef cmd_CUF(self,distance):
        self.g.state.cursor_right(distance)

    cdef cmd_CPL(self,distance):
        self.g.state.cursor_absolute_x(0)
        self.g.state.cursor_up(distance)

    cdef cmd_CNL(self,distance):
        self.g.state.cursor_absolute_x(0)
        self.g.state.cursor_up(distance)

    cdef cmd_CHA(self,x):
        self.g.state.cursor_absolute_x(x)
 
    cdef cmd_CUP(self,x,y):
        self.g.state.cursor_absolute(x,y)
    
    cdef cmd_ED(self,mode):
        if mode==1:
            cp=self.g.state.cursor_get_position()
            for x in xrange(0,self.g.state.cursor_x+1):
                self.g.state.cursor_absolute_x(x)
                self.g.write(0)
            for y in xrange(0,self.g.state.cursor_y-1):
                for x in xrange(0,self.g.state.width):
                    self.g.state.cursor_absolute(x,y)
                    self.g.write(0)
            self.g.state.cursor_absolute(cp[0],cp[1])
        if mode==0:
            cp=self.g.state.cursor_get_position()
            for x in xrange(self.g.state.cursor_x,self.g.state.width):
                self.g.state.cursor_absolute_x(x)
                self.g.write(0)

            for y in xrange(self.g.state.cursor_y+1,self.g.state.height):
                for x in xrange(0,self.g.state.width):
                    self.g.state.cursor_absolute(x,y)
                    self.g.write(0)

            self.g.state.cursor_absolute(cp[0],cp[1])

        if mode==2:
            self.g.screen.clear([self.g.state.foreground,self.g.state.background,0])

    cdef cmd_EL(self,mode):
        cp=self.g.state.cursor_get_position()
        #print ( "DEL",mode,cp)
        if mode==0:
            for x in xrange(self.g.state.cursor_x,self.g.state.width):
                self.g.state.cursor_absolute_x(x)
                self.g.write(0)
        elif mode==1:
            for x in xrange(0,self.g.state.cursor_x+1):
                self.g.state.cursor_absolute_x(x)
                self.g.write(0)
        elif mode==2:
            for x in xrange(0,self.g.state.width):
                self.g.state.cursor_absolute_x(x)
                self.g.write(0)
        self.g.state.cursor_absolute(cp[0],cp[1])

    cdef cmd_DCH(self,distance):
        cdef int x=self.g.state.cursor_x
        cdef int y=self.g.state.cursor_y
        cdef int width=self.g.state.width
        temp=[]
        cdef uint8_t[3] c=[0,0,0]
        #copy elements to buffer
        for x2 in xrange(x+distance,width):
            self.g.screen.get_pixel_3byte(x2,y,c)
            self.g.screen.put_pixel_3byte(x2-distance,y,c)

        # clear the end of the line
        for x2 in xrange(width-distance,width):
            c=[self.g.state.foreground,self.g.state.background,0]
            self.g.screen.put_pixel_3byte(x2,y,c)

    cdef cmd_ECH(self,distance):
        cp=self.g.state.cursor_get_position()
        for x in xrange(self.g.state.cursor_x,self.g.state.cursor_x+distance):
                self.g.state.cursor_absolute_x(x)
                self.g.write(0)
        self.g.state.cursor_absolute(cp[0],cp[1])
    
    cdef cmd_HVP(self,x,y):
        self.g.state.cursor_absolute(x,y)

    cdef cmd_HPA(self,x):
        self.g.state.cursor_absolute_x(x)

    cdef cmd_SCP(self):
        self.g.cursor_save_position()

    cdef cmd_RCP(self):
        self.g.cursor_restore_position()
   
    cdef cmd_VPA(self,position):
        self.g.state.cursor_absolute(0,position)

    cdef stream_2_sequence(self,text,timestamp,delay):
        # patterns for filtering out commands from the stream
        ANSI_SINGLE   ='[\033]([cDEHMZ78>=ijkl])' #ijkl arrow keys?
        ANSI_CHAR_SET = '[\033]\\%([@G*])'
        ANSI_G0       = '[\033]\\(([B0UK])'
        ANSI_G1       = '[\033]\\)([B0UK])'
        ANSI_CSI_RE   = '[\033]\\[((?:\\d|;|<|>|=|\?)*)([a-zA-Z])\002?'
        BRACKET_PASTE = '[\033]\\[(20[0-1]~)'
        # guessed on this one
        #ANSI_OSC_777_REGEX='[\0x1b|\033]\]777[;]([._:A-Za-z0-9\-\s]*)[;]([._:A-Za-z0-9\-\s]*)[;]([._:A-Za-z0-9\-\s]*)'
        ANSI_OSC ='(?:\033\\]|\x9d).*?(?:\033\\\\|[\a\x9c])'
        ESC_SEQUENCES=[ANSI_SINGLE,ANSI_CHAR_SET,ANSI_G0,ANSI_G1,ANSI_CSI_RE,ANSI_OSC,BRACKET_PASTE]
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
            #print groups
                
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
            elif groups[12]:
                esc_type='CSI'
                command=groups[12][-1]
                params=[int(groups[13][0:-1])]
                name="bracketed paste"
                self.add_command_sequence(esc_type,command,params,groups,name,timestamp,delay,text)
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
                    command='?'+command
                    param_tokens=paramstring[1:].split(';')
                    params=[int(part) for part in param_tokens]
                else:
                    try:
                        params = tuple(int(p) for p in paramstring.split(';') if len(p) != 0)
                        if len(params) == 0:
                            if command in 'JKm':
                                params = (0,)
                            elif command in 'ABCD':
                                params = (1,)
                    except Exception as ex:
                        continue
                self.add_command_sequence(esc_type,command,params,groups,name,timestamp,delay,text)
        
        
        if self.has_escape(text[cursor:]):
            self.extra_text=text[cursor:]
                
        else:
            self.extra_text=""
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
        text=[self.remap_character(i) for i in text]
        self.sequence.append({'type':'text','command':'text','data':text,'timestamp':timestamp,'delay':delay})

    cdef add_command_sequence(self,esc_type,command,params,groups,name,timestamp,delay,text=None):
        self.sequence.append({'type':'command','esc_type':esc_type,'command':command,'params':params,'groups':groups,'name':name,'timestamp':timestamp,'delay':delay,'data':text})

    cdef debug_sequence(self):
        print ("============")
        print ("Sequence List")
        print ("Count:{0}".format(len(self.sequence)))
        cdef int i=0
        
        for item in self.sequence:
            self.debug_event(item,i)
            i+=1
  

    cdef debug_event(self,event,index):
        commands=[
                    ['CSI','A' ,[1]   ,'CUU'             ],
                    ['CSI','B' ,[1]   ,'CUD'             ],
                    ['CSI','C' ,[1]   ,'CUF'             ],
                    ['CSI','D' ,[1]   ,'CUB'             ],
                    ['CSI','E' ,[1]   ,'CNL'             ],
                    ['CSI','F' ,[1]   ,'CPL'             ],
                    ['CSI','G' ,[3]   ,'CHA'             ],
                    ['CSI','H' ,[3,4] ,'CUP'             ],
                    ['CSI','J' ,[1]   ,'ED'              ],
                    ['CSI','K' ,[1]   ,'EL'              ],
                    ['CSI','P' ,[1]   ,'DCH'             ],
                    ['CSI','X' ,[1]   ,'ECH'             ],
                    ['CSI','d' ,[3,]  ,'VPA'             ],
                    ['CSI','f' ,[3,4] ,'HVP'             ],
                    ['CSI','h' ,[1]   ,'set_mode'        ],
                    ['CSI','l' ,[1]   ,'reset_mode'      ],
                    ['CSI','m' ,[1]   ,'COL'  ],
                    ['CSI','r' ,[3,4] ,'DECSTBM'         ],
                    ['CSI','s' ,[0]   ,'SCP'             ],
                    ['CSI','u' ,[0]   ,'RCP'             ],
                    ['CSI','`' ,[3]   ,'HPA'             ],
                    ['CSI','~' ,[1]   ,'BRACKETED_PASTE' ],
                    ['CSI','?h',[1]   ,'DECSET'          ],
                    ['CSI','?l',[1]   ,'DECRST'          ],
            ]
        if event['type']=='text':
            print("{2<5} {3:3.5f} : text('{0},{1}')".format(self.ascii_escaped(event['data']),len(event['data']),index, event['timestamp'] ) )
            return
        for cmd in commands:
            if cmd[1]==event['command'] and event['esc_type']==cmd[0]:
                param=[]
                for i in cmd[2]:
                    
                    if i==0: param.append( "" )
                    
                    if i==1: 
                        if len(event['params'])>=1:
                            param.append( "{0}".format(event['params'][0])   ) 
                        else: 
                            param.append( "ERR" )
                    if i==2: 
                        if len(event['params'])>=2:
                            param.append( "{0}".format(event['params'][1])   ) 
                        else: 
                            param.append( "ERR" )
                    if i==3: 
                        if len(event['params'])>=1:
                            param.append( "{0}".format(event['params'][0]-1) ) 
                        else: 
                            param.append( "ERR" )
                    if i==4: 
                        if len(event['params'])>=2:
                            param.append( "{0}".format(event['params'][1]-1) ) 
                        else: 
                            param.append( "ERR" )

                print("{2: 6x} {3:3.5f} : {0}({1})".format(cmd[3],",".join(param),index,event['timestamp']))
                return
                

        print("{5:05x} CMD:  '{0}', Name:'{3}', Command:{1}, Params:{2}  Timestamp:{4}".format(event['esc_type'],
                                            event['command'],
                                            event['params'],
                                            event['name'],
                                            event['timestamp'],index))



 #    x  A   CUU       Move cursor up the indicated # of rows.
        #    x  B   CUD       Move cursor down the indicated # of rows.
        #    x  C   CUF       Move cursor right the indicated # of columns.
        #    x  D   CUB       Move cursor left the indicated # of columns.
        #    x  E   CNL       Move cursor down the indicated # of rows, to column 1.
        #    x  F   CPL       Move cursor up the indicated # of rows, to column 1.
        #    x  G   CHA       Move cursor to indicated column in current row.
        #    x  H   CUP       Move cursor to the indicated row, column (origin at 1,1).
        #    x  J   ED        Erase display (default: from cursor to end of display).
        #    x                ESC [ 1 J: erase from start to cursor.
        #    x                ESC [ 2 J: erase whole display.
        #    x                ESC [ 3 J: erase whole display including scroll-back
        #    x                           buffer (since Linux 3.0).
        #    x  K   EL        Erase line (default: from cursor to end of line).
        #    x                ESC [ 1 K: erase from start of line to cursor.
        #    x                ESC [ 2 K: erase whole line.
        #    x  L   IL        Insert the indicated # of blank lines.
        #    x  P   DCH       Delete the indicated # of characters on current line.
        #    x  X   ECH       Erase the indicated # of characters on current line.
        #    x  d   VPA       Move cursor to the indicated row, current column.
        #    x  f   HVP       Move cursor to the indicated row, column.
        #    y  h   SM        Set Mode (see below).
        #    y  l   RM        Reset Mode (see below).
        #    x  m   SGR       Set attributes (see below).
        #    x  `   HPA       Move cursor to indicated column in current row.
        #    x  s   ?         Save cursor location.
        #    x  u   ?         Restore cursor location.
        #       @   ICH       Insert the indicated # of blank characters.
        #       M   DL        Delete the indicated # of lines.
        #       a   HPR       Move cursor right the indicated # of columns.
        #       c   DA        Answer ESC [ ? 6 c: "I am a VT102".
        #       e   VPR       Move cursor down the indicated # of rows.
        #       g   TBC       Without parameter: clear tab stop at current position.
        #                     ESC [ 3 g: delete all tab stops.
        #       n   DSR       Status report (see below).
        #       q   DECLL     Set keyboard LEDs.
        #                     ESC [ 0 q: clear all LEDs
        #                     ESC [ 1 q: set Scroll Lock LED
        #                     ESC [ 2 q: set Num Lock LED
        #                     ESC [ 3 q: set Caps Lock LED
        #       r   DECSTBM   Set scrolling region; parameters are top and bottom row.

# CSI ? 25 h	DECTCEM Shows the cursor, from the VT320.
# CSI ? 25 l	DECTCEM Hides the cursor.
# CSI ? 1049 h	Enable alternative screen buffer
# CSI ? 1049 l	Disable alternative screen buffer
# CSI ? 2004 h	Turn on bracketed paste mode. Text pasted into the terminal will be surrounded by ESC [200~ and ESC [201~, and characters in it should not be treated as commands (for example in Vim).[20] From Unix terminal emulators.
# CSI ? 2004 l	Turn off bracketed paste mode.