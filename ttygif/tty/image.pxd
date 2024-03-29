# cython: profile=True
# cython: binding=True
# cython: language_level=2

from cpython cimport array
from libc.stdint cimport uint32_t, int64_t,uint16_t,uint8_t,int32_t,int16_t


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
    cdef rect get_rect(self)
    cdef array.array create_buffer(self,size,init_value)
    cdef uint32_t get_position(self,int x,int y)
    cdef get_pixel(self,int x,int y)
    cdef uint8_t get_pixel_1byte(self,int x,int y)
    cdef void get_pixel_3byte(self,int x,int y,uint8_t[3] element)
    cdef void put_pixel(self,int x,int y,pixel)
    cdef void put_pixel_1byte(self,uint16_t x,uint16_t y,uint8_t pixel)
    cdef void put_pixel_3byte(self,int x,int y,uint8_t[3] pixel)
    cdef put_pixel_rgb(self,int x,int y,int r,int g,int b)
    cdef clear(self,uint8_t[] pixel)
    cdef remap_image(self,array.array palette,int16_t transparent)
    cdef match_color_index(self,int r,int g,int b)
    cdef copy(self,image dst_image,rect src,rect dst,int16_t transparent)
    cdef copy_remap(self,image dst_image,rect src,point dst,int16_t transparent)
    cdef copy_scale(self,image dst_image,rect src,rect dst,int16_t transparent)
    cdef copy_tile(self,image dst_image,rect src,rect dst,int16_t transparent)
    cdef copy_9slice(self,image dst_image,rect outer,rect inner,rect dst,int16_t transparent,str mode)
    cdef copy_3slice(self,image dst_image,rect outer,rect inner,rect dst,int16_t transparent,str mode)
  
    cdef debug(self)
