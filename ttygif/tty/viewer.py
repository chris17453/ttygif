from .fonts import font

class viewer:
    # TODO Fix self... on font
    # create loader from gif...
    # save byt3stream into file manually
    # load bytestream
    # automate this with a funciton

    def __init__(self,width,height,stream):
        self.width=width
        self.height=height
        self.stream=stream
        self.color_table=[
                        [0,0,0],
                        [255,255,255],
                        [255,0,0],
                        [0,255,0],
                        [0,0,255],
                        [255,255,0],
                        [0,255,255],
                        [255,0,255],
                        [192,192,192],
                        [128,128,128],
                        [128,0,0],
                        [128,128,0],
                        [0,128,0],
                        [128,0,128],
                        [0,128,128],
                        [0,0,128]
                        ]

        # SET DEFAULTS
        self.fg=0
        self.bg=0
        self.reset=0
        self.attribs=0
        self.colors={}
        self.fg={}
        self.bg={}
        self.reset={}
        self.colors['FG_BLACK']=0
        self.colors['FG_RED']=1
        self.colors['FG_GREEN']=2
        self.colors['FG_YELLOW']=3
        self.colors['FG_BLUE']=4
        self.colors['FG_MAGENTA']=5
        self.colors['FG_CYAN']=6
        self.colors['FG_LIGHT_GRAY']=7
        self.colors['FG_DARK_GRAY']=8
        self.colors['FG_LIGHT_RED']=9
        self.colors['FG_LIGHT_GREEN']=10
        self.colors['FG_LIGHT_YELLOW']=11
        self.colors['FG_LIGHT_BLUE']=12
        self.colors['FG_LIGHT_MAGENTA']=13
        self.colors['FG_LIGHT_CYAN']=14
        self.colors['FG_WHITE']=15
        self.colors['BG_BLACK']=0
        self.colors['BG_RED']=1
        self.colors['BG_GREEN']=2
        self.colors['BG_YELLOW']=3
        self.colors['BG_BLUE']=4
        self.colors['BG_MAGENTA']=5
        self.colors['BG_CYAN']=6
        self.colors['BG_LIGHT_GRAY']=7
        self.colors['BG_DARK_GRAY']=8
        self.colors['BG_LIGHT_RED']=9
        self.colors['BG_LIGHT_GREEN']=10
        self.colors['BG_LIGHT_YELLOW']=11
        self.colors['BG_LIGHT_BLUE']=12
        self.colors['BG_LIGHT_MAGENTA']=13
        self.colors['BG_LIGHT_CYAN']=14
        self.colors['BG_WHITE']=15
        self.colors['BOLD']='A'
        self.colors['DIM']='B'
        self.colors['UNDERLINED']='C'
        self.colors['BLINK']='D'
        self.colors['REVERSE']='E'
        self.colors['HIDDEN']='F'
        self.colors['ALL']='G'
        self.colors['BOLD']='H'
        self.colors['DIM']='I'
        self.colors['UNDERLINED']='K'
        self.colors['BLINK']='L'
        self.colors['REVERSE']='M'
        self.colors['HIDDEN']='N'
        self.colors['DEFAULT']='O'

    def do_escape_code(self,character):
        #ATTRIBS
        if character== 1: 
            self.attribs=self.colors['BOLD']
        elif character== 2: 
            self.attribs=self.colors['DIM']
        elif character== 4: 
            self.attribs=self.colors['UNDERLINED']
        elif character== 5: 
            self.attribs=self.colors['BLINK']
        elif character== 7: 
            self.reset=self.colors['REVERSE']
        elif character== 8: 
            self.reset=self.colors['HIDDEN']
        # RESET
        elif character== 0: 
            self.reset=self.colors['ALL']
        elif character== 21:
            self.reset=self.colors['BOLD']
        elif character== 22:
            self.reset=self.colors['DIM']
        elif character== 24:
            self.reset=self.colors['UNDERLINED']
        elif character== 25:
            self.reset=self.colors['BLINK']
        elif character== 27:
            self.reset=self.colors['REVERSE']
        elif character== 28:
            self.reset=self.colors['HIDDEN']
        elif character== 39:
            self.reset=self.colors['DEFAULT']
         #FG
        elif character== 30: 
            self.fg=self.colors['FG_BLACK']
        elif character== 31: 
            self.fg=self.colors['FG_RED']
        elif character== 32: 
            self.fg=self.colors['FG_GREEN']
        elif character== 33: 
            self.fg=self.colors['FG_YELLOW']
        elif character== 34: 
            self.fg=self.colors['FG_BLUE']
        elif character== 35: 
            self.fg=self.colors['FG_MAGENTA']
        elif character== 36: 
            self.fg=self.colors['FG_CYAN']
        elif character== 37: 
            self.fg=self.colors['FG_LIGHT_GRAY']
        elif character== 90: 
            self.fg=self.colors['FG_DARK_GRAY']
        elif character== 91: 
            self.fg=self.colors['FG_LIGHT_RED']
        elif character== 92: 
            self.fg=self.colors['FG_LIGHT_GREEN']
        elif character== 93: 
            self.fg=self.colors['FG_LIGHT_YELLOW']
        elif character== 94: 
            self.fg=self.colors['FG_LIGHT_BLUE']
        elif character== 95: 
            self.fg=self.colors['FG_LIGHT_MAGENTA']
        elif character== 96: 
            self.fg=self.colors['FG_LIGHT_CYAN']
        elif character== 97: 
            self.fg=self.colors['FG_WHITE']
        elif character== 49: 
            self.fg=self.colors['FG_DEFAULT']
        #BG
        elif character==40:
            this.bg=self.colors['BG_BLACK']
        elif character==41:
            this.bg=self.colors['BG_RED']
        elif character==42:
            this.bg=self.colors['BG_GREEN']
        elif character==43:
            this.bg=self.colors['BG_YELLOW']
        elif character==44:
            this.bg=self.colors['BG_BLUE']
        elif character==45:
            this.bg=self.colors['BG_MAGENTA']
        elif character==46:
            this.bg=self.colors['BG_CYAN']
        elif character==47:
            this.bg=self.colors['BG_LIGHT_GRAY']
        elif character==100:
            this.bg=self.colors['BG_DARK_GRAY']
        elif character==101:
            this.bg=self.colors['BG_LIGHT_RED']
        elif character==102:
            this.bg=self.colors['BG_LIGHT_GREEN']
        elif character==103:
            this.bg=self.colors['BG_LIGHT_YELLOW']
        elif character==104:
            this.bg=self.colors['BG_LIGHT_BLUE']
        elif character==105:
            this.bg=self.colors['BG_LIGHT_MAGENTA']
        elif character==106:
            this.bg=self.colors['BG_LIGHT_CYAN']
        elif character==107:
            this.bg=self.colors['BG_WHITE']
        o=""
        return o

    def is_escape_code(self,character):
        escape_codes=[1,2,4,5,7,8,0,21,22,24,25,27,28,39,30,31,32,33,
        34,35,36,37,90,91,92,93,94,95,96,97,49,40,41,42,
        43,44,45,46,47,100,101,102,103,104,105,106,107]

        if character in escape_codes:
            return True
        return None

    def draw_character(self,character,x,y):
        
        if isinstance(character,int):
            return
        char_index=ord(character)
        #print "FOUND"
        
        cx=char_index%font['chars_per_line']
        cy=char_index/font['chars_per_line']
        for fy in range(0,font['font_height']):
            for fx in range(0,font['font_width']):
                pos=fx+font['offset_x']+cx*font['font_width']
                pos+=(fy+font['offset_y']+cy*font['font_height'])*font['width']
                pixel=font['data'][pos]
                sx=fx+(x*(font['font_width']+font['spacing_x']))
                sy=fy+(y*(font['font_height']+font['spacing_y']))
                screen_pos=sx+sy*self.width
               # print sx,sy,pixel
                if pixel!=0:
                    self.video[screen_pos]=pixel
                else:
                    self.video[screen_pos]=pixel

    def clear_screen(self,character,color):
        self.screen=[color]*self.buffer_len*font['font_height']*font['font_width']

    def get_buffer_height(self):
        height=self.buffer_rows*font['height']

    # todo save as gif..
    # pre test with canvas extension    
    def render(self):
        self.stream_to_buffer()
        #self.clear_screen(self.bg,255) x
        self.video=[1]*(self.width*self.height)
        
        buffer_height=self.get_buffer_height()
        if  buffer_height<=self.height:
            offset=0
        else:
            offset=buffer_height-self.height
 
        for index  in range(0,self.buffer_len,2):
            x=(index/2%self.window_width)
            y=index/2/self.window_width+offset
            if x+font['font_width']<0:
                continue
            if y+font['font_height']<0:
                continue
            if x>=self.width:
                continue
            if y>=self.height:
                continue
            
            color=self.buffer[index]
            character=self.buffer[index+1]
           # print character
            if self.is_escape_code(character):
            #    print ("ESCAPE")
                self.do_escape_code(character)
            else:
             #   print "NOT"
                self.draw_character(character,x,y)
    
    # convert the text stream to a text formated grid
    def stream_to_buffer(self):
        window_width=self.width/font['font_width']
        window_height=self.height/font['font_height']
        self.window_height=window_height
        self.window_width=window_width
        px=0
        color=0xFF
        pos=0
        buffer=[0]*(window_width*2)
        #print buffer
        ##print len(buffer)
        overflow=None
        print window_width,self.width,font['width']
        for i in self.stream:
            
            if i=='\n':
                if overflow==None:
                    print ("O")
                    pos+=window_width*2-px*2
                    buffer+=[0]*(window_width*2)
                    px=0
            else:
                buffer[pos]=color
                buffer[pos+1]=i
                px+=1
                pos+=2
                overflow=None
                if px==window_width:
                    overflow=True    
                    print ("WHAT")
                    buffer+=[0]*(window_width*2)
                    px=0

    
        self.buffer=buffer
        self.buffer_len=len(buffer)
        self.buffer_rows=len(buffer)
        #print buffer

    def get(self):
        return {'width':self.width,'height':self.height,'data':self.video,'color_table':self.color_table}










    def save_screen(self):
        # todo save as gif..
        # pre test with canvas extension
        x=1