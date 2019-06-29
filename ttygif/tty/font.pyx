# cython: profile=True
# cython: linetrace=True
# cython: binding=True
# cython: language_level=2

from cpython cimport array


cdef class font:
    def __cinit__(self):
        self.name=""
        self.chars_per_line=0
        self.lines=0
        self.width=0       
        self.height=0
        self.font_width=0
        self.font_height=0
        self.spacing_x=0
        self.spacing_y=0
        self.offset_x=0
        self.offset_y=0
        self.transparent=0
    #color_table
    #graphic
