# cython: profile=True
# cython: linetrace=True
# cython: binding=True
# cython: language_level=2


# sets bounding paramaters for image transformations
from cpython cimport array
from libc.string cimport memset

cdef class bounds:
    def __cinit__(self,int width,int height,int bytes_per_pixel=1):
        self.width           =width
        self.height          =height
        self.stride          =width*bytes_per_pixel
        self.length          =self.stride*height
        self.bytes_per_pixel =bytes_per_pixel

    cdef debug(self):
        print("  height:  {0}".format(self.height))
        print("  width:   {0}".format(self.width))
        print("  stride:  {0}".format(self.stride))
        print("  length:  {0}".format(self.length))
        print("  bytes_per_pixel: {0}".format(self.bytes_per_pixel))


cdef class rect:
    def __cinit__(self,int left,int top,int right,int bottom):
        self.left   =left
        self.top    =top
        self.right  =right
        self.bottom =bottom
        self.height =bottom-top+1
        self.width  =right-left+1

    cdef update(self):        
        self.height =self.bottom-self.top+1
        self.width  =self.right-self.left+1


    cdef percent_x(self,float x):
        cdef float percent=x/float(self.width)
        return percent

    cdef percent_y(self,float y):
        cdef float percent=y/float(self.height)
        return percent

    cdef get_x_percent(self,float x):
        cdef float pos=x*float(self.width)
        cdef int   calc_x=int(pos)+self.left
        return calc_x

    cdef get_y_percent(self,float y):
        cdef float pos=y*float(self.height)
        cdef int   calc_y=int(pos)+self.top
        return calc_y

    cdef point1(self):
        return point(self.left,self.top)

    cdef point2(self):
        return point(self.right,self.bottom)

    cdef debug(self):
        print("RECT")
        print("  left:   {0}".format(self.left))
        print("  top:    {0}".format(self.top))
        print("  right:  {0}".format(self.right))
        print("  bottom: {0}".format(self.bottom))
        print("  height: {0}".format(self.height))
        print("  width:  {0}".format(self.width))


cdef class point:
    def __cinit__(self,int left,int top):
        self.left   =left
        self.top    =top
    cdef debug(self):
        print("POINT")
        print("  left:   {0}".format(self.left))
        print("  top:    {0}".format(self.top))

# image class, holds image metrics, data and palette        
cdef class image:
    def __cinit__(self,int bytes_per_pixel,int width,int height,array.array palette,int init_value):
        
        self.dimentions=bounds(width,height,bytes_per_pixel)
        self.data      =self.create_buffer(self.dimentions.length,init_value)
        if palette:
            self.palette   =palette
    
    cdef get_rect(self):
        return rect(0,0,self.dimentions.width-1,self.dimentions.height-1)

    cdef create_buffer(self,size,init_value):
        cdef array.array data=array.array('B')
        array.resize(data,size)
        memset(data.data.as_voidptr, init_value, len(data) * sizeof(char))
        return data
    
    cdef get_position(self,int x,int y):
        cdef int pos=self.dimentions.stride*y+x*self.dimentions.bytes_per_pixel
        return pos

    # get a pixel of X stride
    cdef get_pixel(self,int x,int y):
        cdef int pos=x*self.dimentions.bytes_per_pixel+y*self.dimentions.stride
        if self.dimentions.bytes_per_pixel==1:
            return self.data[pos]
        else:
            pixel=[0]*self.dimentions.bytes_per_pixel
            for i in xrange(0,self.dimentions.bytes_per_pixel):
                pixel[i]=self.data[pos+i]
            return pixel

    # put a pixel of X stride
    cdef put_pixel(self,int x,int y,pixel):
        cdef int pix_byte
        if x<0 or x>=self.dimentions.width:
            return
        if y<0 or y>=self.dimentions.height:
            return
        cdef int pos=self.get_position(x,y)
        if self.dimentions.bytes_per_pixel==1:
            self.data[pos]=pixel
        else:
            for i in xrange(0,self.dimentions.bytes_per_pixel):
                pix_byte=pixel[i]
                self.data[pos+i]=pix_byte

    cdef put_pixel_rgb(self,int x,int y,int r,int g,int b):
        pixel=self.match_color_index(r,g,b)
        self.put_pixel(x,y,pixel)

    
    cdef clear(self,int init_value):
        memset(self.data.data.as_voidptr, init_value, self.dimentions.length )

    cdef remap_image(self,array.array palette):
        cdef rect src=self.get_rect()
        cdef point dst=src.point1()

        cdef image tmp=image(self.dimentions.bytes_per_pixel,self.dimentions.width,self.dimentions.height,palette,0)
        self.copy_remap(tmp,src,dst)
        self.data=tmp.data
        self.palette=tmp.palette


    cdef match_color_index(self,int r,int g,int b):
        cdef double last_distance=-1
        cdef double color_distance
        cdef int mapped_color=0
        cdef int mr
        cdef int mg
        cdef int mb
        #print r,g,b
        cdef int color_table_len=len(self.palette)
        cdef int i
        for i in xrange(0,color_table_len,3):
            mr=self.palette[i]
            mg=self.palette[i+1]
            mb=self.palette[i+2]
            color_distance=(r-mr)*(r-mr)+(g-mg)*(g-mg)+(b-mb)*(b-mb)
            if last_distance==-1 or color_distance<last_distance:
                last_distance=color_distance
                mapped_color=i/3

        if mapped_color>255:
            #print color_distance
            raise Exception("Color value to high")

        return mapped_color



    # plain copy 1-1
    cdef copy(self,image dst_image,rect src,point dst):
        cdef int x
        cdef int y
        cdef int r
        cdef int g
        cdef int b

        if dst.left==-1:
            dst.left=dst_image.dimentions.width-1-(src.right-src.left)
            #dst.right+=dst.left
        if dst.top==-1:
            dst.top=dst_image.dimentions.height-1-(src.bottom-src.top)


        if dst.left<0:
            dst.left+=dst_image.dimentions.width-1
        if dst.top<0:
            dst.top+=dst_image.dimentions.height-1

        for y in xrange(0,src.height):
            for x in xrange(0,src.width):
                pixel=self.get_pixel(x+src.left,y+src.top)
                if pixel==self.transparent:
                    continue
                dst_image.put_pixel(x,dst.top+y,pixel)

    cdef copy_remap(self,image dst_image,rect src,point dst):
        cdef int x
        cdef int y
        cdef int r
        cdef int g
        cdef int b

        if dst.left==-1:
            dst.left=dst_image.dimentions.width-1-(src.right-src.left)
            #dst.right+=dst.left
        if dst.top==-1:
            dst.top=dst_image.dimentions.height-1-(src.bottom-src.top)


        if dst.left<0:
            dst.left+=dst_image.dimentions.width-1
        if dst.top<0:
            dst.top+=dst_image.dimentions.height-1

        for y in xrange(0,src.height):
            for x in xrange(0,src.width):
                pixel=self.get_pixel(x+src.left,y+src.top)
                r=self.palette[pixel*3+0]
                g=self.palette[pixel*3+1]
                b=self.palette[pixel*3+2]
                dst_image.put_pixel_rgb(dst.left+x,dst.top+y,r,g,b)
                

    # strech src to fir dest
    cdef copy_scale(self,image dst_image,rect src,rect dst):
        cdef int x
        cdef int y 
        cdef int x3
        cdef int y3
        cdef float fx
        cdef float fy
        
        for y in xrange(0,dst.height):
            for x in xrange(0,dst.width):
                # percentage
                fx=dst.percent_x(x)
                fy=dst.percent_y(y)

                x3=src.get_x_percent(fx)
                y3=src.get_y_percent(fy)

                pixel=self.get_pixel(x3,y3)                
                #pixel=dst_image.match_color_index(self.palette[pixel*3],self.palette[pixel*3+1],self.palette[pixel*3+2])
                dst_image.put_pixel(x+dst.left,y+dst.top,pixel)

    # tile src to dest
    cdef copy_tile(self,image dst_image,rect src,rect dst):
        cdef int x
        cdef int y 
   
        for y in xrange(0,dst.height):
            for x in xrange(0,dst.width):
                
                x3=x%src.width+src.left
                y3=y%src.height+src.top
                
                pixel=self.get_pixel(x3,y3)
                
                #pixel=dst_image.match_color_index(self.palette[pixel*3],self.palette[pixel*3+1],self.palette[pixel*3+2])
                dst_image.put_pixel(x+dst.left,y+dst.top,pixel)




    # template image for adaptive scaling via grid and looping
    cdef copy_9slice(self,image dst_image,rect outer,rect inner,rect dst,str mode):
        #grid 1 2 3   
        #grid 4 5 6
        #grid 7 8 9
        # grid diagram
        #  |o1     |      |     o2|
        #  |   1   |   2  |   3   |
        #  |     i1|      |i2     |
        #  |-------|------|-------|     
        #  |       |      |       |  
        #  |   4   |   5  |    6  |  
        #  |       |      |       |  
        #  |-------|------|-------|     
        #  |     i3|      |i4     |
        #  |   7   |   8  |    9  |
        #  |o3     |      |     o4| 

        # COPY 1,3,7,9 
        # tile 2,4,6,8
        # stretch 5 or omit...
        

        cdef rect   src_1=rect(outer.left    ,outer.top     ,inner.left     ,inner.top)
        cdef rect   src_2=rect(inner.left+1  ,outer.top     ,inner.right-1  ,inner.top)
        cdef rect   src_3=rect(inner.right   ,outer.top     ,outer.right    ,inner.top)
        cdef rect   src_4=rect(outer.left    ,inner.top+1   ,inner.left     ,inner.bottom-1)
        cdef rect   src_5=rect(inner.left+1  ,inner.top+1   ,inner.right-1  ,inner.bottom-1)
        cdef rect   src_6=rect(inner.right   ,inner.top+1   ,outer.right    ,inner.bottom-1)
        cdef rect   src_7=rect(outer.left    ,inner.bottom  ,inner.left     ,outer.bottom)
        cdef rect   src_8=rect(inner.left+1  ,inner.bottom  ,inner.right-1  ,outer.bottom)
        cdef rect   src_9=rect(inner.right   ,inner.bottom  ,outer.right    ,outer.bottom)

        cdef rect   dst_outer=dst
        cdef rect   dst_inner=rect(dst.left+src_1.width-1,dst.top+src_1.height-1,dst.right-src_9.width+1,dst.bottom-src_9.height+1)

        cdef rect   dst_1=rect(dst_outer.left    ,dst_outer.top     ,dst_inner.left     ,dst_inner.top)
        cdef rect   dst_2=rect(dst_inner.left+1  ,dst_outer.top     ,dst_inner.right-1  ,dst_inner.top)
        cdef rect   dst_3=rect(dst_inner.right   ,dst_outer.top     ,dst_outer.right    ,dst_inner.top)
        cdef rect   dst_4=rect(dst_outer.left    ,dst_inner.top+1   ,dst_inner.left     ,dst_inner.bottom-1)
        cdef rect   dst_5=rect(dst_inner.left+1  ,dst_inner.top+1   ,dst_inner.right-1  ,dst_inner.bottom-1)
        cdef rect   dst_6=rect(dst_inner.right   ,dst_inner.top+1   ,dst_outer.right    ,dst_inner.bottom-1)
        cdef rect   dst_7=rect(dst_outer.left    ,dst_inner.bottom  ,dst_inner.left     ,dst_outer.bottom)
        cdef rect   dst_8=rect(dst_inner.left+1  ,dst_inner.bottom  ,dst_inner.right-1  ,dst_outer.bottom)
        cdef rect   dst_9=rect(dst_inner.right   ,dst_inner.bottom  ,dst_outer.right    ,dst_outer.bottom)

        cdef point  p1=dst_1.point1()
        cdef point  p3=dst_3.point1()
        cdef point  p7=dst_7.point1()
        cdef point  p9=dst_9.point1()

        self.copy(dst_image,src_1, p1)
        self.copy(dst_image,src_3, p3)
        self.copy(dst_image,src_7, p7)
        self.copy(dst_image,src_9, p9)

        self.copy_tile(dst_image,src_2, dst_2)
        self.copy_tile(dst_image,src_4, dst_4)
        self.copy_tile(dst_image,src_6, dst_6)
        self.copy_tile(dst_image,src_8, dst_8)

        #if mode=='scale':
        #    self.copy_scale(dst_image,src_5,dst_5)
        #elif mode=='tile':
        #    self.copy_tile(dst_image,src_5, dst_5)

       # print "src"
       # src_1.debug()
       # src_2.debug()
       # src_3.debug()
       # src_4.debug()
       # src_5.debug()
       # src_6.debug()
       # src_7.debug()
       # src_8.debug()
       # src_9.debug()
       # exit()
       # print "dst"
       # dst_1.debug()
       # dst_2.debug()
       # dst_3.debug()
       # dst_4.debug()
       # dst_5.debug()
       # dst_6.debug()
       # dst_7.debug()
       # dst_8.debug()
       # dst_9.debug()
    
    cdef debug(self):
        print("Image")
