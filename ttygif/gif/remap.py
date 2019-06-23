





def match_color_index(r,g,b,color_table):
    last_distance=-1
    mappeded_color=-1

    color_table_len=len(color_table)
    for i in range(0,color_table_len):
        color=color_table[i]
        color_distance=(r-color[0])*(r-color[0])+(g-color[1])*(g-color[1])+(b-color[2])*(b-color[2])
        if last_distance==-1 or color_distance<last_distance:
            last_distance=color_distance
            mappeded_color=i

    return mappeded_color

# todo account for color table size mismatch, crud on new table, and reindexing for best color palette...
def remap(src_color_table,src_pixels,dst_color_table,dst_pixels):
    hash_map=[0]*len(src_color_table)
    # remap the colors from the source to the dest
    for i in src_color_table:
        src_color=src_color_table[i]
        new_index=match_color_index(src_color[0],src_color[1],src_color[2])
        hash_map[i]=new_index

    # reindex the pixels
    src_pixel_len=len(src_pixels)
    for i in range(0,src_pixel_len):
        original_index=src_pixels[i]
        #replace srrc data pixel...
        src_pixels[i]=has_map[original_index]


