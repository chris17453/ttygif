# cython: profile=True
# cython: linetrace=True
# cython: binding=True
# cython: language_level=2

    

from .decode import decode
from .canvas import canvas

class gif:
    def __init__(self,debug=None):
        self.debug=debug

    def decode(self,filename):
        d=decode(filename,debug=self.debug)
        data=d.get()
        return data

    def canvas_it(self,gif_filename,html_filename):
        d=decode(gif_filename,debug=self.debug)
        data=d.get()
        canvas().web(html_filename,data)
        
    def extract(self,gif_filename,output_filename):
        d=decode(gif_filename,debug=self.debug)
        data=d.get()
        canvas().extract(data,output_filename)
    
    def screen(self,data,output_filename):
        canvas().screen_canvas(data,output_filename)

    