# cython: profile=True
# cython: binding=True
# cython: language_level=2

import sys
from cpython cimport array
from libc.string cimport  memcpy
from .gif.encode import encode_gif
from .gif.decode import decode
from .asciicast.reader import asciicast_reader
from .tty.terminal_emulator cimport terminal_emulator


cdef class cast2gif:
    cdef object debug
    cdef object cast_file
    cdef object gif_file
    cdef object natural
    cdef object loop_count
    cdef object loop_delay
    cdef object frame_rate
    cdef object width
    cdef object height
    cdef double interval
    cdef object event_length
    cdef double percent
    cdef double old_percent
    cdef object dilation 
    cdef object minimal_interval
    cdef object underlay
    cdef int    underlay_x1
    cdef int    underlay_y1
    cdef int    underlay_x2
    cdef int    underlay_y2
    cdef int    underlay_mode
    cdef int    underlay_frame
    cdef int    last_event
    cdef object font_name
    cdef object theme_name
    cdef object show_state
    cdef object debug_gif
    
    
    
    # last frame created timestamp
    cdef double timestamp 
    # last timestamp in file
    cdef double last_timestamp 
    # where we are in TOTAL with delays
    cdef double aggregate_timestamp
    cdef object stream 

    cdef ascii_safe(self,text):
        return ''.join([i if ord(i) < 128 else '*' for i in text])

    cdef info(self,text):
        if self.debug:
            print(self.ascii_safe(text))

    cdef get_frame_bounding_diff(self,array.array frame1,array.array frame2,int width,int height):
        if frame1==None or frame2==None:
            return {'min_x':0,'min_y':0,'max_x':width-1,'max_y':height-1,'width':width,'height':height}
        cdef int pos=0
        cdef int min_x=width
        cdef int min_y=height
        cdef int max_x=0
        cdef int max_y=0
        cdef same=1
        cdef int x
        cdef int y
        for y in xrange(0,height):
            for x in xrange(0,width):
                if frame1[pos]!=frame2[pos]:
                    same=0
                    if x<min_x:
                        min_x=x
                    if x>max_x:
                        max_x=x
                    if y<min_y:
                        min_y=y
                    if y>max_y:
                        max_y=y
                pos+=1
        # it didnt change...
        # place holder so delat is kept same same
        if same==1:
            min_x=0
            min_y=0
            max_x=2
            max_y=2
            #return None

        cdef int bound_height=max_y-min_y+1
        cdef int bound_width =max_x-min_x+1
        return {'min_x':min_x,'min_y':min_y,'max_x':max_x,'max_y':max_y,'width':bound_width,'height':bound_height}

    def get_delay(self,event_index):
        delay=0
        if event_index==len(self.stream['events'])-1:
            #print loop_delay,1
            if self.loop_delay==None:
                self.loop_delay=100
            delay=self.loop_delay 
            new_frame=True
        else:
            if self.frame_rate==0:
                #print self.stream['events'][event_index+1][0],self.stream['events'][event_index][0]
                delay=int((self.stream['events'][event_index+1][0]-self.stream['events'][event_index][0])*100)
            else:
                delay=0
        return delay

    def show_percent(self,index):
        self.old_percent=self.percent
        self.percent=int((index*100)/self.event_length)
        if self.percent!=self.old_percent:
            if self.natural:
                sys.stdout.write("  {0} of {1} Seconds {2}% Frame: {3}                       \r".format(round(self.timestamp,2),round(self.last_timestamp,2),round(self.percent,2),index))
            else:
                sys.stdout.write("  {0} of {1} Seconds {2}% Frame: {3} {4} FPS ({5}ms)       \r".format(round(self.timestamp,2),round(self.last_timestamp,2),round(self.percent,2),index,self.frame_rate,round(self.interval,2)))
            sys.stdout.flush()    

    def update_timestamps(self):
        for i in xrange(0,len(self.stream['events'])):
            self.stream['events'][i][0]=float(self.stream['events'][i][0])*self.dilation

    def __init__(self,cast_file,gif_file,last_event=0,trailer=None,events=None,dilation=1,loop_count=0xFFFF,frame_rate=100,loop_delay=1000,natural=None,
                 debug=None,width=None,height=None,underlay=None,font_name=None,theme_name=None,
                 debug_gif=None,
                 show_state=None):
        self.dilation=dilation
        self.cast_file= cast_file
        self.gif_file= gif_file
        self.loop_count= loop_count
        self.frame_rate= frame_rate
        self.loop_delay= loop_delay
        self.natural= natural
        self.debug= debug
        self.width= width
        self.height= height
        self.show_state=show_state
        self.percent=-1
        self.timestamp=0
        self.aggregate_timestamp=0
        self.minimal_interval=.03
        self.font_name=font_name
        self.theme_name=theme_name
        self.last_event=last_event
        self.debug_gif=debug_gif

        if underlay:
            underlay_image=decode(underlay)
            self.underlay=underlay_image.get()

        print(" - dilation: {0}".format(self.dilation))
        if None==events:
            print (" - input: {0}".format(cast_file))
        else:
            print (" - input: stdin (pipe)")
        print (" - output: {0}".format(gif_file))
        cast=asciicast_reader(debug=debug)
        if events:
            self.stream=events
        else:
            self.stream=cast.load(cast_file)


        self.update_timestamps()
        self.event_length=len(self.stream['events'])

        if self.event_length<1:
            print("Empty stream")
            exit(0) 

        self.last_timestamp=float(self.stream['events'][self.event_length-1][0])
        self.timestamp=float(self.stream['events'][0][0])
        if self.width==None:
            self.width=self.stream['width']
        if self.height==None:
            self.height=self.stream['height']

        if self.last_event!=0:
            print (" - last event: {0}".format(self.last_event))
        
        self.encode_stream()
    
    
    def encode_stream(self):
        g=encode_gif(self.loop_count,debug=self.debug_gif)
        

        v=terminal_emulator(char_width=self.width,char_height=self.height,font_name=self.font_name,theme_name=self.theme_name,debug=self.debug,last_event=self.last_event,show_state=self.show_state)
        dim=v.get_dimentions()
        print (" - character dimensions: {0}x{1}".format(self.width,self.height))
        print (" - pixel dimensions: {0}x{1}".format(dim.width,dim.height))

        g.create(width=dim.width,height=dim.height,filename=self.gif_file,palette=v.terminal_graphics.theme.palette)

        
        print("\n");


        index=0
        frame=0
        data=None
        old_data=None
        new_frame=None
        self.aggregate_timestamp=0
        text=""


        seconds=self.stream['events'][-1][0]
        frames=int(seconds*self.frame_rate)
        print("Frames Rate: {0}".format(self.frame_rate))
        print("Frames: {0}".format(frames))
        print("Seconds: {0}".format(seconds))
        
        # add attribute of status to event array
        for event in self.stream['events']:
            event.append(0)

        for i in range(frames):
            curent_time=1/self.frame_rate*i;
            self.show_percent(curent_time)


            for event in self.stream['events']:
                # skip rendered rows .. ok for static backgrounds
                if event[3]==1:
                    continue;
                event[3]=1
                # skip events that havnt happened
                if event[0]<curent_time:
                    v.add_event(event)

            # add any leftover text from the end of the blah blah i dont know what i did
            if i==self.event_length-1:
                v.last_frame()


            #millasecnds 1000 per second
            delay=int(100/self.frame_rate)
            
            frame+=1
            

            # loop the frames if the delay is bigger than 65.535 seconds =0xFFFF
            add_frames=True
            while add_frames:
                if delay>0xFFFF:
                    partial_delay=0xFFFF
                else:
                    partial_delay=delay
                delay-=partial_delay
                if delay==0:
                    add_frames=None

                #v.render_underlay(self.underlay,0)
                v.render()
            
                old_data=data
                data=v.get()
                #old_data=None
                if None==old_data:
                    diff={'min_x':0,'min_y':0,'max_x':dim.width-1,'max_y':dim.height-1,'width':dim.width,'height':dim.height}
                else:
                    diff=self.get_frame_bounding_diff(old_data['data'],data['data'],dim.width,dim.height)
            
                if diff:
                    frame_snip=self.copy_area(data['data'],diff,dim.width,dim.height)


                    # add the freame to the gif
                    g.add_frame(    disposal_method=0,
                                    delay=partial_delay, 
                                    transparent=None,
                                    left=diff['min_x'],
                                    top=diff['min_y'],
                                    width=diff['width'],
                                    height=diff['height'],
                                    palette=None,
                                    image_data=frame_snip)

                    self.aggregate_timestamp+=partial_delay

                #self.timestamp=cur_timestamp
            #self.show_percent(index)
        if self.debug:
            v.debug_sequence()
        g.close()
        #print ("Total:",self.aggregate_timestamp)
        print("\n")
        

    # super fast memory copy
    cdef copy_area(self,array.array data,diff,int width,int height):
        cdef int pos=0
        cdef int new_data_len=diff['width']*diff['height']
        cdef int y_offset
        cdef array.array dest_frame=array.array('B')
        array.resize(dest_frame,new_data_len)


        cdef int data_pos
        cdef int dest_frame_po
        cdef void *src=data.data.as_voidptr
        for y in xrange(diff['min_y'],diff['max_y']+1):
            data_pos= y*width+diff['min_x']
            dest_frame_pos= (y-diff['min_y'])*diff['width']
            memcpy(
                    &dest_frame.data.as_uchars[dest_frame_pos], 
                    &data.data.as_uchars[data_pos],
                    diff['width'])
        
        return dest_frame
