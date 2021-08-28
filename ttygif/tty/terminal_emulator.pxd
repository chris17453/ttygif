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
    cdef public object font_name
    cdef public object default_font
    cdef public object theme_name
    cdef public int    last_event
    cdef public object show_state
    cdef public object no_autowrap
    cdef public object underlay
        


    cdef init(self,width,heigh,char_width,char_height,debug,last_event,show_state)
    cdef add_event(self,event)
    cdef render(self,time)
    cdef get(self)
    cdef get_dimentions(self)
    cdef last_frame(self)
    cdef debug_sequence(self)
    cdef save_screen(self)
