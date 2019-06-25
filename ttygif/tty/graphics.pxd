from .display_state cimport display_state
from .image cimport image


cdef create_default_palette()
cdef create_array(int size,int init_value)
cdef copy_image(image src_image,int src_x1,int src_y1,int src_x2,src_y2,
                image dst_image,int dst_x1,int dst_y1,int dst_x2,dst_y2,object mode)
cdef shift_buffer(image src_image,int init_value)
cdef match_color_index(r,g,b,color_table)
cdef remap(src_color_table,src_pixels,dst_color_table)