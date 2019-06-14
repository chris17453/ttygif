
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

    parser = argparse.ArgumentParser("ttygif", usage='%(prog)s [options]', description="""tty output to gif""", epilog="Dont yaknow?")
    # actions
    parser.add_argument('-v', '--debug',      help='show debuging statistics', action='store_true')
    parser.add_argument('-i', '--input',      help='source file', default= None)
    parser.add_argument('-o', '--output',     help='destination file', default= None)
    parser.add_argument('-x', '--extract',    help='Extract data from gif as json', action='store_true')
    parser.add_argument('-w', '--html',       help='Convert a gif to a html canvas web page.', action='store_true')
    parser.add_argument('-l', '--loop',       help='number of times to loop animation, default 0= forever', default=0)
    parser.add_argument('-f', '--frame-rate', help='frame rate, default 8 FPS (1-25)', default=8)
    

    args = parser.parse_args()
    if args.html:
        gif().canvas_it(args.input,args.output)
    
    elif args.extract:
        gif(debug=None).extract(args.input,args.output)


    elif args.input and args.output:
        frame_rate=int(args.frame_rate)
        if frame_rate<0:
            frame_rate=1
        if frame_rate>25:
           frame_rate=25
            
        cast2gif(args.input,args.output,loop_count=args.loop,debug=args.debug,frame_rate=frame_rate)
    else:
        print("usage: ttygif -i input.cast -o output.gif -l 1")
                    

if __name__=='__main__':
    cli_main()
