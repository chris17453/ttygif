# sets bounding paramaters for image transformations
from cpython cimport array
from libc.string cimport memset

cdef class bounds:
    cdef int width
    cdef int height
    cdef int stride
    cdef int length
    cdef int bytes_per_pixel
    def __cint__(self,int width,int height,int bytes_per_pixel=1):
        self.width          =width
        self.height          =height
        self.stride          =width*bytes_per_pixel
        self.length          =stride*height
        self.bytes_per_pixel =bytes_per_pixel

# image class, holds image metrics, data and palette        
cdef class image:
    cdef array.array data
    cdef bounds      dimentions
    cdef array.array palette
    def __cint__(self,int bytes_per_pixel,int width,int height,array.array palette,int init_value):
        
        self.dimentions=bounds(width=width,height=height,bytes_per_pixel=bytes_per_pixel)
        self.data      =create_array(size=dimentions.length,init_value=init_value)
        if palette==None:
            self.palette=create_default_palette()
        else:
            self.palette   =palette
    
    cdef get position(int x,int y):
        cdef int pos=self.dimentions.stride*y+x*self.dimentions.bytes_per_pixel
        return pos

    # get a pixel of X stride
    cdef get_pixel(int x,int y):
        cdef int pos=x*self.dimentions.bytes_per_pixel+y*self.dimentions.stride
        if self.dimentions.bytes_per_pixel==1:
            return self.data[pos]
        else:
            pixel=[0]*self.dimentions.bytes_per_pixel
            for i in range(0,self.dimentions.bytes_per_pixel):
                pixel[i]=self.data[pos+i]
            return pixel

    # put a pixel of X stride
    cdef put_pixel(int x,int y,pixel):
        if x<0 or x>=self.dimentions.width:
            continue
        if y<0 or y>=self.dimentions.height:
            continue
        cdef int pos=self.get_position(x,y)
        if self.dimentions.bytes_per_pixel==1:
            self.data[pos]=pixel
        else:
            for i in range(0,self.dimentions.bytes_per_pixel):
                self.data[pos+i]=pixel[i]
    
    cdef clear(int init_value=0):
        memset(self.data.data.as_voidptr, init_value, self.dimentions.length )
