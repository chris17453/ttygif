from cpython cimport array
import array

cdef class font_map:

    cdef char *name
    cdef int        chars_per_line
    cdef int        lines         
    cdef int        width         
    cdef int        height        
    cdef int        font_width    
    cdef int        font_height   
    cdef int        spacing_x     
    cdef int        spacing_y     
    cdef int        offset_x      
    cdef int        offset_y      
    cdef array.array color_table
    cdef int        transparent
    cdef array.array graphics
