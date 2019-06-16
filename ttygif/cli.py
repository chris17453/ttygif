# cython: linetrace=True

import argparse
from .gif.gif import gif
from .gif.encode import encode_gif
from .tty.viewer import viewer 
from .asciicast.reader import asciicast_reader
from .cast2gif import cast2gif
from .version import __version__
import pprint
import time

def cli_main():
    print("ttygif version {0}".format( __version__))

    parser = argparse.ArgumentParser(
        prog='ttygif',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
        description="""tty output to gif""")
    # actions

    parser.add_argument('--input',   help='asciinema .cast file', default= None,metavar='FILE')
    parser.add_argument('--output',  help='gif output file', default= None,metavar='FILE')
    parser.add_argument('--loop',    help='number of loops to play, 0=unlimited', default=0,metavar='COUNT')
    parser.add_argument('--delay',   help='delay before restarting gif in milliseconds', default=1000,metavar='MS')
    parser.add_argument('--fps',     help='encode at (n) frames per second (0-25) 0=speed of cast file', default=8,metavar='FPS')
    
    
    
    #debug = parser.add_argument_group('Debug')
    #debug.add_argument('-v', '--debug',         help='show debuging statistics', action='store_true')
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

    if args.input and args.output:
        frame_rate=int(args.fps)
        if frame_rate<0:
            frame_rate=1
        if frame_rate>25:
           frame_rate=25
            
        natural=None
        if args.fps==0:
            natural=True
        debug=None
        cast2gif(args.input,args.output,loop_count=args.loop,debug=debug,frame_rate=frame_rate,natural=natural)
    else:
        parser.print_help()
                    

if __name__=='__main__':
    cli_main()
