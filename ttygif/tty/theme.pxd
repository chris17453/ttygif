# cython: profile=True
# cython: binding=True
# cython: language_level=2
from cpython cimport array
from image cimport rect,image

cdef class layer:
    cdef int         z_index
    cdef str         file
    cdef str         mode  
    cdef str         name
    cdef rect        outer
    cdef rect        inner
    cdef rect        bounds
    cdef point       dst


    cdef image       image
    cdef debug    (self)
    cdef load_file(self)

    

cdef class theme:    
    cdef str         name
    cdef int         background
    cdef int         foreground
    cdef int         default_background
    cdef int         default_foreground
    cdef int         colors
    cdef array.array palette
    cdef rect        padding
    cdef layer       layer1
    cdef layer       layer2
    cdef layer       layer3
    cdef layer       layer4
    cdef layer       layer5
    cdef init(self)
    cdef auto(self)
