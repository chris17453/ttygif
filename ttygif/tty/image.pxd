from cpython cimport array

# sets bounding paramaters for image transformations
cdef class bounds:
    cdef public int width
    cdef public int height
    cdef public int stride
    cdef public int length
    cdef public int bytes_per_pixel

cdef class image:
    cdef array.array data
    cdef bounds      dimentions
    cdef array.array palette
    cdef create_buffer(self,size,init_value)
    cdef get_position(self,int x,int y)
    cdef get_pixel(self,int x,int y)
    cdef put_pixel(self,int x,int y,pixel)
    cdef clear(self,int init_value)
