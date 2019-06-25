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
    cdef get_position(self,int x,int y)
    cdef get_pixel(self,int x,int y)
    cdef put_pixel(self,int x,int y,pixel)
    cdef clear(self,int init_value=0)
