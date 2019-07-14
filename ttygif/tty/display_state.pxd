# cython: profile=True
# cython: linetrace=True
# cython: binding=True
# cython: language_level=2
from libc.stdint cimport uint32_t, int64_t,uint16_t,uint8_t,int32_t

cdef class display_state:
    cdef uint8_t         width
    cdef uint8_t         height
    cdef int             cursor_x
    cdef int             cursor_y
    cdef int             saved_cursor_x
    cdef int             saved_cursor_y
    cdef uint8_t         default_foreground
    cdef uint8_t         default_background
    cdef uint8_t         foreground
    cdef uint8_t         background
    cdef int             scroll
    cdef int             scroll_top
    cdef int             scroll_bottom
    cdef object          reverse_video
    cdef object          bold 
    cdef object          text_mode
    cdef object          autowrap
    cdef object          pending_wrap
    cdef object          display_cursor
                 
    cdef show_cursor(self)
    cdef hide_cursor(self)
    cdef text_mode_on(self)
    cdef text_mode_off(self)
    cdef autowrap_on(self)
    cdef autowrap_off(self)
    cdef set_scroll_region(self,top,bottom)
    cdef check_bounds(self)
    cdef cursor_up(self,int distance)
    cdef cursor_down(self,int distance)
    cdef cursor_left(self,int distance)
    cdef cursor_right(self,int distance)
    cdef cursor_absolute_x(self,position)
    cdef cursor_absolute_y(self,position)
    cdef cursor_save_position(self)
    cdef cursor_restore_position(self)
    cdef cursor_get_position(self)
    cdef cursor_absolute(self,position_x,position_y)
    cdef set_background(self,int color)
    cdef set_foreground(self,int color)
