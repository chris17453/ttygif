import argparse
from .gif.gif import gif
from .gif.encode import encode_gif
from .tty.fonts import font
from .tty.viewer import viewer 
from .asciicast.reader import asciicast_reader
import pprint
import time

def cli_main():
    parser = argparse.ArgumentParser("ttygif", usage='%(prog)s [options]', description="""tty output to gif""", epilog="Dont yaknow?")

    # actions
    parser.add_argument('-v', '--debug',   help='show debuging statistics', action='store_true')
    parser.add_argument('-i', '--input',   help='source file', default= None)
    parser.add_argument('-o', '--output',  help='destination file', default= None)
    parser.add_argument('-x', '--extract', help='Extract data from gif as json', action='store_true')
    parser.add_argument('-w', '--web',     help='Convert a gif to a html canvas web page.', action='store_true')
    parser.add_argument('-s', '--screen',  help='Create font html canvas web page.', action='store_true')
    parser.add_argument('-t', '--test',    help='test viewer', action='store_true')
    

    args = parser.parse_args()
    if args.web:
        gif().canvas_it(args.input,args.output)
    
    if args.extract:
        gif(debug=None).extract(args.input,args.output)

    if args.screen:
        gif().screen(font,args.output)
    

    if args.test:
        cast=asciicast_reader(debug=None)
        stream=cast.load(args.input)
        #pprint.pprint(stream)
        #return
        v=viewer(char_width=stream['width'],char_height=stream['height'],stream="")
        index=0
        strlen=len(stream['events'])
        for event in stream['events']:
            v.add_event(event)
            percent=int((index*100)/strlen)
            index+=1
            print("Index:{0} out of {1} - {2}%",index,strlen,percent)
            #time.sleep(.1)            
            #print event
            #v.render()
            #data=v.get()
            #break
        v.render()
        v.debug()
        data=v.get()
        #gif().screen(data,args.output)
        g=encode_gif()
        g.create(width=stream['width'],height=stream['height'],filename=args.output,default_palette=True)
        g.add_frame(disposal_method=0,delay=1, transparent=None,top=0,left=0,width=None,Height=None,palette=None,image_data=data)
        g.write()

        #g=gif()
        #print(data)
        #g.encode(data,args.output)
            

if __name__=='__main__':
    cli_main()
