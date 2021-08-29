# cython: profile=True
# cython: linetrace=True
# cython: binding=True
# cython: language_level=2

import os
import argparse
from .asciicast.reader import asciicast_reader
from .cast2gif import cast2gif
from .version import __version__
from .tools.passthrough import has_stdin, read_stdin
import pprint
import time
import sys



def main():
    print("ttygif version [{0}]\n".format( __version__))
    print(" - Compiled against Python: {0}".format(sys.version.replace("\n"," ")))
    
    formatter = lambda prog: argparse.HelpFormatter(prog,max_help_position=42)

    parser = argparse.ArgumentParser(
        prog='ttygif',
        description="""tty output to gif""",
        formatter_class=formatter)

    
    #file options
    parser.add_argument('--input'       , '-i'  , help='asciinema .cast file', default= None,metavar='FILE')
    parser.add_argument('--output'      , '-o'  , help='gif output file. will default to ttygif-xx', default= None,metavar='FILE')
    parser.add_argument('--record'      ,         help='output generated cast data to file', metavar='FILE')
    
    
    group1 = parser.add_argument_group('Gif', 'Effects')

    #gif options
    group1.add_argument('--theme'       , '-t'  , help='load theme: game,windows7,mac,fwdm,opensource,scripted,bar. User themes can be loaded by file or ~./ttygif.  .theme is added to any user input ',default='default')
    group1.add_argument('--loop'        , '-l'  , help='number of loops to play, 0=unlimited', default=0,metavar='COUNT', type=int)
    group1.add_argument('--delay'       , '-d'  , help='delay before restarting gif in milliseconds ', default=100,metavar='MS', type=int)
    group1.add_argument('--trailer'     ,         help='Append an ending to the gif',action='store_true',default=None)
    group1.add_argument('--speed'       ,         help='process events at a faster or slower rate of time. Pipes are sped up 10,000 automatically', default=1,metavar='RATE', type=float)
    group1.add_argument('--fps'         ,         help='encode at (n) frames per second (0-100) 0=speed of cast file, min 3ms', default=10,metavar='FPS', type=int)
    group1.add_argument('--title'       ,         help='If using a theme, you can add a title text', default=None, type=str)
    
    parser.add_argument('--underlay'    ,         help='Add an image as a background, (Internal)', metavar='FILE', default=None)
    

    group2 = parser.add_argument_group('Term', 'Default settings')
    #terminal options
    group2.add_argument('--no-autowrap'          ,help='turn off line wrap in the terminal', action='store_true',default=None)
    group2.add_argument('--font'        ,  '-f'  ,help='which internal font to use', metavar='NAME')
    group2.add_argument('--columns'     ,  '-c'  ,help='change character width of gif, default is 80 or what is in the cast file',metavar='WIDTH', type=int)
    group2.add_argument('--rows'        ,  '-r'  ,help='change character height of gif, default is 25 or what is in the cast file',metavar='HEIGHT', type=int)
    #parser.add_argument('--text-at'  help='print the text screen buffer at TIME',metavar='TIME', type=int)
 
    # underlay_display =simple, stretch, center
    # bounds x,y x x2,y2
    # underlay_display =simple, stretch, center
    # bounds x,y x x2,y2
    
    #debug stuff
    #group3 = parser.add_argument_group('Debug', 'Various debugging chores')
    #group3.add_argument('--last-event' ,         help='Debug . Trim events to this index. (found from --debug)', metavar='FILE', default=0,type=int)
    #group3.add_argument('--show-state' ,         help='Debug . show display state', action='store_true',default=None);
    #group3.add_argument('--debug'      ,         help='show debuging statistics', action='store_true',default=None)
    #group3.add_argument('--debug-gif'  ,         help='show gif debuging statistics', action='store_true',default=None)
    #debug.add_argument('-c', '--show-commands', help='dump interpreted cast data ', action='store_true')
    
    # dev options
    #tools = parser.add_argument_group('Tools')
    #tools.add_argument('-x', '--extract',       help='gif data to json', action='store_true')
    #tools.add_argument('-w', '--html',          help='gif to html', action='store_true')

    args = parser.parse_args()
    if args.output==None:
        for index in range(0,10000):
            filename="ttygif-{0:04d}.gif".format(index)
            if os.path.exists(filename)==False:
                args.output=filename
                break;
        if args.output==None:
            print( " Well, Well. You have no output file, and all the auto generated file names are taken. Messy.")
            exit(1);

    


    #if args.html:
    #    gif().canvas_it(args.input,args.output)
    
    #elif args.extract:
    #    gif(debug=None).extract(args.input,args.output)

    #elif  args.show_commands and args.input:
    #    cast=asciicast_reader(debug=args.debug)
    #    stream=cast.load(args.input)
    #    v=viewer()
    #    for event in stream['events']:
    #        v.add_event(event)
#
    #    v.debug_sequence()

    
    
    if  args.output:
        events=None
        if has_stdin():
            events=read_stdin()
            if args.speed==1:
                args.speed=10000
            if args.record:
                ar=asciicast_reader()
                ar.write(args.record,events)
            
        elif None==args.input:
            parser.print_help()    
            events=None
            exit(0)

        frame_rate=args.fps
        if frame_rate<0:
            frame_rate=1
        if frame_rate>100:
           frame_rate=100
            
        #debug=args.debug

        try:

        # just for me...
                    #show_state   =args.show_state,
                    #debug        =debug,
                    #debug_gif    =args.debug_gif,
                    #last_event   =args.last_event,

            cast2gif(args.input,args.output,
                    title        =args.title,
                    no_autowrap  =args.no_autowrap,
                    trailer      =args.trailer,
                    events       =events,
                    loop_count   =args.loop,
                    loop_delay   =args.delay,
                    dilation     =args.speed,
                    frame_rate   =frame_rate,
                    height       =args.rows,
                    width        =args.columns,
                    underlay     =args.underlay,
                    #overlay=args.overlay,
                    font_name   =args.font,
                    theme_name  =args.theme)
        except KeyboardInterrupt:
            print("\nProcessing Aborted...")
            sys.exit()
    else:
        parser.print_help()
                    

if __name__=='__main__':
    main()
