# cython: profile=True
# cython: linetrace=True
# cython: binding=True
# cython: language_level=2

import argparse
from .asciicast.reader import asciicast_reader
from .cast2gif import cast2gif
from .version import __version__
from .tools.passthrough import has_stdin, read_stdin
import pprint
import time
import sys



def cli_main():
    print("ttygif version {0}".format( __version__))

    parser = argparse.ArgumentParser(
        prog='ttygif',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
        description="""tty output to gif""")
    # actions

    parser.add_argument('--input',     help='asciinema .cast file', default= None,metavar='FILE')
    parser.add_argument('--output',    help='gif output file', default= None,metavar='FILE')
    parser.add_argument('--loop',      help='number of loops to play, 0=unlimited', default=0,metavar='COUNT')
    parser.add_argument('--delay',     help='delay before restarting gif in milliseconds ', default=100,metavar='MS')
    parser.add_argument('--record',    help='output generated cast data to file', metavar='FILE')
    
    parser.add_argument('--dilation',  help='process events at a faster or slower rate of time', default=1,metavar='RATE', type=float)
    parser.add_argument('--fps',       help='encode at (n) frames per second (0-25) 0=speed of cast file, min 3ms', default=0,metavar='FPS', type=int)
    parser.add_argument('--width',     help='change character width of gif, default is 80 or what is in the cast file',metavar='WIDTH', type=int)
    parser.add_argument('--height',    help='change character height of gif, default is 25 or what is in the cast file',metavar='HEIGHT', type=int)
    #parser.add_argument('--text-at'  help='print the text screen buffer at TIME',metavar='TIME', type=int)
    parser.add_argument('--underlay',  help='use a gif image as the background', default= None,metavar='FILE')
    parser.add_argument('--overlay',   help='use a gif image as a transparent top layer', default= None,metavar='FILE')
    parser.add_argument('--undelay--bounds',   help='the bounding of the background image  (left,top,right,bottom)', default= None,nargs=4)
    parser.add_argument('--overlay--bounds',   help='the bounding of the transparent top layer (left,top,right,bottom)', default= None,nargs=4)


    # underlay_display =simple, stretch, center
    # bounds x,y x x2,y2
    # underlay_display =simple, stretch, center
    # bounds x,y x x2,y2
    
    
    parser.add_argument('--debug',   help='show debuging statistics', action='store_true',default=None)
    #debug.add_argument('-c', '--show-commands', help='dump interpreted cast data ', action='store_true')
    
    # dev options
    #tools = parser.add_argument_group('Tools')
    #tools.add_argument('-x', '--extract',       help='gif data to json', action='store_true')
    #tools.add_argument('-w', '--html',          help='gif to html', action='store_true')

    args = parser.parse_args()
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
            
        natural=None
        if args.fps==0:
            natural=True
        debug=args.debug
        try:
            
            cast2gif(args.input,args.output,
                    events=events,
                    loop_count=args.loop,
                    loop_delay=args.delay,
                    debug=debug,
                    dilation=args.dilation,
                    frame_rate=frame_rate,
                    natural=natural,
                    height=args.height,
                    width=args.width,
                    underlay=args.underlay)
        except KeyboardInterrupt:
            print("\nProcessing Aborted...")
            sys.exit()
    else:
        parser.print_help()
                    

if __name__=='__main__':
    cli_main()
