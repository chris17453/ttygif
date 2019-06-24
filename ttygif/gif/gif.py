# cython: linetrace=True

from .decoder import decoder
from .canvas import canvas

class gif:
    def __init__(self,debug=None):
        self.debug=debug

    def decode(self,filename):
        d=decoder(filename,debug=self.debug)
        data=d.get()
        return data

    def canvas_it(self,gif_filename,html_filename):
        d=decoder(gif_filename,debug=self.debug)
        data=d.get()
        canvas().web(html_filename,data)
        
    def extract(self,gif_filename,output_filename):
        d=decoder(gif_filename,debug=self.debug)
        data=d.get()
        canvas().extract(data,output_filename)
    
    def screen(self,data,output_filename):
        canvas().screen_canvas(data,output_filename)

    