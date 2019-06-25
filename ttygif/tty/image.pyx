# sets bounding paramaters for image transformations
from .graphics cimport create_array, create_default_palette
from cpython cimport array
from libc.string cimport memset

cdef class bounds:
    def __cint__(self,int width,int height,int bytes_per_pixel=1):
        self.width          =width
        self.height          =height
        self.stride          =width*bytes_per_pixel
        self.length          =self.stride*height
        self.bytes_per_pixel =bytes_per_pixel

# image class, holds image metrics, data and palette        
cdef class image:
    def __cint__(self,int bytes_per_pixel,int width,int height,array.array palette,int init_value):
        
        self.dimentions=bounds(width=width,height=height,bytes_per_pixel=bytes_per_pixel)
        self.data      =create_array(size=dimentions.length,init_value=init_value)
        if palette==None:
            self.palette=create_default_palette()
        else:
            self.palette   =palette
    
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
            for i in range(0,self.dimentions.bytes_per_pixel):
                pixel[i]=self.data[pos+i]
            return pixel

    # put a pixel of X stride
    cdef put_pixel(self,int x,int y,pixel):
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
    
    cdef clear(self,int init_value=0):
        memset(self.data.data.as_voidptr, init_value, self.dimentions.length )

