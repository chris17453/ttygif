# cython: profile=True
# cython: binding=True
# cython: language_level=2

from .terminal_graphics cimport terminal_graphics
import re



cdef class term_parser:
    cdef object            debug_mode
    cdef object            sequence
    cdef int               sequence_pos
    cdef object            extra_text
    cdef object            no_codes
    cdef object            bracketed_paste
    cdef object            current_sequence_position
        
    cdef terminal_graphics g
    cdef double            last_timestamp
    

    cdef ascii_safe(self,text)
    cdef info(self,text)
    cdef clear_sequence(self)
    cdef rgb_to_palette(self,r,g,b)
    cdef uint8_t remap_character(self,character)
    cdef render_to_buffer(self)
    cdef procces_OSC(self,groups)
    cdef process_SINGLE(self,groups)
    cdef process_CHAR_SET(self,groups)
    cdef process_G0(self,groups)
    cdef process_G1(self,groups)
    cdef process_CSI(self,command,params)
    cdef cmd_DECSET(self,int code)
    cdef cmd_DECRST(self,int code)
    cdef cmd_bracketed_paste_on(self)
    cdef cmd_bracketed_paste_off(self)
    cdef cmd_BRACKETED_PASTE(self,value)
    cdef cmd_set_mode(self,cmd)
    cdef cmd_reset_mode(self,cmd)
    cdef set_foreground(self,color)
    cdef set_background(self,color)
    cdef cmd_process_colors(self,params)
    cdef cmd_render_text(self,event)
    cdef cmd_DECSTBM(self,int top,int bottom)
    cdef cmd_CUU(self,distance)
    cdef cmd_CUD(self,distance)
    cdef cmd_CUB(self,distance)
    cdef cmd_CUF(self,distance)
    cdef cmd_CPL(self,distance)
    cdef cmd_CNL(self,distance)
    cdef cmd_CHA(self,x)
    cdef cmd_CUP(self,x,y)
    cdef cmd_ED(self,mode)
    cdef cmd_EL(self,mode)
    cdef cmd_ECH(self,distance)
    cdef cmd_DCH(self,distance)
    cdef cmd_HVP(self,x,y)
    cdef cmd_HPA(self,x)
    cdef cmd_SCP(self)
    cdef cmd_RCP(self)
    cdef cmd_VPA(self,position)

    cdef stream_2_sequence(self,text,timestamp,delay)
    cdef last_frame(self)
    cdef has_escape(self,text)
    cdef add_event(self,event)
    cdef add_text_sequence(self,text,timestamp,delay)
    cdef add_command_sequence(self,esc_type,command,params,groups,name,timestamp,delay,text=?)
    cdef debug_sequence(self)
    cdef debug_event(self,event,index)
    

