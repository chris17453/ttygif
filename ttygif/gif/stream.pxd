# cython: language_level=2
import os
import struct 

cdef class DataStream:
    cdef object FILE_NULL
    cdef object FILE_NOT_FOUND
    cdef object FILE_OBJECT_NULL
    cdef object OUT_OF_BOUNDS
    cdef object INVALID_POSITION
    cdef object mode
    cdef public long   pos
    cdef long   file_length
    cdef object file
    cdef object file_object
    cdef long  pinned_position

    cdef validate_file(self)
    cdef validate_bounds(self)
    cdef open(self)
    cdef pin(self)
    cdef seek(self,position)
    cdef rewind(self)
    cdef get_file_size(self)
    
