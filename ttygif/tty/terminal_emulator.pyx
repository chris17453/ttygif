# cython: linetrace=True


from .parser cimpor term_parser
from .graphic cimport terminal_graphics
from .font cimport font
from .fonts cimport vga_font



# main interface for terminal emulation
cdef class terminal_emulator:
    
    cdef public term_parser          parser
    cdef public terminal_graphics    terminal_display
    cdef public object underlay_flag
    cdef public object term
    
    def __init__(self,width=640,height=480,char_width=None,char_height=None,debug=None):
        self.debug_mode      =debug
        self.underlay_fag    =None
        
        self.parser          = term_parser(debug_mode=debug)
        
        self.terminal_display= terminal_graphics(character_width =char_width,
                                                 character_height=char_height,
                                                 viewport_width  =width,
                                                 viewport_height =height,
                                                 image_font=vga_font)

   
    # this pre computes the regex into commands and stores into an array
    def add_event(self,event):
        parser.add_event(event)
    
    def render(self):
        self.terminal_display.

    # this is for returning screen data to other functions
    def get(self):
        return {    
            'width'         : self.terminal_display.viewport.dimentions.width,
            'height'        : self.terminal_display.viewport.dimentions.height,
            'data'          : array.copy(self.terminal_display.viewport.data),
            'color_table'   : self.terminal_display.viewport.palette}

    # TODO snapshot of a frame
    cdef save_screen(self):
        x=1