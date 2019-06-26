from .terminal_graphics cimport terminal_graphics
import re



cdef class term_parser:
    cdef object            debug_mode
    cdef object            sequence
    cdef int               sequence_pos
    cdef object            extra_text
    cdef terminal_graphics terminal_graphics
    cdef double            last_timestamp
    

    cdef ascii_safe(self,text)
    cdef info(self,text)
    cdef clear_sequence(self)
    cdef rgb_to_palette(self,r,g,b)
    cdef remap_character(self,character)
    cdef render_to_buffer(self)
    cdef procces_OSC(self,groups)
    cdef process_DSINGLE(self,groups)
    cdef process_CHAR_SET(self,groups)
    cdef process_G0(self,groups)
    cdef process_G1(self,groups)
    cdef process_CSI(self,command,params)
    cdef cmd_set_mode(self,cmd)
    cdef cmd_reset_mode(self,cmd)
    cdef cmd_process_colors(self,params)
    cdef cmd_render_text(self,event)
    cdef cmd_cursor_up(self,distance)
    cdef cmd_cursor_down(self,distance)
    cdef cmd_cursor_left(self,distance)
    cdef cmd_cursor_right(self,distance)
    cdef cmd_previous_line(self,distance)
    cdef cmd_next_line(self,distance)
    cdef cmd_absolute_pos_x(self,x)
    cdef cmd_absolute_pos_y(self,y)
    cdef cmd_absolute_pos(self,x,y)
    cdef cmd_vert_pos(self,position)
    cdef cmd_erase_display(self,mode)
    cdef cmd_erase_line(self,mode)
    cdef cmd_erase_characters(self,distance)
    cdef cmd_del_characters(self,length)
    cdef stream_2_sequence(self,text,timestamp,delay)
    cdef last_frame(self)
    cdef has_escape(self,text)
    cdef add_event(self,event)
    cdef add_text_sequence(self,text,timestamp,delay)
    cdef add_command_sequence(self,esc_type,command,params,groups,name,timestamp,delay)
    cdef debug_sequence(self)

