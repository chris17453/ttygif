# cython: profile=True
# cython: linetrace=True
# cython: binding=True
# cython: language_level=2

from .parser cimport term_parser
from .terminal_graphics cimport terminal_graphics


# main interface for terminal emulation
cdef class terminal_emulator:
    cdef public term_parser          parser
    cdef public terminal_graphics    terminal_graphics
    cdef public object underlay_flag
    cdef public object debug_mode


    cdef init(self,width,heigh,char_width,char_height,font_name,debug)
    cdef add_event(self,event)
    cdef render(self)
    cdef get(self)
    cdef get_dimentions(self)
    cdef last_frame(self)
    cdef save_screen(self)
