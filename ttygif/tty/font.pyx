from cpython cimport array
import array

cdef class font:

    char *      name          =""
    cint        chars_per_line=0
    cint        lines         =0
    cint        width         =0
    cint        height        =0
    cint        font_width    =0
    cint        font_height   =0
    cint        spacing_x     =0
    cint        spacing_y     =0
    cint        offset_x      =0
    cint        offset_y      =0
    array.array color_table
    cint        transparent   =0
    array.array graphics
