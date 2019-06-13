# NON CSI Sequences
#       ESC c     RIS      Reset.
#       ESC D     IND      Linefeed.
#       ESC E     NEL      Newline.
#       ESC H     HTS      Set tab stop at current column.
#       ESC M     RI       Reverse linefeed.
#       ESC Z     DECID    DEC private identification. The kernel returns the
#                          string  ESC [ ? 6 c, claiming that it is a VT102.
#       ESC 7     DECSC    Save current state (cursor coordinates,
#                          attributes, character sets pointed at by G0, G1).
#       ESC 8     DECRC    Restore state most recently saved by ESC 7.
#       ESC [     CSI      Control sequence introducer
#       ESC %              Start sequence selecting character set
#       ESC % @               Select default (ISO 646 / ISO 8859-1)
#       ESC % G               Select UTF-8
#       ESC % 8               Select UTF-8 (obsolete)
#       ESC # 8   DECALN   DEC screen alignment test - fill screen with E's.
#       ESC (              Start sequence defining G0 character set
#       ESC ( B               Select default (ISO 8859-1 mapping)
#       ESC ( 0               Select VT100 graphics mapping
#       ESC ( U               Select null mapping - straight to character ROM
#       ESC ( K               Select user mapping - the map that is loaded by
#                             the utility mapscrn(8).
#       ESC )              Start sequence defining G1
#                          (followed by one of B, 0, U, K, as above).
#       ESC >     DECPNM   Set numeric keypad mode
#       ESC =     DECPAM   Set application keypad mode
#       ESC ]     OSC      (Should be: Operating system command) ESC ] P
#                          nrrggbb: set palette, with parameter given in 7