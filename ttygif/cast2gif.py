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
        for y in range(0,height):
            for x in range(0,width):
                if frame1[pos]!=frame2[pos]:
                    if x<min_x:
                        min_x=x
                    if x>max_x:
                        max_x=x
                    if y<min_y:
                        min_y=y
                    if y>max_y:
                        max_y=y
                pos+=1
        bound_height=max_y-min_y
        bound_width =max_x-min_x
        return {'min_x':min_x,'min_y':min_y,'max_x':max_x,'max_y':max_y,'width':bound_width,'height':bound_height}

    def copy_area(self,data,diff,width,height):
        pos=0
        new_data_len=diff['width']*diff['height']
        print diff,new_data_len,len(data)
        new_data=[0]*new_data_len
        for y in range(diff['min_y'],diff['max_y']+1):
            y_offset=y*width
            for x in range(diff['min_x'],diff['max_x']+1):
                new_data[pos]=data[x+y_offset]
                pos+=1
        
        return new_data

    def __init__(self,cast_file,gif_file):
        cast=asciicast_reader(debug=None)
        stream=cast.load(cast_file)

        v=viewer(char_width=stream['width'],char_height=stream['height'],stream="")
        index=0
        strlen=len(stream['events'])

        g=encode_gif()
        g.create(width=v.width,height=v.height,filename=gif_file,default_palette=True)

        timestamp=0
        interval=.100
        frame=0
        max_frames=10
        data=None
        old_data=None
        for event in stream['events']:
            index+=1
            if timestamp==0:
                timestamp=float(event[0])

            cur_timestamp=float(event[0])
            if cur_timestamp-timestamp>interval:
                print("Frame: {0}".format(frame))
                frame+=1
                if frame>max_frames:
                    break
                percent=int((index*100)/strlen)
                #print("Index:{0} out of {1} - {2}%".format(index,strlen,percent))
                v.render()
                old_data=data
                data=v.get()
                print len(data)
                diff=self.get_frame_bounding_diff(old_data,data,v.width,v.height)
                frame_snip=self.copy_area(data,diff,v.width,v.height)

                delay=int(interval*100)
                if delay>255:
                    delay=255
                g.add_frame(disposal_method=0,delay=delay, 
                                transparent=None,
                                top=diff['min_x'],left=diff['min_y'],
                                width=diff['width'],height=diff['height'],
                                palette=None,image_data=frame_snip)
            v.add_event(event)

        # last frame    
        v.render()
        data=v.get()
        g.add_frame(disposal_method=0,delay=1, transparent=None,top=0,left=0,width=data['width'],height=data['height'],palette=None,image_data=data['data'])
        g.write()
        #gif().screen(data,args.output)

        #g=gif()
        #print(data)
        #g.encode(data,args.output)
