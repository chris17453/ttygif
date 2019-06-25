from cpython cimport array

# sets bounding paramaters for image transformations
cdef class bounds:
    cdef int width
    cdef int height
    cdef int stride
    cdef int length
    cdef int bytes_per_pixel

cdef class image:
    cdef array.array data
    cdef bounds      dimentions
    cdef array.array palette
    cdef get position(int x,int y)
    cdef get_pixel(int x,int y)
    cdef put_pixel(int x,int y,pixel)
    cdef clear(int init_value)
