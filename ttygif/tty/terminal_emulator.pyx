# cython: linetrace=True
from cpython cimport array
from .parser cimport term_parser
from .terminal_graphics cimport terminal_graphics
from .font cimport font
from .fonts cimport vga_font



# main interface for terminal emulation
class terminal_emulator:
    #cdef public term_parser          parser
    #cdef public terminal_graphics    terminal_graphics
    #cdef public object underlay_flag
    #cdef public object term
    parser=None
    terminal_graphics=None
    underlay_flag=None
    term=None
    
    def __init__(self,width=640,height=480,char_width=None,char_height=None,debug=None):
        self.debug_mode      =debug
        self.underlay_fag    =None
        self.init(width,height,char_width,char_height,debug)

    cdef  init(self,width=640,height=480,char_width=None,char_height=None,debug=None):
        self.parser          = term_parser(debug_mode=debug)
        
        self.terminal_display= terminal_graphics(character_width =char_width,
                                                 character_height=char_height,
                                                 viewport_width  =width,
                                                 viewport_height =height,
                                                 image_font=vga_font)

   
    # this pre computes the regex into commands and stores into an array
    def add_event(self,event):
        self.parser.add_event(event)
    
    def render(self):
        self.parser.render_to_buffer(terminal_graphics)
        self.terminal_graphics.render()

    # this is for returning screen data to other functions
    def get(self):
        return {    
            'width'         : self.terminal_display.viewport.dimentions.width,
            'height'        : self.terminal_display.viewport.dimentions.height,
            'data'          : array.copy(self.terminal_display.viewport.data),
            'color_table'   : self.terminal_display.viewport.palette}

    # TODO snapshot of a frame
    def save_screen(self):
        x=1
