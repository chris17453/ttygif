# cython: profile=True
# cython: linetrace=True
# cython: binding=True
# cython: language_level=2

from cpython cimport array

# sets bounding paramaters for image transformations
cdef class bounds:
    cdef public int width
    cdef public int height
    cdef public int stride
    cdef public int length
    cdef public int bytes_per_pixel

cdef class point:
    cdef int left
    cdef int top

cdef class rect:
    cdef int left
    cdef int top
    cdef int right
    cdef int bottom
    cdef int width
    cdef int height
    cdef percent_x(self,float x)
    cdef percent_y(self,float y)
    cdef get_x_percent(self,float x)
    cdef get_y_percent(self,float y)
    cdef point1(self)
    cdef point2(self)

cdef class image:
    cdef array.array data
    cdef bounds      dimentions
    cdef array.array palette
    cdef create_buffer(self,size,init_value)
    cdef get_position(self,int x,int y)
    cdef get_pixel(self,int x,int y)
    cdef put_pixel(self,int x,int y,pixel)
    cdef clear(self,int init_value)
    cdef copy(self,image dst_image,rect src,point dst)
    cdef copy_scale(self,image dst_image,rect src,rect dst)
    cdef copy_tile(self,image dst_image,rect src,rect dst)
    cdef copy_9slice(self,image dst_image,rect outer,rect inner,rect dst)
