# cython: profile=True
# cython: binding=True
# cython: language_level=2


from cpython cimport array
from .parser cimport term_parser
from .terminal_graphics cimport terminal_graphics
from .font cimport font



# main interface for terminal emulation
cdef class terminal_emulator:
    
    def __cinit__(self,
                    width       = 640,
                    height      = 480,
                    char_width  = None,
                    char_height = None,
                    font_name   = None,
                    theme_name  = None,
                    debug       = None,
                    last_event  = 0,
                    show_state  = False,
                    no_autowrap = None,
                    underlay    = None):
    
        self.debug_mode      =debug
        self.show_state      =show_state
        self.underlay_flag   =None
        self.default_font    ='Verite_9x16'
        if font_name==None:
           font_name=self.default_font
        self.font_name       =font_name
        self.theme_name      =theme_name
        self.last_event      =last_event
        self.no_autowrap     =no_autowrap
        self.underlay        =underlay
        self.init(width,height,char_width,char_height,debug,last_event,show_state)
    
    cdef init(self,width,height,char_width,char_height,debug,last_event,show_state):
        cdef font internal_font


        try:
            internal_font=font(self.font_name)
        except Exception:
            internal_font=font(self.default_font)
        

        self.terminal_graphics= terminal_graphics(character_width = char_width,
                                                 character_height = char_height,
                                                 viewport_width   = width,
                                                 viewport_height  = height,
                                                 image_font       = internal_font,
                                                 theme_name       = self.theme_name,
                                                 underlay         = self.underlay)

        self.parser          = term_parser(debug_mode=debug,terminal_graphics=self.terminal_graphics,last_event=last_event,show_state=show_state,no_autowrap=self.no_autowrap)
        
   
    # this pre computes the regex into commands and stores into an array
    cdef add_event(self,event):
        self.parser.add_event(event)
    
    cdef render(self,time):
        # graphics pointer is inside of the parser.... maybe seperate...
        self.frame+=1
        print("RENDERING FRAME {0}".format(frame))
        self.parser.render_to_buffer(time)
        self.terminal_graphics.render()
        if self.terminal_graphics.state.display_cursor==True:
            if (int(time*10))%10>5:
                self.terminal_graphics.draw_character(
                    self.terminal_graphics.state.cursor_x,
                    self.terminal_graphics.state.cursor_y,[7,0,95]);

    cdef last_frame(self):
        self.parser.last_frame()

    cdef debug_sequence(self):
        #self.parser.debug_sequence()
        print ("Sequence is above")
    # this is for returning screen data to other functions
    cdef get(self):
        return {    
            'width'         : self.terminal_graphics.viewport.dimentions.width,
            'height'        : self.terminal_graphics.viewport.dimentions.height,
            'data'          : array.copy(self.terminal_graphics.viewport.data),
            'color_table'   : self.terminal_graphics.viewport.palette}
    
    cdef get_dimentions(self):
        return self.terminal_graphics.viewport.dimentions

    # TODO snapshot of a frame
    cdef save_screen(self):
        x=1
