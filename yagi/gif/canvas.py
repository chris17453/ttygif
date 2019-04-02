import json

class canvas:

    def __init__(self,dest_file,gif_data):
        template="""<html>
    <head>
        <title>YAGI {0}, Yet another gif implimentation</title>
    </head>
    <body>
        <canvas id="yagi" width="{1}" height="{2}" style="border:1px solid #000000;"></canvas>
        <script>
            var global_color_table={3}
            var frame_count={4}
            var frames={5}
            var header={6}
            var width={1}
            var height={2}
            var canvas = document.getElementById('yagi');
            var ctx = canvas.getContext("2d");

            function put_pixel(x,y,color_index){{
                var color=global_color_table[color_index]
                var r=color[0];
                var g=color[1];
                var b=color[2];
            
                ctx.fillStyle = "rgb("+r+","+g+","+b+")";
                ctx.fillRect( x, y, 1, 1 );
            }}

            function fill(color_index){{
                var color=global_color_table[color_index]
                var r=color[0];
                var g=color[1];
                var b=color[2];
            
                ctx.fillStyle = "rgb("+r+","+g+","+b+")";
                ctx.fillRect( 0, 0, width, height );
            }}

            function draw_frame(frame){{
                var cx=0;
                var cy=0;
                var color_index=0;
                x=frame['descriptor']['Left']
                y=frame['descriptor']['Top']
                width=frame['descriptor']['Width']
                height=frame['descriptor']['Height']
                image=frame['image']['data']
                len_of_frame=frame['image']['data'].length
                if(frame['gc']['TransparentColorFlag']==true){{
                    transparent=frames[i]['gc']['ColorIndex']
                }} else {{
                    transparent=-1
                }}

                
                for(i=0;i<len_of_frame;i++){{
                    color_index=image[i]
                    if(color_index==transparent){{
                        continue;
                    }}
                    put_pixel(cx+x,cy+y,color_index)
                    cx++;
                    if(cx==width){{
                        cx=0;
                        cy++;
                    }}
                }}
            }}

            fill(header['BackgroundColor']);
            
            for(i  in frames){{
                draw_frame(frames[i])
            }}


        </script>
    </body>
</html>"""
        #self.Signature= stream.string(3,value=gif_sig)        # Header Signature (always "GIF") 
        #self.Version= stream.string(3,value=gif_sig_ver)      # GIF format version("87a" or "89a")
        ## Logical Screen Descriptor
        #self.ScreenWidth= stream.word()                       # Width of Display Screen in Pixels
        #self.ScreenHeight= stream.word()                      # Height of Display Screen in Pixels
        #self.Packed= stream.byte()                            # Screen and Color Map Information
        #self.BackgroundColor= stream.byte()                   # Background Color Index
        #self.AspectRatio= stream.byte()                       # Pixel Aspect Ratio
        bg=gif_data['header'].BackgroundColor
        width=gif_data['header'].ScreenWidth
        height=gif_data['header'].ScreenHeight
        colors=self.render(gif_data['global_color_table'].colors)
        header=self.render(gif_data['header'])
        frames=self.render(gif_data['frames'])
        frame_count=json.dumps(gif_data['frame_count'],indent=4)
        doc=template.format( dest_file,     #0
                             width,         #1
                             height,        #2
                             colors,        #3
                             frame_count,   #4
                             frames,        #5
                             header
                             )
        file = open(dest_file,"w") 
        file.write(doc) 
        file.close() 
    
    def render(self,obj,depth=0):
        """json like output for python objects, very loose"""
        unk_template='"???{0}???"'
        str_template='"{0}"'
        int_template="{0}"
        float_template="{0}"
        bool_template="{0}"
        array_template='['+'{0}'+']'
        tuple_template='"{0}":{1}'
        object_template='{{'+'{0}'+'}}'
        NULL="{}"
        fragment=""
        #if None == obj:
         #   return fragment

        if obj == None:
            fragment+=NULL

        elif isinstance(obj,str):
            fragment+=str_template.format(obj)

        elif isinstance(obj,bool):
            if obj==True:
                fragment+="true"    
            if obj==False:
                fragment+="false"    

        elif isinstance(obj,int):
            fragment+=int_template.format(obj)

        elif isinstance(obj,float):
            fragment+=float_template.format(obj)
        
        elif  isinstance(obj,list):
            partial=[]
            for item in obj:
                partial.append(self.render(item,depth=depth+1))
            if len(partial)>0:
                fragment+=array_template.format(",".join(map(str, partial)))
        elif isinstance(obj,dict):
            partial=[]
            #print (obj)
            for item in obj:
                partial.append(tuple_template.format(item,self.render(obj[item],depth=depth+1)))
            if len(partial)>0:
                fragment+=object_template.format(",".join(map(str, partial))) 
        elif isinstance(obj,object):
            partial=[]
            #print (obj)
            if hasattr(obj,'__dict__'):
                for item in obj.__dict__:
                    partial.append(tuple_template.format(item,self.render(obj.__dict__[item],depth=depth+1)))
                if len(partial)>0:
                    fragment+=object_template.format(",".join(map(str, partial))) 
            else:
                for item in obj:
                    partial.append(tuple_template.format(item,self.render(obj[item],depth=depth+1)))
                if len(partial)>0:
                    fragment+=object_template.format(",".join(map(str, partial))) 
        else:
            fragment+=unk_template.format("UNK",obj)
        return fragment