# cython: profile=True

import json
# TODO pick transparent color index, none OR first pixel
# TODO disposal of last frame if end of loop
# TODO Loop based on # times or infinity

class canvas:

    def __init__(self):
        x=1

    def web(self,dest_file,gif_data):
        template="""<html>
    <head>
        <title>TTYGIF {0}, STDIO/TTY to GIF</title>
    </head>
    <body>
        <canvas id="ttygif" width="{1}" height="{2}" style="border:1px solid #000000;"></canvas>
        <script>
            var global_color_table={3}
            var frame_count={4}
            var frames={5}
            var header={6}
            var width={1}
            var height={2}
            var canvas = document.getElementById('ttygif');
            var ctx = canvas.getContext("2d");
            var id = ctx.createImageData(1,1);
            var id2 = ctx.createImageData({1},{2});
            var d  = id.data;                        
            var id2d  = id2.data;                        
            var mode=3;  // this changes the method used to blit the image.
                         // 1 is a rect per pixel. good for scaling i guess
                         // 2 is single image writes way slower
                         // 3 is single blit

            function put_pixel(x,y,color_index){{
                var color=global_color_table[color_index]
                if(mode==1){{
                    var r=color[0];
                    var g=color[1];
                    var b=color[2];
                    ctx.fillStyle = "rgb("+r+","+g+","+b+")";
                    ctx.fillRect( x, y, 1, 1 );
                }} 
                if(mode==2) {{
                    d[0]   = color[0];
                    d[1]   = color[1];
                    d[2]   = color[2];
                    d[3]   = 255;
                    ctx.putImageData( id, x, y ); 
                }}
                if(mode==3){{
                    var off = (y * id2.width + x) * 4;

                    id2d[off+0]   = color[0];
                    id2d[off+1]   = color[1];
                    id2d[off+2]   = color[2];
                    id2d[off+3]   = 255;

                }}
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
                if(frame['gc'] && frame['gc']['TransparentColorFlag']==true){{
                    transparent=frame['gc']['ColorIndex']
                }} else {{
                    transparent=-1
                }}

                
                for(i=0;i<len_of_frame;i++){{
                    color_index=image[i]
                    if(color_index!=transparent){{
                        put_pixel(cx+x,cy+y,color_index)
                    }}

                    cx++;
                    if(cx==width){{
                        cx=0;
                        cy++;
                    }}
                }}
                if (mode==3){{
                    ctx.putImageData(id2,0,0);
            
                }}
            }}
            function sleep(milliseconds) {{
                var start = new Date().getTime();
                for (var i = 0; i < 1e7; i++) {{
                    
                    if ((new Date().getTime() - start) > milliseconds){{
                    break;
                    }}
                }}
            }}

            
            fill(header['BackgroundColor']);
            var cur_frame=0,last_frame=0;
            function rotate(){{
                
                if(frames[last_frame]['gc']){{
                    disposal=frames[last_frame]['gc']['DisposalMethod']
                    
                                        
                    if(disposal==1){{ //Do rewind to a disposal=0
                        for(i=last_frame-1;i>-1;i--){{
                            if(frames[i]['gc']){{
                                disposal=frames[i]['gc']['DisposalMethod']
                                if(disposal==0){{
                                    draw_frame(frames[i]);
                                    break;
                                }}
                    
                            }}
                        }}
                    }}
                    if (frames[cur_frame]['gc']){{
                        DELAY=frames[cur_frame]['gc']['DelayTime']*10;
                        last_frame=cur_frame;
                        if (DELAY!=0){{
                            setTimeout(rotate,DELAY);
                            cur_frame++;
                            if(cur_frame>=frames.length){{
                                cur_frame=0;
                            }}
                        }}
                        
                    }}

                }}
                draw_frame(frames[cur_frame])
                
            }}
            rotate();
                
        
        </script>

    </body>
</html>"""
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
    
    def extract(self,data,output_file):
        doc=self.render(data)
        file = open(output_file,"w") 
        file.write(doc) 
        file.close() 
    
    def screen_canvas(self,screen,output_file):
        template="""<html>
    <head>
        <title>TTYGIF {0}, STDIO/TTY to GIF</title>
    </head>
    <body>
        <canvas id="ttygif" width="{1}" height="{2}" style="border:0px solid #000000;"></canvas>
        <script>
            var frame={3}
            var canvas = document.getElementById('ttygif');
            var ctx = canvas.getContext("2d");
            var id2 = ctx.createImageData({1},{2});
            var id2d  = id2.data;                        
          
            function put_pixel(x,y,color_index){{
                var color=frame['color_table'][color_index]
                var off = (y * id2.width + x) * 4;

                id2d[off+0]   = color[0];
                id2d[off+1]   = color[1];
                id2d[off+2]   = color[2];
                id2d[off+3]   = 255;
            }}

            function fill(color_index){{
                var color=frame['color_table'][color_index]
                var r=color[0];
                var g=color[1];
                var b=color[2];
            
                ctx.fillStyle = "rgb("+r+","+g+","+b+")";
                ctx.fillRect( 0, 0, frame['width'], frame['height'] );
            }}

            function draw_frame(){{
                var cx=0;
                var cy=0;
                var color_index=0;
                width=frame['width']
                height=frame['height']
                len_of_frame=frame['data'].length
                
                for(i=0;i<len_of_frame;i++){{
                    color_index=frame['data'][i]
                    put_pixel(cx,cy,color_index)
                    cx++;
                    if(cx==width){{
                        cx=0;
                        cy++;
                    }}
                }}
                ctx.putImageData(id2,0,0);
            }}

            
            fill(0);
            draw_frame()
            
        </script>

    </body>
</html>"""
        frame=self.render(screen)
        doc=template.format( output_file,     #0
                             screen.width,
                             screen.height,
                             frame,         #4
                             )
        file = open(output_file,"w") 
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
                try:
                    for item in obj.__dict__:
                        render_res=self.render(obj.__dict__[item],depth=depth+1)
                        if not render_res or render_res=="":
                            continue
                        partial.append(tuple_template.format(item,render_res))
                    if len(partial)>0:
                        fragment+=object_template.format(",".join(map(str, partial))) 
                except:
                    pass
            else:
                try:
                    for item in obj:
                        render_res=self.render(obj[item],depth=depth+1)
                        if not render_res or render_res=="":
                            continue
                        partial.append(tuple_template.format(item,render_res))
                    if len(partial)>0:
                        fragment+=object_template.format(",".join(map(str, partial))) 
                except:
                    pass
        else:
            fragment+=unk_template.format("UNK",obj)
        return fragment