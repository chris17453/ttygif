from cpython cimport array
from libc.string cimport memset
from .font cimport font
from .image cimport image

cdef create_default_palette():
    cdef array.array palette=array.array('B',[  # 16 System Colors
            0,0,0,  128,0,0,  0,128,0,  128,128,0,
            0,0,128,  128,0,128,  0,128,128,  192,192,192,
            128,128,128,  255,0,0,  0,255,0,  255,255,0,
            0,0,255,  255,0,255,  0,255,255,  255,255,255,
            # xterm palette
            0,0,0,  0,0,95,  0,0,135,  0,0,175,  0,0,215,  0,0,255,
            0,95,0,  0,95,95,  0,95,135,  0,95,175,  0,95,215,  0,95,255,
            0,135,0,  0,135,95,  0,135,135,  0,135,175,  0,135,215,  0,135,255,
            0,175,0,  0,175,95,  0,175,135,  0,175,175,  0,175,215,  0,175,255,
            0,215,0,  0,215,95,  0,215,135,  0,215,175,  0,215,215,  0,215,255,
            0,255,0,  0,255,95,  0,255,135,  0,255,175,  0,255,215,  0,255,255,
            95,0,0,  95,0,95,  95,0,135,  95,0,175,  95,0,215,  95,0,255,
            95,95,0,  95,95,95,  95,95,135,  95,95,175,  95,95,215,  95,95,255,
            95,135,0,  95,135,95,  95,135,135,  95,135,175,  95,135,215,  95,135,255,
            95,175,0,  95,175,95,  95,175,135,  95,175,175,  95,175,215,  95,175,255,
            95,215,0,  95,215,95,  95,215,135,  95,215,175,  95,215,215,  95,215,255,
            95,255,0,  95,255,95,  95,255,135,  95,255,175,  95,255,215,  95,255,255,
            135,0,0,  135,0,95,  135,0,135,  135,0,175,  135,0,215,  135,0,255,
            135,95,0,  135,95,95,  135,95,135,  135,95,175,  135,95,215,  135,95,255,
            135,135,0,  135,135,95,  135,135,135,  135,135,175,  135,135,215,  135,135,255,
            135,175,0,  135,175,95,  135,175,135,  135,175,175,  135,175,215,  135,175,255,
            135,215,0,  135,215,95,  135,215,135,  135,215,175,  135,215,215,  135,215,255,
            135,255,0,  135,255,95,  135,255,135,  135,255,175,  135,255,215,  135,255,255,
            175,0,0,  175,0,95,  175,0,135,  175,0,175,  175,0,215,  175,0,255,
            175,95,0,  175,95,95,  175,95,135,  175,95,175,  175,95,215,  175,95,255,
            175,135,0,  175,135,95,  175,135,135,  175,135,175,  175,135,215,  175,135,255,
            175,175,0,  175,175,95,  175,175,135,  175,175,175,  175,175,215,  175,175,255,
            175,215,0,  175,215,95,  175,215,135,  175,215,175,  175,215,215,  175,215,255,
            175,255,0,  175,255,95,  175,255,135,  175,255,175,  175,255,215,  175,255,255,
            215,0,0,  215,0,95,  215,0,135,  215,0,175,  215,0,215,  215,0,255,
            215,95,0,  215,95,95,  215,95,135,  215,95,175,  215,95,215,  215,95,255,
            215,135,0,  215,135,95,  215,135,135,  215,135,175,  215,135,215,  215,135,255,
            215,175,0,  215,175,95,  215,175,135,  215,175,175,  215,175,215,  215,175,255,
            215,215,0,  215,215,95,  215,215,135,  215,215,175,  215,215,215,  215,215,255,
            215,255,0,  215,255,95,  215,255,135,  215,255,175,  215,255,215,  215,255,255,
            255,0,0,  255,0,95,  255,0,135,  255,0,175,  255,0,215,  255,0,255,
            255,95,0,  255,95,95,  255,95,135,  255,95,175,  255,95,215,  255,95,255,
            255,135,0,  255,135,95,  255,135,135,  255,135,175,  255,135,215,  255,135,255,
            255,175,0,  255,175,95,  255,175,135,  255,175,175,  255,175,215,  255,175,255,
            255,215,0,  255,215,95,  255,215,135,  255,215,175,  255,215,215,  255,215,255,
            255,255,0,  255,255,95,  255,255,135,  255,255,175,  255,255,215,  255,255,255,
            8,8,8,  18,18,18,  28,28,28,  38,38,38,  48,48,48,  58,58,58,  68,68,68,
            78,78,78,  88,88,88,  98,98,98,  108,108,108,  118,118,118,  128,128,128,
            138,138,138,  148,148,148,  158,158,158,  168,168,168,  178,178,178,  188,188,188,
            198,198,198,  208,208,208,  218,218,218,  228,228,228,  238,238,238
            ])
    return palette


# returns a byte array set with an initial value
cdef create_array(int size,int init_value):
    cdef array.array data=array.array('B')
    array.resize(data,size)
    memset(data.data.as_voidptr, init_value, len(data) * sizeof(char))
    return data

# super fast memory copy
cdef copy_image(image src_image,int src_x1,int src_y1,int src_x2,int src_y2,image dst_image,int dst_x1,int dst_y1,int dst_x2,int dst_y2,object mode):
    cdef int x3
    cdef int y3
    if mode==None:
        mode='simple'
    if mode=='simple':
        
        for y in range(src_y1,src_y2):
            for x in range(src_x1,src_x2):
                pixel=src_image.get_pixel(x,y)
                #print x,y,pixel
                x3=x+dst_x1-src_x1
                y3=y+dst_y1-src_y1
                dst_image.put_pixel(x3,y3,pixel)


# shifts an image buffer up 1 line and fills the newly created space with x value
cdef shift_buffer(image src_image,int init_value):
    cdef int buffer_length=src_image.dimentions.length
    cdef int index=src_image.dimentions.width
    
    for i in range(0,index):
        buffer.pop(0)
        buffer.pop(0)
        buffer.pop(0)
    cdef int row_pos=buffer_length-src_image.dimentions.stride
    array.resize(src_image.data,buffer_length)  
    memset(&src_image.data.data.as_uchars[row_pos],init_value,src_image.dimentions.length)

cdef match_color_index(r,g,b,palette):
    last_distance=-1
    mappeded_color=-1
    cdef int mr
    cdef int mg
    cdef int mb

    color_table_len=len(palette)
    for i in range(0,color_table_len,3):
        mr=palette[i]
        mg=palette[i+1]
        mb=palette[i+2]
        color_distance=(r-mr)*(r-mr)+(g-mg)*(g-mg)+(b-mb)*(b-mb)
        if last_distance==-1 or color_distance<last_distance:
            last_distance=color_distance
            mappeded_color=i

    return mappeded_color


# todo account for color table size mismatch, crud on new table, and reindexing for best color palette...
cdef remap(src_palette,src_pixels,dst_palette):
    hash_map=[0]*len(src_palette)
    # remap the colors from the source to the dest
    cdef int mr
    cdef int mg
    cdef int mb
    for i in range(0,len(src_palette),3):
        mr=color_table[i]
        mg=color_table[i+1]
        mb=color_table[i+2]
        new_index=match_color_index(mr,mg,mb,dst_palette)
        hash_map[i]=new_index

    # reindex the pixels
    src_pixel_len=len(src_pixels)
    for i in range(0,src_pixel_len):
        original_index=src_pixels[i]
        #replace srrc data pixel...
        src_pixels[i]=hash_map[original_index]

