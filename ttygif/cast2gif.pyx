# cython: linetrace=True
import sys
from cpython cimport array
import array
from libc.string cimport  memcpy
from .gif.encode import encode_gif
from .asciicast.reader import asciicast_reader
from .tty.viewer import viewer


cdef class cast2gif:
    cdef object debug

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


    def __init__(self,cast_file,gif_file,loop_count=0xFFFF,frame_rate=100,loop_delay=1000,natural=None,debug=None,width=None,height=None):
        self.debug=debug
        print ("input : {0}".format(cast_file))
        print ("output: {0}".format(gif_file))
        cast=asciicast_reader(debug=debug)
        stream=cast.load(cast_file)
        
        g=encode_gif(loop_count,debug=debug)
        if width==None:
            width=stream['width']
        if height==None:
            height=stream['height']

        print ("dimensions: {0}x{1}".format(width,height))
        

        v=viewer(char_width=width,char_height=height,debug=debug)
        g.create(width=v.viewport_px_width,height=v.viewport_px_height,filename=gif_file,default_palette=True)

        percent=-1
        index=0
        timestamp=0
        if frame_rate!=0:
            interval=float(1)/float(frame_rate)
        else:
            interval=0
        frame=0
        max_frames=50
        data=None
        old_data=None
        strlen=len(stream['events'])
        if strlen<1:
            print("Empty stream")
            exit(0)

        last_timestamp=float(stream['events'][strlen-1][0])
        timestamp=float(stream['events'][0][0])
        #print timestamp
        new_frame=None
       # print "FR",frame_rate
        
        for event_index in range(0,len(stream['events'])):
            event=stream['events'][event_index]
            v.add_event(event)
            if event_index==len(stream['events'])-1:
                #print loop_delay,1
                if loop_delay==None:
                    loop_delay=1000
                delay=loop_delay 
                new_frame=True
                #print("last frame")
                v.last_frame()
            else:
                #print 2
                if frame_rate==0:
                    #print 3
                    print stream['events'][event_index+1][0],stream['events'][event_index][0]
                    delay=float(stream['events'][event_index+1][0])-stream['events'][event_index][0]
                else:
                    #print 4

                    delay=int(interval*100)
            print("Delay:{0}".format(delay))

            index+=1
            old_percent=percent
            percent=int((index*100)/strlen)
            if percent!=old_percent:
                if natural:
                    sys.stdout.write("Seconds: {0} of {1} {2}%    \r".format(timestamp,last_timestamp,percent))                
                else:
                    sys.stdout.write("Seconds: {0} of {1} {2}% {3} FPS ({4}ms)    \r".format(timestamp,last_timestamp,percent,frame_rate,interval))
                sys.stdout.flush()
            cur_timestamp=float(event[0])
            #print cur_timestamp,cur_timestamp-timestamp,interval
            
            if natural :
                new_frame=True
            elif cur_timestamp-timestamp>interval:
                new_frame=True

            if new_frame:
                #print("frame {0}".format(frame))
                new_frame=None
                #print ("New Frame")
                frame+=1
                #if frame>2: 
                #    break
                #if frame>max_frames:
                 #   break
                v.render()
                old_data=data
                data=v.get()
                old_data=None
                
                diff=self.get_frame_bounding_diff(old_data,data,v.viewport_px_width,v.viewport_px_height)
                
                if diff:
                    frame_snip=self.copy_area(data['data'],diff,v.viewport_px_width,v.viewport_px_height)
                    
                    if delay==0:
                        g.add_frame(disposal_method=0,delay=0, 
                                        transparent=None,
                                        left=diff['min_x'],top=diff['min_y'],
                                        width=diff['width'],height=diff['height'],
                                        palette=None,image_data=frame_snip)
                    else:
                        while delay!=0:
                            if delay>0xFFFF:
                                partial_delay=0xFFFF
                            else:
                                partial_delay=delay
                            delay-=partial_delay
                            #print diff
                            #print (len(frame_snip))
                            g.add_frame(disposal_method=0,delay=partial_delay, 
                                            transparent=None,
                                            left=diff['min_x'],top=diff['min_y'],
                                            width=diff['width'],height=diff['height'],
                                            palette=None,image_data=frame_snip)
                timestamp=cur_timestamp
        if self.debug:
            v.debug_sequence()
        g.close()
        print("\nfinished")
        


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
