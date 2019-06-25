cdef class display_state:
    cdef public int             width
    cdef public int             height
    cdef public int             cursor_x
    cdef public int             cursor_y
    cdef public int             default_foreground
    cdef public int             default_background
    cdef public int             foreround
    cdef public int             background
    cdef public object          reverse_video
    cdef public object          bold 

    cdef check_bounds(self)
    cdef cursor_up(self)
    cdef cursor_down(self)
    cdef cursor_left(self)
    cdef cursor_right(self)
    cdef cursor_absolute_x(self,position)
    cdef cursor_absolute_y(self,position)
    cdef cursor_absolute(self,position_x,position_y)
