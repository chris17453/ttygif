# cython: linetrace=True
import sys
from cpython cimport array
import array
from libc.string cimport  memcpy
from .gif.encode import encode_gif
from .gif.decode import decode
from .asciicast.reader import asciicast_reader
from .tty.viewer import viewer


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
    cdef int underlay_x1
    cdef int underlay_y1
    cdef int underlay_x2
    cdef int underlay_y2
    cdef int underlay_mode
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

    def get_frame_bounding_diff(self,frame1,frame2,int width,int height):
        if frame1==None or frame2==None:
            return {'min_x':0,'min_y':0,'max_x':width-1,'max_y':height-1,'width':width,'height':height}
        cdef int pos=0
        cdef int min_x=width
        cdef int min_y=height
        cdef int max_x=0
        cdef int max_y=0
        cdef same=1
        for y in range(0,height):
            for x in range(0,width):
                if frame1['data'][pos]!=frame2['data'][pos]:
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
                sys.stdout.write(" {0} of {1} Seconds {2}%        \r".format(round(self.timestamp,2),round(self.last_timestamp,2),round(self.percent,2)))
            else:
                sys.stdout.write(" {0} of {1} Seconds {2}% {3} FPS ({4}ms)       \r".format(round(self.timestamp,2),round(self.last_timestamp,2),round(self.percent,2),self.frame_rate,round(self.interval,2)))
            sys.stdout.flush()    

    def update_timestamps(self):
        for i in range(0,len(self.stream['events'])):
            self.stream['events'][i][0]=float(self.stream['events'][i][0])*self.dilation

    def __init__(self,cast_file,gif_file,events=None,dilation=1,loop_count=0xFFFF,frame_rate=100,loop_delay=1000,natural=None,debug=None,width=None,height=None,underlay=None):
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
        self.percent=-1
        self.timestamp=0
        self.aggregate_timestamp=0
        self.minimal_interval=.03

        if underlay:
            self.underlay=decode(underlay)
            
        print("dilation:{0}".format(self.dilation))
        if None==events:
            print ("input: {0}".format(cast_file))
        else:
            print ("input: stdin (pipe)")
        print ("output: {0}".format(gif_file))
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
        
        self.encode_stream()
    
    
    def encode_stream(self):
        g=encode_gif(self.loop_count,debug=self.debug)
        

        v=viewer(char_width=self.width,char_height=self.height,debug=self.debug)
        g.create(width=v.viewport_px_width,height=v.viewport_px_height,filename=self.gif_file,default_palette=True)

        print ("character dimensions: {0}x{1}".format(self.width,self.height))
        print ("pixel dimensions: {0}x{1}".format(v.viewport_px_width,v.viewport_px_height))

        index=0
        if self.frame_rate!=0:
            self.interval=float(1)/float(self.frame_rate)
        else:
            self.interval=self.minimal_interval
        # default lowest setting
        if self.interval<self.minimal_interval:
            self.interval=self.minimal_interval
        frame=0
        data=None
        old_data=None
        new_frame=None
        self.aggregate_timestamp=0
        text=""
        for event_index in range(0,self.event_length):
            self.show_percent(index)
            event=self.stream['events'][event_index]
            v.add_event(event)
            
            if event_index==self.event_length-1:
                v.last_frame()
                new_frame=True

            delay=self.get_delay(event_index)
            #print("Delay:{0}".format(delay))

            index+=1
            cur_timestamp=round(float(event[0]),2)

            if self.natural and delay!=0 and delay>=self.interval:
                new_frame=True
            elif cur_timestamp-self.timestamp>=self.interval:
                #print("interval_breach")
                new_frame=True
                delay=int((cur_timestamp-self.timestamp)*100)
                #print("Delay",delay,self.interval,cur_timestamp,self.timestamp)

            if new_frame:
                self.info("Frame:{0}, Delay:{1}".format(frame,delay))
                new_frame=None
                frame+=1
               
            
                v.render()
               
                old_data=data
                data=v.get()


                diff=self.get_frame_bounding_diff(old_data,data,v.viewport_px_width,v.viewport_px_height)
                if diff:
                    frame_snip=self.copy_area(data['data'],diff,v.viewport_px_width,v.viewport_px_height)

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

                self.timestamp=cur_timestamp
            self.show_percent(index)
        if self.debug:
            v.debug_sequence()
        g.close()
        #print ("Total:",self.aggregate_timestamp)
        print("\nfinished")
        

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
        for y in range(diff['min_y'],diff['max_y']+1):
            data_pos= y*width+diff['min_x']
            dest_frame_pos= (y-diff['min_y'])*diff['width']
            memcpy(
                    &dest_frame.data.as_uchars[dest_frame_pos], 
                    &data.data.as_uchars[data_pos],
                    diff['width'])
        
        return dest_frame
