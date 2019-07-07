# cython: profile=True
# cython: binding=True
# cython: language_level=2
from cpython cimport array

cdef class theme:    
    cdef str         name
    cdef int         background
    cdef int         foreground
    cdef int         default_background
    cdef int         default_foreground
    cdef int         colors
    cdef array.array palette
    