# cython: profile=True
# cython: linetrace=True
# cython: binding=True
# cython: language_level=2

from cpython cimport array
from libc.stdint cimport uint32_t, int64_t,uint16_t,uint8_t,int32_t


# sets bounding paramaters for image transformations
cdef class bounds:
    cdef public int width
    cdef public int height
    cdef public int stride
    cdef public int length
    cdef public int bytes_per_pixel
    cdef debug(self)

cdef class point:
    cdef int left
    cdef int top
    cdef debug(self)


cdef class rect:
    cdef int left
    cdef int top
    cdef int right
    cdef int bottom
    cdef int width
    cdef int height
    cdef update(self)
    cdef percent_x(self,float x)
    cdef percent_y(self,float y)
    cdef get_x_percent(self,float x)
    cdef get_y_percent(self,float y)
    cdef point1(self)
    cdef point2(self)
    cdef debug(self)

cdef class image:
    cdef int         transparent
    cdef array.array data
    cdef bounds      dimentions
    cdef array.array palette
    cdef int         length
    cdef get_rect(self)
    cdef create_buffer(self,size,init_value)
    cdef get_position(self,int x,int y)
    cdef get_pixel(self,int x,int y)
    cdef put_pixel(self,int x,int y,pixel)
    cdef put_pixel_rgb(self,int x,int y,int r,int g,int b)
    cdef clear(self,uint8_t[] pixel)
    cdef remap_image(self,array.array palette)
    cdef match_color_index(self,int r,int g,int b)
    cdef copy(self,image dst_image,rect src,point dst)
    cdef copy_remap(self,image dst_image,rect src,point dst)
    cdef copy_scale(self,image dst_image,rect src,rect dst)
    cdef copy_tile(self,image dst_image,rect src,rect dst)
    cdef copy_9slice(self,image dst_image,rect outer,rect inner,rect dst,str mode)
    cdef debug(self)
