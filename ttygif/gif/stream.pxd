# cython: language_level=2
import os
import struct 

cdef class DataStream:
    cdef char *FILE_NULL
    cdef char *FILE_NOT_FOUND
    cdef char *FILE_OBJECT_NULL
    cdef char *OUT_OF_BOUNDS
    cdef char *INVALID_POSITION
    cdef char *mode
    cdef int pos
    cdef long file_length
    cdef char *file

    cdef validate_file(self)
    cdef validate_bounds(self)
    cdef open(self)
    cdef close(self)
    cdef pin(self)
    cdef seek(self,position)
    cdef rewind(self)
    cdef get_file_size(self)
    cdef read(self,length=1,word=None,char=None,byte=None,string=None)
    cdef write_byte(self,byte)
    cdef write_word(self,word)
    cdef write_string(self,string,length)
    cdef char(self,length=1,ptr=None,value=None)
    cdef byte(self,length=1,ptr=None,value=None,eod=None)
    cdef string(self,length=1,ptr=None,value=None,EOD=None)
    cdef word(self,length=1,ptr=None,value=None,EOD=None)
    cdef print_bit(self,byte,length=8)
    cdef bit(self,byte,index,length=None)
