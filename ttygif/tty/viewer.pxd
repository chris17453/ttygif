cdef class viewer:
    cdef public:
        cdef int   debug
        
        cdef int   viewport_px_width
        cdef int   viewport_px_height
        cdef int   viewport_char_height
        cdef int   viewport_char_width
        cdef int   background_color
        cdef int   foreground_color
        cdef char* window