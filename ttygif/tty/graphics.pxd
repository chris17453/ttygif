

cdef create_default_palette()
cdef create_array(int size,int init_value)
cdef copy_image(image src_image,src_x1,src_y1,src_x2,src_y2,)
                image dst_image,dst_x1,dst_y1,dst_x2,dst_y2,mode)
cdef shift_buffer(image src_image,int init_value)
def match_color_index(r,g,b,color_table)
def remap(src_color_table,src_pixels,dst_color_table)
