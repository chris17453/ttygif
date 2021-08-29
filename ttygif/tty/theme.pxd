# cython: profile=True
# cython: binding=True
# cython: language_level=2
from cpython cimport array
from image cimport rect,image,point
from libc.stdint cimport uint32_t, int64_t,uint16_t,uint8_t,int32_t


cdef class layer:
    cdef uint16_t    z_index
    cdef str         file
    cdef str         path
    cdef str         mode  
    cdef str         name
    cdef rect        outer
    cdef rect        inner
    cdef rect        bounds
    cdef rect        dst
    cdef str         center
    cdef str         copy_mode
    cdef uint16_t    transparent


    cdef image       image
    cdef debug    (self)
    cdef load_file (self,array.array)

    

cdef class theme:    
    cdef str         name
    cdef uint16_t    title_x
    cdef uint16_t    title_y
    cdef uint16_t    title_foreground
    cdef uint16_t    title_background
    cdef uint16_t    title_font
    cdef float       title_font_size
    cdef str         path
    cdef str         font
    cdef uint16_t    width
    cdef uint16_t    height
    cdef uint16_t    background
    cdef uint16_t    foreground
    cdef uint16_t    default_background
    cdef uint16_t    default_foreground
    cdef uint16_t    transparent
    cdef uint16_t    colors
    cdef array.array palette
    cdef rect        padding
    cdef layer       layer1
    cdef layer       layer2
    cdef layer       layer3
    cdef layer       layer4
    cdef layer       layer5
    cdef init(self)
    cdef update_layer(self, layer temp)
    cdef auto(self)
