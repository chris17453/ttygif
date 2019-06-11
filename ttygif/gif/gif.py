
from .Decoder import Decoder
from .canvas import canvas
from .encode import Encode

class gif:
    def __init__(self,debug=None):
        self.debug=debug

    def decode(self,filename):
        decoder=Decoder(filename,debug=self.debug)
        data=decoder.get()
        return data

    def canvas_it(self,gif_filename,html_filename):
        decoder=Decoder(gif_filename,debug=self.debug)
        data=decoder.get()
        canvas().web(html_filename,data)
        
    def extract(self,gif_filename,output_filename):
        decoder=Decoder(gif_filename,debug=self.debug)
        data=decoder.get()
        canvas().extract(data,output_filename)
    
    def screen(self,data,output_filename):
        canvas().screen_canvas(data,output_filename)

    def encode(self,data,output_filename):
        e=Encode()
        data_buffer=[]
        image_data=data['data']
        min_code_size=8
        e.compress(min_code_size,[4,3,2,65,76,5,47,65,7,65,47,6,5,4,7,65,47,65,47,6,5,65,43,5,34,15,3,24,32,14,2,31,42,31,4])
        #content=open (output_filename,"wb")
        #content.
        print data_buffer

