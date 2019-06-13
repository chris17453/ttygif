from cpython cimport array
import array

cdef class font:

    char *      name          =""
    cdef int        chars_per_line=0
    cdef int        lines         =0
    cdef int        width         =0
    cdef int        height        =0
    cdef int        font_width    =0
    cdef int        font_height   =0
    cdef int        spacing_x     =0
    cdef int        spacing_y     =0
    cdef int        offset_x      =0
    cdef int        offset_y      =0
    cdef array.array color_table
    cdef int        transparent   =0
    cdef array.array graphics
