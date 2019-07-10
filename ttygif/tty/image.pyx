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
    cdef copy(self,image dst,int x1,int y1,int x2,int y2,int dx,int dy):
        cdef int x
        cdef int y 
        for y in xrange(y1,y2):
            for x in xrange(x1,x2):
                pixel=self.get_pixel(x,y)
                dst.put_pixel(dx+(x-x1),dy+(y-y1),pixel)


    # strech src to fir dest
    cdef copy_scale(self,image dst,x1,y1,x2,y2,dx1,dy1,dx2,dy2):
        cdef int x
        cdef int y 
        cdef int x3
        cdef int y3
        cdef float fx
        cdef float fy
        cdef int s_xlen=x2-x1
        cdef int s_ylen=y2-y1
        cdef int d_xlen=dx2-dx1
        cdef int d_ylen=dy2-dy1
        
        for y in xrange(0,d_ylen):
            for x in xrange(0,d_xlen):

                # percentage
                fx=float(x)/float(d_ylen)
                fy=float(y)/float(d_xlen)

                y3=int( float(s_ylen)*fy+y1 )
                x3=int( float(s_xlen)*fx+x1 )

                pixel=self.get_pixel(x3,y3)                
                dst.put_pixel(x+dx1,y+dy1,pixel)

    # tile src to dest
    cdef copy_tile(self,image dst,x0,y0,x1,y1,x2,y2,x3,y3,dx1,dy1,dx2,dy2):
        cdef int x
        cdef int y 
        cdef int s_xlen=x2-x1
        cdef int s_ylen=y2-y1
        
        cdef int d_xlen=dx2-dx1
        cdef int d_ylen=dy2-dy1
        

        #grid 1 2 3
        #grid 4 5 6
        #grid 7 8 9

        # COPY 1,3,7,9 
        # tile 2,4,6,8
        # stretch 5
        b=dst.dimentions.bottom-1
        r=dst.dimentions.right-1

        self.copy(dst,x0,y0,x1,y1, dx1,dy1)
        self.copy(dst,0 ,y2,x1,b , dx1,dy1+)




    # template image for adaptive scaling via grid and looping
    cdef copy_9slice(self,image dst,x1,x2,y1,y2,,dx_1,dy_1,dx2,dy2):
    