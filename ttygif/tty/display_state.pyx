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

    cdef check_bounds(self):
        if self.cursor_y<0:
            self.cursor_y=0

        if self.cursor_y>=self.height:
            self.cursor_y=self.height-1
            self.cursor_y=0

        if self.cursor_x<0:
            self.cursor_x=0

        if self.cursor_x>=self.width:
            self.cursor_x=self.width-1
            self.cursor_x=0
            self.cursor_down()

        #self.shift_buffer(buffer)
            #shift!buffer

    cdef cursor_up(self):
        self.cursor_y-=1
        self.check_bounds()
        
    cdef cursor_down(self):
        self.cursor_y+=1
        self.check_bounds()
    
    cdef cursor_left(self):
        self.cursor_x-=1
        self.check_bounds()

    cdef cursor_right(self):
        self.cursor_x+=1
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