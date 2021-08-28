# cython: profile=True
# cython: binding=True
# cython: language_level=2
from cpython cimport array
from image cimport rect,image,point

cdef class layer:
    cdef int         z_index
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
    cdef int         transparent


    cdef image       image
    cdef debug    (self)
    cdef load_file (self,array.array)

    

cdef class theme:    
    cdef str         name
    cdef str         path
    cdef str         font
    cdef int         width
    cdef int         height
    cdef int         background
    cdef int         foreground
    cdef int         default_background
    cdef int         default_foreground
    cdef int         transparent
    cdef int         colors
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
