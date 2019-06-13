import sys
from .gif.encode import encode_gif
from .asciicast.reader import asciicast_reader
from .tty.viewer import viewer


class cast2gif:
    def get_frame_bounding_diff(self,frame1,frame2,width,height):
        if frame1==None or frame2==None:
            return {'min_x':0,'min_y':0,'max_x':width-1,'max_y':height-1,'width':width,'height':height}
        pos=0
        min_x=width
        min_y=height
        max_x=0
        max_y=0
        same=True
        for y in range(0,height):
            for x in range(0,width):
                if frame1['data'][pos]!=frame2['data'][pos]:
                    same=None
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
        if same:
            min_x=0
            min_y=0
            max_x=2
            max_y=2
            #return None

        bound_height=max_y-min_y+1
        bound_width =max_x-min_x+1
        return {'min_x':min_x,'min_y':min_y,'max_x':max_x,'max_y':max_y,'width':bound_width,'height':bound_height}

    def copy_area(self,data,diff,width,height):
        pos=0
        new_data_len=diff['width']*diff['height']
       # print new_data_len
        new_data=[0]*new_data_len
        for y in range(diff['min_y'],diff['max_y']+1):
            y_offset=y*width
            for x in range(diff['min_x'],diff['max_x']+1):
                new_data[pos]=data[x+y_offset]
                pos+=1
                
        
        return new_data

    def __init__(self,cast_file,gif_file,loop_count=0xFFFF,debug=None):
        self.debug=debug

        cast=asciicast_reader(debug=debug)
        stream=cast.load(cast_file,debug=debug)

        g=encode_gif(loop_count,debug=debug)
        v=viewer(char_width=stream['width'],char_height=stream['height'],stream="",debug=debug)
        g.create(width=v.width,height=v.height,filename=gif_file,default_palette=True)

        index=0
        timestamp=0
        interval=.100
        frame=0
        max_frames=50
        data=None
        old_data=None
        strlen=len(stream['events'])
        for event in stream['events']:
            index+=1
            if timestamp==0:
                timestamp=float(event[0])

            cur_timestamp=float(event[0])
            if cur_timestamp-timestamp>interval:
                timestamp=cur_timestamp
                percent=int((index*100)/strlen)
                sys.stdout.write("Time: {0}-{1} - {2}%\r".format(index,strlen,percent))
                sys.stdout.flush()
                
                frame+=1
                #if frame>max_frames:
                 #   break
                v.render()
                old_data=data
                data=v.get()
                #old_data=None
                diff=self.get_frame_bounding_diff(old_data,data,v.width,v.height)
                
                if diff:
                    frame_snip=self.copy_area(data['data'],diff,v.width,v.height)

                    delay=int(interval*100)
                    if delay>255:
                        delay=255
                    #print diff
                    #print (len(frame_snip))
                    g.add_frame(disposal_method=0,delay=delay, 
                                    transparent=None,
                                    left=diff['min_x'],top=diff['min_y'],
                                    width=diff['width'],height=diff['height'],
                                    palette=None,image_data=frame_snip)
            v.add_event(event)

        # need to close the gif
        # last frame    
        if 1==0:
            v.render()
            data=v.get()
            diff=self.get_frame_bounding_diff(old_data,data,v.width,v.height)
            frame_snip=self.copy_area(data['data'],diff,v.width,v.height)
            g.add_frame(disposal_method=0,delay=delay, 
                            transparent=None,
                            left=diff['min_x'],top=diff['min_y'],
                            width=diff['width'],height=diff['height'],
                            palette=None,image_data=frame_snip)
        g.close()
        print("finished")
        