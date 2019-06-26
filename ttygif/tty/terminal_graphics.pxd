from cpython cimport array
from .image cimport image
from .display_state cimport display_state


cdef class terminal_graphics:
    cdef array.array    data
    cdef font.          font
    cdef image          viewport
    cdef image          character_buffer
    cdef display_state character_buffer_state

    cdef write(self,int character)
    cdef draw_string(self,x,y,data)
    cdef draw_character(self,int character,int x,int y,int offset,int foreground_color,int background_color)
    cdef get_text(self)
    cdef foreground_from_rgb(self,r,g,b)
    cdef background_from_rgb(self,r,g,b)
    cdef set_foreground(self,color)
    cdef set_background(self,color)
    cdef render(self)
