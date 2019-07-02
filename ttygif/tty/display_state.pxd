# cython: profile=True
# cython: linetrace=True
# cython: binding=True
# cython: language_level=2

cdef class display_state:
    cdef public int             width
    cdef public int             height
    cdef public int             cursor_x
    cdef public int             cursor_y
    cdef public int             saved_cursor_x
    cdef public int             saved_cursor_y
    cdef public int             default_foreground
    cdef public int             default_background
    cdef public int             foreground
    cdef public int             background
    cdef public int             scroll
    cdef public int             scroll_top
    cdef public int             scroll_bottom
    cdef public object          reverse_video
    cdef public object          bold 
    cdef public object          text_mode
    cdef public object          autowrap
    cdef public object          pending_wrap
            
        
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
