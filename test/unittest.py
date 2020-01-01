import os
import sys
import unittest2
from .context import  ttygif

# some gifs came from https://www.htmlgoodies.com/tutorials/web_graphics/article.php/3479931/Image-Formats.htm#gif
# the rest are random. Kermit is my fav
class test_engine(unittest2.TestCase):
    base_asset_dir="assets/src_gifs/"
    base_decode_dir="assets/canvas/"
    def test_canvas_noninterlaced(self):
        try:
            g=ttygif.gif.gif(debug=None)
            g.canvas_it(self.base_asset_dir+"/VGA_8x19font.gif",self.base_decode_dir+"/VGA_8x19font.html")
        except Exception as ex:
            self.fail(ex)

    def test_canvas_interlaced(self):
        try:
            g=ttygif.gif.gif(debug=None)
            g.canvas_it(self.base_asset_dir+"/89a_interlaced.gif",self.base_decode_dir+"/89a_interlaced.html")
        except Exception as ex:
            self.fail(ex)

    def test_canvas_kermit(self):
        try:
            g=ttygif.gif.gif(debug=None)
            g.canvas_it(self.base_asset_dir+"/kermit.gif",self.base_decode_dir+"/kermit.html")
        except Exception as ex:
            self.fail(ex)

    def test_canvas_giphy(self):
        try:
            g=ttygif.gif.gif(debug=None)
            g.canvas_it(self.base_asset_dir+"/giphy.gif",self.base_decode_dir+"/giphy.html")
        except Exception as ex:
            self.fail(ex)

    def test_canvas_blue(self):
        try:
            g=ttygif.gif.gif(debug=None)
            g.canvas_it(self.base_asset_dir+"/blue.gif",self.base_decode_dir+"/blue.html")
        except Exception as ex:
            self.fail(ex)


if __name__ == '__main__':
    unittest2.main()
