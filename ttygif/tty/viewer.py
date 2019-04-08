from .fonts import font

class viewer:
    # TODO Fix self... on font
    # create loader from gif...
    # save byt3stream into file manually
    # load bytestream
    # automate this with a funciton

    def __init__(self,width=640,height=480,char_width=None,char_height=None,stream=''):
        if char_width:
            width=char_width*font['font_width']
        if char_height:
            height=char_height*font['font_height']

        self.width=width
        self.height=height
        
        self.stream=stream
        self.background_color=0
        self.foreground_color=3
        self.window="BOTTOM"
        self.color_table=[
                        [0,0,0],
                        [170,0,0],
                        [0,170,0],
                        [170,85,0],
                        [0,0,170],
                        [170,0,170],
                        [0,170,170],
                        [170,170,170],
                        [85,85,85],
                        [255,85,85],
                        [85,255,85],
                        [255,255,85],
                        [85,85,255],
                        [255,85,255],
                        [85,255,255],
                        [255,255,255]
                        ]
        self.video=[]
        self.video_length=len(self.video)
        # SET DEFAULTS
        self.fg=0
        self.bg=0
        self.reset=0
        self.attribs=0


    def do_escape_code(self,character):
        #ATTRIBS
      
        o=""
        return o

    def is_escape_code(self,character):
        escape_codes=[1,2,4,5,7,8,0,21,22,24,25,27,28,39,30,31,32,33,
        34,35,36,37,90,91,92,93,94,95,96,97,49,40,41,42,
        43,44,45,46,47,100,101,102,103,104,105,106,107]

        
        #if character!=0:
        #    print ord(character)
        
        if character in escape_codes:
            return True
        return None

    # only level 1 optomised for reduced calculations in inner loops
    # TODO: runtime calculation
    def draw_character(self,character,x,y,offset,color):
        
        #print character
        if isinstance(character,int):
            return
        char_index=ord(character)
        if char_index>255:
           # print ("Missing character")
            return

        #print "FOUND"
        fs=font['width']
        fw=font['font_width']
        fh=font['font_height']
        fox=font['offset_x']
        foy=font['offset_y']
        fsx=font['spacing_x']
        fsy=font['spacing_y']
        transparent=font['transparent']
        cx=int(char_index%font['chars_per_line'])
        cy=int(char_index/font['chars_per_line'])

        pre_x=fox+cx*fw
        pre_y=(foy+cy*fh)*fs
        pre=pre_x+pre_y
        pre_y2=0
        for fy in range(0,fh): 
            sy=fy+(y*(fh+fsy))
            sx=(x*(fw+fsx))
            screen_pos=sx+(sy-offset)*self.width
            if screen_pos<0 or screen_pos>=self.video_length:
                continue
            pos=pre+pre_y2
            for fx in range(0,fw):
                screen_pos2=screen_pos+fx
                if screen_pos2<0 or screen_pos2>=self.video_length:
                    continue
                pos2=pos+fx
                pixel=font['data'][pos2]
                if pixel!=transparent:
                    self.video[screen_pos2]=color/0xF
                else:
                    self.video[screen_pos2]=pixel
            pre_y2+=fs
            

    def clear_screen(self,character,color):
        self.screen=[color]*self.buffer_len*font['font_height']*font['font_width']

    def get_buffer_height(self):
        #print self.buffer_rows,"ROWS"
        height=self.buffer_rows*font['font_height']
        return height

    # todo save as gif..
    # pre test with canvas extension    
    def render(self):
        self.stream_to_buffer()
        #self.clear_screen(self.bg,255) x
        self.video=[self.background_color]*(self.width*self.height)
        self.video_length=len(self.video)

        
        buffer_height=self.get_buffer_height()
        if self.window=="BOTTOM":
            if  buffer_height<=self.height:
                offset=0
            else:
                offset=buffer_height-self.height

        if self.window=="TOP":
            offset=0

        #print offset,buffer_height
        for index  in range(0,self.buffer_len,2):
            x=(index/2%self.window_width)
            y=index/2/self.window_width
            if (y+1)*font['font_height']<offset:
                continue
            color=self.buffer[index]
            character=self.buffer[index+1]
           # print character
            if self.is_escape_code(character):
            #    print ("ESCAPE")
                self.do_escape_code(character)
            else:
             #   print "NOT"
                self.draw_character(character,x,y,offset,color)
    
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
        #print window_width,self.width,font['width']
        row=0
        mode=None
        mode_index=0
        CSI={}
                        
        fg=0
        bg=0

        for i in self.stream:
            oi=ord(i)
            if mode=='ESCAPE':
                #print i
                mode_index+=1
                if mode_index==1 and oi!=ord('['):
                    mode=None
                    mode_index=0
                    continue
                if mode_index==1 and oi==ord('['):
                    #print "CSI"
                    CSI={}
                    CSI['primary']=''
                    CSI['intermediate']=''
                    CSI['final']=''
                    continue

                if oi >=0x30 and oi<=0x3F:
                    #print "P"
                    CSI['primary']+=i
                elif oi >=0x20 and oi<=0x2F:
                    #print "I"
                    CSI['intermediate']+=i
                elif oi >=0x40 and oi<=0x7F:
                    #print "F"
                    CSI['final']+=i
                    mode=None
                else:
                    #print "DONE"
                    mode=None
                continue
            if 27==ord(i):
                mode='ESCAPE'
                mode_index=0
                continue
            if i=='\r':
                continue
            
            if i=='\n':
                if overflow==None:
                    row+=1
                    #print ("O")
                    pos+=window_width*2-px*2
                    buffer+=[0]*(window_width*2)
                    px=0
            else:
                if 'primary' in CSI:
                    parts=CSI['primary'].split(';')
                    pm=None
                    #print CSI['primary']
                    if len(parts)>0:
                        for part in parts:
                            #print part
                            if pm=='bg':
                                bg=self.color_lookup(part)
                                pm=None
                            elif pm=='fg':
                                fg=self.color_lookup(part)
                                pm=None

                            if part=='38':
                                pm='fg'
                            elif part=='48':
                                pm='bg'
                            else:
                                pm=None
                                color=part
                                if   color=='30':
                                    fg=0
                                elif color=='31':
                                    fg=1
                                elif color=='32':
                                    fg=2
                                elif color=='33':
                                    fg=3
                                elif color=='34':
                                    fg=4
                                elif color=='35':
                                    fg=5
                                elif color=='36':
                                    fg=6
                                elif color=='37':
                                    fg=7
                                elif color=='90':
                                    fg=8
                                elif color=='91':
                                    fg=9
                                elif color=='92':
                                    fg=10
                                elif color=='93':
                                    fg=11
                                elif color=='94':
                                    fg=12
                                elif color=='95':
                                    fg=13
                                elif color=='96':
                                    fg=14
                                elif color=='97':
                                    fg=15
                                elif color=='40' :
                                    bg=0
                                elif color=='41' :
                                    bg=1
                                elif color=='42' :
                                    bg=2
                                elif color=='43' :
                                    bg=3
                                elif color=='44' :
                                    bg=4
                                elif color=='45' :
                                    bg=5
                                elif color=='46' :
                                    bg=6
                                elif color=='47' :
                                    bg=7
                                elif color=='100':
                                    bg=8
                                elif color=='101':
                                    bg=9
                                elif color=='102':
                                    bg=10
                                elif color=='103':
                                    bg=11
                                elif color=='104':
                                    bg=12
                                elif color=='105':
                                    bg=13
                                elif color=='106':
                                    bg=14
                                elif color=='107':
                                    bg=15
                                                        

                
                fg=2
                bg=4
                color=fg*0xF+bg
                #print("{0:02X},{1:02X},{2:02X}".format(color,fg,bg))
                buffer[pos]=color
                buffer[pos+1]=i
                px+=1
                pos+=2
                overflow=None
                if px==window_width:
                    row+=1
                    overflow=True    
                    #print ("WHAT")
                    buffer+=[0]*(window_width*2)
                    px=0
    
        self.buffer=buffer
        self.buffer_len=len(buffer)
        self.buffer_rows=row
        #print buffer
    
    def color_lookup(self,color):
        #print color
        if   color=='30'	or color=='40':	   #Black	        30	40	0,0,0	12,12,12	0,0,0	1,1,1
            return 0
        elif color=='31'	or color=='41':	   #Red	        31	41	170,0,0	128,0,0	197,15,31	194,54,33	187,0,0	127,0,0	205,0,0	255,0,0	222,56,43
            return 1
        elif color=='32'	or color=='42':	   #Green	        32	42	0,170,0	0,128,0	19,161,14	37,188,36	0,187,0	0,147,0	0,205,0	0,255,0	57,181,74
            return 2
        elif color=='33'	or color=='43':	   #Yellow	        33	43	170,85,0[nb 8]	128,128,0	238,237,240	193,156,0	173,173,39	187,187,0	252,127,0	205,205,0	255,255,0	255,199,6
            return 3
        elif color=='34'	or color=='44':	   #Blue	        34	44	0,0,170	0,0,128	0,55,218	73,46,225	0,0,187	0,0,127	0,0,238[23]	0,0,255	0,111,184            return 1
            return 4
        elif color=='35'	or color=='45':	   #Magenta	    35	45	170,0,170	128,0,128	1,36,86	136,23,152	211,56,211	187,0,187	156,0,156	205,0,205	255,0,255	118,38,113
            return 5
        elif color=='36'	or color=='46':	   #Cyan	        36	46	0,170,170	0,128,128	58,150,221	51,187,200	0,187,187	0,147,147	0,205,205	0,255,255	44,181,233
            return 6
        elif color=='37'	or color=='47':	   #White	        37	47	170,170,170	192,192,192	204,204,204	203,204,205	187,187,187	210,210,210	229,229,229	255,255,255	204,204,204
            return 7
        elif color=='90'	or color=='100':   #Bright Black	90	100	85,85,85	128,128,128	118,118,118	129,131,131	85,85,85	127,127,127	127,127,127		128,128,128
            return 8
        elif color=='101'	or color=='25':    #Bright Red	91	101	255,85,85	255,0,0	231,72,86	252,57,31	255,85,85	255,0,0	255,0,0		255,0,0
            return 9
        elif color=='92'	or color=='102':   #Bright Green	92	102	85,255,85	0,255,0	22,198,12	49,231,34	85,255,85	0,252,0	0,255,0	144,238,144	0,255,0
            return 10
        elif color=='93'	or color=='103':   #Bright Yellow	93	103	255,255,85	255,255,0	249,241,165	234,236,35	255,255,85	255,255,0	255,255,0	255,255,224	255,255,0
            return 11
        elif color=='94'	or color=='104':   #Bright Blue	94	104	85,85,255	0,0,255	59,120,255	88,51,255	85,85,255	0,0,252	92,92,255[24]	173,216,230	0,0,255
            return 12
        elif color=='95'	or color=='105':   #Bright Magenta	95	105	255,85,255	255,0,255	180,0,158	249,53,248	255,85,255	255,0,255	255,0,255		255,0,255
            return 13
        elif color=='96'	or color=='106':   #Bright Cyan	96	106	85,255,255	0,255,255	97,214,214	20,240,240	85,255,255	0,255,255	0,255,255	224,255,255	0,255,255
            return 14
        elif color=='97'	or color=='107':   #Bright White	97	107
            return 15
        return 0

    def get(self):
        return {'width':self.width,'height':self.height,'data':self.video,'color_table':self.color_table}

    def add_event(self,event):
        timestamp=event[0]
        event_type=event[1]
        event_io=event[2]
        self.stream+=event_io

    def save_screen(self):
        # todo save as gif..
        # pre test with canvas extension
        x=1




#  query: "name"
#  arguments: optional, 1 or 0 for unlimited (comma seperated)
#  switch: signatures to match against 
#     data: optional
#          vars: variabls to manually set
#          sig: signature to match, {viariable} places any data in that position into that variable, [ ] makes it an array plain strings are dropped
#     name: initial string to match against to enter this query, this is the index of the object
#   optional: can we skip this
#   depends_on: do not match unless the other variable is present 
#   jump: goto an ealier command for matching, to repeat a loop set for multiple matches
#   parent: override the name, and place data on this index
#   store_array: allow multiple keys in an array at this index
#   specs :{'variable_name': {'type': 'int', 'default': 0} },




