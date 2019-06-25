# cython: linetrace=True

from cpython cimport array
import array
import re
from libc.string cimport memset


from .font cimport font_map
from .fonts cimport font
#import font

# Reference
# http://man7.org/linux/man-pages/man4/console_codes.4.html


cdef class viewer:
    cdef public object          last_timestamp
  
    cdef public object          stream
    cdef public int             video_length
    cdef        array.array     video
    cdef        object          color_table
    cdef        array.array     buffer
    cdef public int             buffer_rows
    cdef        object          debug_mode
    cdef public object          sequence
    cdef public object          sequence_pos

    cdef public object          underlay_flag
    
    cdef ascii_safe(self,text):
        return ''.join([i if ord(i) < 128 else '*' for i in text])

    cdef info(self,text):
        if self.debug_mode:
            print(self.ascii_safe(text))
    
    cdef new_char_buffer(self):
        cdef array.array buffer=array.array('B')
        array.resize(buffer,self.viewport_char_stride*self.viewport_char_height)
        memset(buffer.data.as_voidptr, self.background_color, len(buffer) * sizeof(char))

        return buffer

    cdef new_video_buffer(self):
        cdef array.array buffer=array.array('B')
        array.resize(buffer,self.viewport_px_width*self.viewport_px_height)
        return buffer
        
    def __init__(self,width=640,height=480,char_width=None,char_height=None,debug=None):
        self.debug_mode                =debug
        self.viewport_px_width    =width
        self.viewport_px_height   =height

        if char_width and char_height:
            self.viewport_char_width  = char_width
            self.viewport_char_height = char_height
            self.viewport_px_width    = self.viewport_char_width*font.font_width
            self.viewport_px_height   = self.viewport_char_height*font.font_height
        else:
            self.viewport_char_height = self.viewport_px_height/font.font_width
            self.viewport_char_width  = self.viewport_px_width/font.font_height
            self.viewport_px_width    = width
            self.viewport_px_height   = height
        self.underlay_flag        =None
        #fg,bg,char
        self.viewport_char_stride =self.viewport_char_width*3  
        self.clear_sequence()
        self.video                =self.new_video_buffer()
        self.buffer               =self.new_char_buffer()
        #self.buffer_length        =self.viewport_char_width*self.viewport_char_height

        self.sequence_pos         =0
        self.video_length         =len(self.video)
        self.background_color     =0
        self.foreground_color     =3
        self.window_style         ="BOTTOM"
        self.extra_text           =""
        self.last_timestamp       =0





   
        
  
    
    def get(self):
        return {'width':self.viewport_px_width,'height':self.viewport_px_height,'data':array.copy(self.video),'color_table':self.color_table}

    def add_event(self,event):
        timestamp=round(float(event[0]),3)
        event_type=event[1]
        event_io=event[2]
        if self.last_timestamp==0:
            delay=0
        else:
            length=len(self.sequence)-1
            if length>0:
                self.sequence[length]['delay']=timestamp-self.last_timestamp
            else:
                delay=0
        if event_type=='o':
            self.stream_2_sequence(self.extra_text+event_io,timestamp,0)
            self.last_timestamp=timestamp
        
    cdef save_screen(self):
        # todo save as gif..
        # pre test with canvas extension
        x=1
