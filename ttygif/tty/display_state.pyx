# cython: profile=True
# cython: linetrace=True
# cython: binding=True
# cython: language_level=2

cdef class display_state:

    def __cinit__(self,int width,int height):
        self.cursor_x           = 0
        self.cursor_y           = 0
        self.width              = width
        self.height             = height
        self.reverse_video      = None
        self.bold               = None            
        self.default_foreground = 15
        self.default_background = 0
        self.foreground         = self.default_foreground
        self.background         = self.default_background

        self.set_scroll_region(0,self.height)


    cdef set_scroll_region(self,top,bottom):
        self.scroll             = 0
        self.scroll_top         = top
        self.scroll_bottom      = bottom

    cdef check_bounds(self):
        if self.cursor_x<0:
            self.cursor_x=0

        if self.cursor_x>=self.width:
            self.cursor_x=self.width-1

        if self.cursor_y<self.scroll_top:
            self.scroll-=self.scroll_top-self.cursor_y #negative
            self.cursor_y=self.scroll_top
            
        if self.cursor_y>self.scroll_bottom:
            self.scroll+=self.cursor_y-self.scroll_bottom #positive
            self.cursor_y=self.scroll_bottom



    cdef cursor_up(self,int distance):
        self.cursor_y-=distance
        self.check_bounds()
        
    cdef cursor_down(self,int distance):
        self.cursor_y+=distance
        self.check_bounds()
    
    cdef cursor_left(self,int distance):
        self.cursor_x-=distance
        self.check_bounds()

    cdef cursor_right(self,int distance,wrap=None):
        self.cursor_x+=distance
        if wrap:
            if self.cursor_x>=self.width:
                self.cursor_x-=self.width
                self.cursor_down(1)
        else:
            self.check_bounds()

    cdef cursor_absolute_x(self,position):
        self.cursor_x=position
        self.check_bounds()
        
    cdef cursor_absolute_y(self,position):
        self.cursor_y=position
        self.check_bounds()

    cdef cursor_absolute(self,position_x,position_y):
        self.cursor_x=position_x
        self.cursor_y=position_y
        self.check_bounds()

    cdef cursor_save_position(self):
        self.saved_cursor_x=self.cursor_x
        self.saved_cursor_y=self.cursor_y

    cdef cursor_restore_position(self):
        self.cursor_x=self.saved_cursor_x
        self.cursor_y=self.saved_cursor_y

    cdef cursor_get_position(self):
        return [self.cursor_x,self.cursor_y]

    cdef set_background(self,int color):
        if color>255:
            raise Exception ("Color over maximum value")
        self.background=color
    
    cdef set_foreground(self,int color):
        if color>255:
            raise Exception ("Color over maximum value")
        self.foreground=color