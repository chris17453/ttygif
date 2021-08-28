# cython: profile=True
# cython: binding=True
# cython: language_level=2
from libc.stdint cimport uint32_t, int64_t,uint16_t,uint8_t,int32_t
from theme cimport theme

cdef class display_state:

    def __cinit__(self,int width,int height,theme user_theme):
        self.cursor_x           = 0
        self.cursor_y           = 0
        self.width              = width
        self.height             = height
        self.mode               = "linux"
        self.reverse_video      = None
        self.bold               = None            
        self.text_mode          = None            
        self.autowrap           = True            
        self.foreground         = user_theme.foreground
        self.background         = user_theme.background
        self.default_foreground = user_theme.default_foreground
        self.default_background = user_theme.default_background
        self.pending_wrap       = None
        self.cursor_speed       = 0
        self.display_cursor     = None

        self.set_scroll_region(0,self.height-1)

    cdef text_mode_on(self):
        self.text_mode=True

    cdef text_mode_off(self):
        self.text_mode=None

    cdef autowrap_on(self):
        self.autowrap=True
        
    cdef autowrap_off(self):
        self.autowrap=None

    cdef set_scroll_region(self,top,bottom):
        self.scroll             = 0
        self.scroll_top         = top
        self.scroll_bottom      = bottom


    cdef show_cursor(self):
        self.display_cursor=True

    cdef hide_cursor(self):
        self.display_cursor=None

  
  
  
  
  
    cdef check_bounds(self):
        if self.pending_wrap:
            if self.cursor_x!=self.width-1 or self.cursor_y!=self.height-1 or self.autowrap!=True:
                self.pending_wrap=None

        if self.cursor_x<0:
            self.cursor_x=0

        if self.cursor_x>=self.width:
            self.cursor_x=self.width-1

        if self.cursor_y<self.scroll_top:
            if self.text_mode:
                self.scroll-=self.scroll_top-self.cursor_y #negative
            self.cursor_y=self.scroll_top
            
        if self.cursor_y>self.scroll_bottom:
            if self.text_mode:
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

    cdef cursor_right(self,int distance):
        
        if self.pending_wrap==None and self.autowrap and self.cursor_x==self.width-1 and self.cursor_y==self.height-1:
            self.pending_wrap=True
            #print ("PENDING YO",self.cursor_x,self.cursor_y)
        else:
            self.cursor_x+=distance
            if self.autowrap==True:
                while self.cursor_x>=self.width:
                    #print "DOWN!",self.cursor_x,self.cursor_y,self.pending_wrap,self.autowrap 
                    self.cursor_x=self.cursor_x-self.width
                    self.cursor_down(1)
            #else:
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

    cdef debug_state(self):
        print(" DisplayState")
        print(" - cursor_x           : {0}".format(self.cursor_x))
        print(" - cursor_y           : {0}".format(self.cursor_y))
        print(" - width              : {0}".format(self.width))
        print(" - height             : {0}".format(self.height))
        print(" - mode               : {0}".format(self.mode))
        print(" - reverse_video      : {0}".format(self.reverse_video))
        print(" - bold               : {0}".format(self.bold))
        print(" - text_mode          : {0}".format(self.text_mode))
        print(" - autowrap           : {0}".format(self.autowrap))
        print(" - foreground         : {0}".format(self.foreground))
        print(" - background         : {0}".format(self.background))
        print(" - default_foreground : {0}".format(self.default_foreground))
        print(" - default_background : {0}".format(self.default_background))
        print(" - pending_wrap       : {0}".format(self.pending_wrap))