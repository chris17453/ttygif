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

cdef class rect:
    cdef int left
    cdef int top
    cdef int right
    cdef int bottom
    cdef int width
    cdef int height
    

    def __cinit__(self,int left,int top,int right,int bottom):
        self.left   =left
        self.top    =top
        self.right  =right
        self.bottom =bottom
        self.height =bottom-top+1
        self.width  =right-left+1

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

cdef class point:
    cdef int left
    cdef int top

    def __cinit__(self,int left,int top):
        self.left   =left
        self.top    =top

# image class, holds image metrics, data and palette        
cdef class image:
    def __cinit__(self,int bytes_per_pixel,int width,int height,array.array palette,int init_value):
        
        self.dimentions=bounds(width,height,bytes_per_pixel)
        self.data      =self.create_buffer(self.dimentions.length,init_value)
        if palette:
            self.palette   =palette
    
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
    
    cdef clear(self,int init_value):
        memset(self.data.data.as_voidptr, init_value, self.dimentions.length )


    # plain copy 1-1
    cdef copy(self,image dst_image,rect src,point dst):
        cdef int x
        cdef int y 
        for y in xrange(0,src.height):
            for x in xrange(0,src.width):
                pixel=self.get_pixel(x+src.left,y+src.top)
                dst_image.put_pixel(dst.left+x,dst.top+y,pixel)


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
                dst_image.put_pixel(x+dst.left,y+dst.top,pixel)



    # template image for adaptive scaling via grid and looping
    cdef copy_9slice(self,image dst_image,rect outer,rect inner,rect dst):
    

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


        src_1=rect(outer.left    ,outer.top     ,inner.left     ,inner.top)
        src_2=rect(inner.left+1  ,outer.top     ,inner.right-1  ,inner.top)
        src_3=rect(inner.right   ,outer.top     ,outer.right    ,inner.top)
        src_4=rect(outer.left    ,inner.top+1   ,inner.left     ,inner.bottom-1)
        src_5=rect(inner.left+1  ,inner.top+1   ,inner.right-1  ,inner.bottom-1)
        src_6=rect(inner.right   ,inner.top+1   ,outer.right    ,inner.bottom-1)
        src_7=rect(outer.left    ,inner.bottom  ,inner.left     ,outer.bottom)
        src_8=rect(inner.left+1  ,inner.bottom  ,inner.right-1  ,outer.bottom)
        src_9=rect(inner.right   ,inner.bottom  ,outer.right    ,outer.bottom)

        rect dst_outer=dst
        rect dst_inner=rect(dst.left+src_1.width-1,dst.top+src_1.height-1,dst.right-src_9.width+1,dst.bottom-src_9.height+1)

        dst_1=rect(dst_outer.left    ,dst_outer.top     ,dst_inner.left     ,dst_inner.top)
        dst_2=rect(dst_inner.left+1  ,dst_outer.top     ,dst_inner.right-1  ,dst_inner.top)
        dst_3=rect(dst_inner.right   ,dst_outer.top     ,dst_outer.right    ,dst_inner.top)
        dst_4=rect(dst_outer.left    ,dst_inner.top+1   ,dst_inner.left     ,dst_inner.bottom-1)
        dst_5=rect(dst_inner.left+1  ,dst_inner.top+1   ,dst_inner.right-1  ,dst_inner.bottom-1)
        dst_6=rect(dst_inner.right   ,dst_inner.top+1   ,dst_outer.right    ,dst_inner.bottom-1)
        dst_7=rect(dst_outer.left    ,dst_inner.bottom  ,dst_inner.left     ,dst_outer.bottom)
        dst_8=rect(dst_inner.left+1  ,dst_inner.bottom  ,dst_inner.right-1  ,dst_outer.bottom)
        dst_9=rect(dst_inner.right   ,dst_inner.bottom  ,dst_outer.right    ,dst_outer.bottom)

        p1=rec1.point1()
        p2=rec3.point1()
        p7=rec7.point1()
        p9=rec9.point1()

        self.copy(dst,src_1, p1)
        self.copy(dst,src_3, p3)
        self.copy(dst,src_7, p7)
        self.copy(dst,src_9, p9)

        self.copy_tile(dst,src_2, dst_2)
        self.copy_tile(dst,src_4, dst_4)
        self.copy_tile(dst,src_6, dst_6)
        self.copy_tile(dst,src_8, dst_8)
