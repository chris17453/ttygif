# cython: linetrace=True
import sys
from libc.string cimport  memcpp
from .gif.encode import encode_gif
from .asciicast.reader import asciicast_reader
from .tty.viewer import viewer


class cast2gif:
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

    def copy_area(self,data,diff,int width,int height):
        cdef int pos=0
        cdef int new_data_len=diff['width']*diff['height']
        cdef int y_offset
       
       #  print new_data_len
        cdef array.array new_data=array.aray('B')
        new_data.resize(new_data_len)

        for y in range(diff['min_y'],diff['max_y']+1):
            data_pos=y*width
            new_data_pos=y*diff['width']
            memcpy(data.data.as_voidptr[data_pos], new_data.data.as_voidptr[new_data_pos], sizeof(char)*width)#that is pretty sloppy..
           #r#es.data.as_longlongs[n]=x

            #y_offset=y*width
            #for x in range(diff['min_x'],diff['max_x']+1):
             #   new_data[pos]=data[x+y_offset]
             #   pos+=1
                
        
        return new_data

    def __init__(self,cast_file,gif_file,loop_count=0xFFFF,frame_rate=100,natural=None,debug=None):
        self.debug=debug
        print ("input : {0}".format(cast_file))
        print ("output: {0}".format(gif_file))
        cast=asciicast_reader(debug=debug)
        stream=cast.load(cast_file)

        g=encode_gif(loop_count,debug=debug)
        v=viewer(char_width=stream['width'],char_height=stream['height'],debug=debug)
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
        for event in stream['events']:
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
                new_frame=None
                #print ("New Frame")
                frame+=1
                #if frame>max_frames:
                 #   break
                v.render()
                old_data=data
                data=v.get()
                #old_data=None
                diff=self.get_frame_bounding_diff(old_data,data,v.viewport_px_width,v.viewport_px_height)
                
                if diff:
                    frame_snip=self.copy_area(data['data'],diff,v.viewport_px_width,v.viewport_px_height)

                    
                    delay=int((cur_timestamp-timestamp)*100)
                    #print delay,cur_timestamp-timestamp
                    
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
                


            v.add_event(event)

        # need to close the gif
        # last frame    
        v.render()
        data=v.get()
        delay=int((cur_timestamp-timestamp)*100)
        diff=self.get_frame_bounding_diff(old_data,data,v.viewport_px_width,v.viewport_px_height)
        frame_snip=self.copy_area(data['data'],diff,v.viewport_px_width,v.viewport_px_height)
        g.add_frame(disposal_method=0,delay=delay, 
                        transparent=None,
                        left=diff['min_x'],top=diff['min_y'],
                        width=diff['width'],height=diff['height'],
                        palette=None,image_data=frame_snip)
        g.close()
        print("\nfinished")
        