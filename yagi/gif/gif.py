
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
        canvas(html_filename,data)
        


   
if __name__=='__main__':
    #gif("sample_1.gif")
    #gif("kermit.gif")
    #gif.decode("giphy.gif")
    g=gif(debug=True)
    
    #g.canvas_it("sample_1.gif","giphy.html")
    
    g.canvas_it("kermit.gif","giphy.html")
