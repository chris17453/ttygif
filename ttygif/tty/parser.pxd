from .terminal_graphics cimport terminal_graphics
import re



cdef class term_parser:
    cdef object debug_mode
    cdef object sequence
    cdef int    sequence_pos
    cdef object extra_text
    cdef double last_timestamp
    cdef ascii_safe(self,text)
    cdef info(self,text)
    cdef clear_sequence(self)
    cdef rgb_to_palette(self,r,g,b)
    cdef remap_character(self,character)
    cdef set_mode(self,cmd)
    cdef reset_mode(self,cmd)
    cdef render_to_buffer(self,terminal_graphics frame)
    cdef stream_2_sequence(self,text,timestamp,delay)
    cdef last_frame(self)
    cdef has_escape(self,text)
    cdef add_event(self,event)
    cdef add_text_sequence(self,text,timestamp,delay)
    cdef add_command_sequence(self,esc_type,command,params,groups,name,timestamp,delay)
    cdef debug_sequence(self)