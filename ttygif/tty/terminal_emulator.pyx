# cython: linetrace=True
from cpython cimport array
from .parser cimport term_parser
from .terminal_graphics import terminal_graphics
from .font cimport font
from .fonts cimport vga_font



# main interface for terminal emulation
cdef class terminal_emulator:
    
    def __cinit__(self,width=640,height=480,char_width=None,char_height=None,debug=None):
        self.debug_mode      =debug
        self.underlay_flag   =None
        self.init(width,height,char_width,char_height,debug)

    cdef init(self,width,height,char_width,char_height,debug):
        self.parser          = term_parser(debug_mode=debug)
        
        self.terminal_graphics= terminal_graphics(character_width =char_width,
                                                 character_height=char_height,
                                                 viewport_width  =width,
                                                 viewport_height =height,
                                                 image_font=vga_font)

   
    # this pre computes the regex into commands and stores into an array
    cdef add_event(self,event):
        self.parser.add_event(event)
    
    cdef render(self):
        self.parser.render_to_buffer(terminal_graphics)
        self.terminal_graphics.render()

    # this is for returning screen data to other functions
    cdef get(self):
        return {    
            'width'         : self.terminal_graphics.viewport.dimentions.width,
            'height'        : self.terminal_graphics.viewport.dimentions.height,
            'data'          : array.copy(self.terminal_graphics.viewport.data),
            'color_table'   : self.terminal_graphics.viewport.palette}

    # TODO snapshot of a frame
    cdef save_screen(self):
        x=1
