
from .Decoder import Decoder
from .canvas import canvas

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

    