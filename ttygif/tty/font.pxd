# cython: profile=True
# cython: linetrace=True
# cython: binding=True
# cython: language_level=2

from cpython cimport array


cdef class font:
    cdef str          name
    cdef int          pointsize
    cdef int          height
    cdef int          width
    cdef int          ascent
    cdef int          inleading
    cdef int          exleading
    cdef int          charset
    cdef array.array  graphic
    cdef object       offset