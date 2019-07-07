# cython: profile=True
# cython: linetrace=True
# cython: binding=True
# cython: language_level=2

from cpython cimport array
from .image  cimport image
from .font   cimport font
from .theme  cimport theme
from .display_state cimport display_state


cdef class terminal_graphics:
    cdef array.array    data
    cdef font           font
    cdef image          viewport
    cdef image          screen
    cdef image          alt_screen
    cdef display_state  state
    cdef display_state  alt_state
    cdef object         display_alt_screen
    cdef theme          theme

    cdef alternate_screen_on(self)
    cdef alternate_screen_off(self)
    cdef write(self,int character)
    cdef draw_string(self,x,y,data)
    cdef scroll_buffer(self)
    cdef draw_character(self,int character,int x,int y,int foreground_color,int background_color)
    cdef get_text(self)
    cdef foreground_from_rgb(self,r,g,b)
    cdef background_from_rgb(self,r,g,b)
    cdef set_foreground(self,color)
    cdef set_background(self,color)
    cdef set_background(self,color)
    cdef render(self)
