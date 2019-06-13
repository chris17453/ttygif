from cpython cimport array
import array

class font:

    name          =""
    cdef cint        chars_per_line=0
    cdef cint        lines         =0
    cdef cint        width         =0
    cdef cint        height        =0
    cdef cint        font_width    =0
    cdef cint        font_height   =0
    cdef cint        spacing_x     =0
    cdef cint        spacing_y     =0
    cdef cint        offset_x      =0
    cdef cint        offset_y      =0
    cdef array.array color_table   =array.array('B',[0x00,0x00,0x00,
                                                     0xFF,0xFF,0xFF])
    cdef cint        transparent   =0
    cdef array.array graphics=array.array('B')
