# ttygif

A full featured text to gif conversion utility, that just works.

## Why use ttygif?

- its fast, and easy to install
- can be used with a pipe
- it can be scripted
- it can read asciicast files
- it runs headless
- perfect fit for CI/CD

## install

```bash
## requirements gcc and python development libs
pip install ttygif --user
```

## It's portable

ttygif is self contained with no dependencys other than python. GIF encoding 
and termal emulation are both implimented with internal cython code. No system 
fonts are required.  All you need to get ttygif to work is a c compiler,
python and its development libs. ttygif is a cython project.


## usage

```
ttygif version 1.0.792
usage: ttygif [-h] [--input FILE] [--output FILE] [--loop COUNT] [--delay MS]
              [--record FILE] [--dilation RATE] [--fps FPS] [--width WIDTH]
              [--height HEIGHT] [--debug]

tty output to gif

optional arguments:
  -h, --help       show this help message and exit
  --input FILE     asciinema .cast file (default: None)
  --output FILE    gif output file (default: None)
  --loop COUNT     number of loops to play, 0=unlimited (default: 0)
  --delay MS       delay before restarting gif in milliseconds (default: 100)
  --record FILE    output generated cast data to file (default: None)
  --dilation RATE  process events at a faster or slower rate of time (default:
                   1)
  --fps FPS        encode at (n) frames per second (0-25) 0=speed of cast
                   file, min 3ms (default: 0)
  --width WIDTH    change character width of gif, default is 80 or what is in
                   the cast file (default: None)
  --height HEIGHT  change character height of gif, default is 25 or what is in
                   the cast file (default: None)
  --debug          show debuging statistics (default: None)
```

## cast file to gif

```bash
ttygif --input  232377.cast --output ls_pipe.gif --fps=33
```

## pipe to gif

```bash
ls -lhatsR | ttygif --output ls_pipe.gif --fps=0
```

## slow down gif

```bash
ls -lhatsR | ttygif --output ls_pipe.gif --fps=0 --dilate 10
```

## speed up gif

```bash
ls -lhatsR | ttygif --output ls_pipe.gif --fps=0 --dilate .5
```

## Supported fonts
- All fonts came from [https://int10h.org/oldschool-pc-fonts](https://int10h.org/oldschool-pc-fonts/)
- copyright FON conversion © 2015 VileR, license: CC BY-SA 4.0
- ttygif supports the "fd" font format. Basicly text files.
- All .FON files have been exported to fd files for portability.
- All fonts are copyright of their perspective owners, not me.
- default font=Verite_9x16

- AMI_BIOS
- ![AMI_BIOS](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/AMI_BIOS.gif)
- AmstradPC1512
- ![AmstradPC1512](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/AmstradPC1512.gif)
- ATI_8x14
- ![ATI_8x14](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/ATI_8x14.gif)
- ATI_8x16
- ![ATI_8x16](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/ATI_8x16.gif)
- ATI_8x8
- ![ATI_8x8](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/ATI_8x8.gif)
- ATI_9x14
- ![ATI_9x14](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/ATI_9x14.gif)
- ATI_9x16
- ![ATI_9x16](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/ATI_9x16.gif)
- ATI_SmallW_6x8
- ![ATI_SmallW_6x8](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/ATI_SmallW_6x8.gif)
- ATT_PC6300
- ![ATT_PC6300](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/ATT_PC6300.gif)
- CompaqThin_8x14
- ![CompaqThin_8x14](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/CompaqThin_8x14.gif)
- CompaqThin_8x16
- ![CompaqThin_8x16](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/CompaqThin_8x16.gif)
- CompaqThin_8x8
- ![CompaqThin_8x8](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/CompaqThin_8x8.gif)
- DTK_BIOS
- ![DTK_BIOS](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/DTK_BIOS.gif)
- IBM_3270pc
- ![IBM_3270pc](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/IBM_3270pc.gif)
- IBM_BIOS
- ![IBM_BIOS](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/IBM_BIOS.gif)
- IBM_CGA
- ![IBM_CGA](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/IBM_CGA.gif)
- IBM_CGAthin
- ![IBM_CGAthin](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/IBM_CGAthin.gif)
- IBM_Conv
- ![IBM_Conv](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/IBM_Conv.gif)
- IBM_EGA8
- ![IBM_EGA8](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/IBM_EGA8.gif)
- IBM_EGA9
- ![IBM_EGA9](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/IBM_EGA9.gif)
- IBM_ISO8
- ![IBM_ISO8](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/IBM_ISO8.gif)
- IBM_ISO9
- ![IBM_ISO9](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/IBM_ISO9.gif)
- IBM_MDA
- ![IBM_MDA](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/IBM_MDA.gif)
- IBM_PGC
- ![IBM_PGC](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/IBM_PGC.gif)
- IBM_PS2thin1
- ![IBM_PS2thin1](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/IBM_PS2thin1.gif)
- IBM_PS2thin2
- ![IBM_PS2thin2](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/IBM_PS2thin2.gif)
- IBM_PS2thin3
- ![IBM_PS2thin3](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/IBM_PS2thin3.gif)
- IBM_PS2thin4
- ![IBM_PS2thin4](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/IBM_PS2thin4.gif)
- IBM_VGA8
- ![IBM_VGA8](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/IBM_VGA8.gif)
- IBM_VGA9
- ![IBM_VGA9](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/IBM_VGA9.gif)
- ITT_BIOS
- ![ITT_BIOS](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/ITT_BIOS.gif)
- Kaypro2K
- ![Kaypro2K](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/Kaypro2K.gif)
- Phoenix_BIOS
- ![Phoenix_BIOS](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/Phoenix_BIOS.gif)
- PhoenixEGA_8x14
- ![PhoenixEGA_8x14](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/PhoenixEGA_8x14.gif)
- PhoenixEGA_8x16
- ![PhoenixEGA_8x16](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/PhoenixEGA_8x16.gif)
- PhoenixEGA_8x8
- ![PhoenixEGA_8x8](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/PhoenixEGA_8x8.gif)
- PhoenixEGA_9x14
- ![PhoenixEGA_9x14](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/PhoenixEGA_9x14.gif)
- TandyNew_225
- ![TandyNew_225](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/TandyNew_225.gif)
- TandyNew_Mono
- ![TandyNew_Mono](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/TandyNew_Mono.gif)
- TandyNew_TV
- ![TandyNew_TV](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/TandyNew_TV.gif)
- TandyOld_225
- ![TandyOld_225](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/TandyOld_225.gif)
- TandyOld_TV
- ![TandyOld_TV](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/TandyOld_TV.gif)
- ToshibaLCD_8x16
- ![ToshibaLCD_8x16](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/ToshibaLCD_8x16.gif)
- ToshibaLCD_8x8
- ![ToshibaLCD_8x8](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/ToshibaLCD_8x8.gif)
- Verite_8x14
- ![Verite_8x14](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/Verite_8x14.gif)
- Verite_8x16
- ![Verite_8x16](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/Verite_8x16.gif)
- Verite_8x8
- ![Verite_8x8](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/Verite_8x8.gif)
- Verite_9x14
- ![Verite_9x14](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/Verite_9x14.gif)
- Verite_9x16
- ![Verite_9x16](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/Verite_9x16.gif)
- VGA_SquarePx
- ![VGA_SquarePx](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/VGA_SquarePx.gif)
- VTech_BIOS
- ![VTech_BIOS](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/VTech_BIOS.gif)
- Wyse700a-2y
- ![Wyse700-2y](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/Wyse700-2y.gif)
- Wyse700a
- ![Wyse700a](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/Wyse700a.gif)
- Wyse700b-2y
- ![Wyse700b-2y](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/fonts/preview/Wyse700b-2y.gif)


### ESCAPE CODE SUPPORT

- the letters n and m in the middle of the escape sequence are numeric substitutions
- ignore whitespace

| Type |          | Code     | Name                            |
|------|----------|----------|---------------------------------|
| CSI  | ^[ n   A | CUU      | Cursor up                       |
| CSI  | ^[ n   B | CUD      | Cursor down                     |
| CSI  | ^[ n   C | CUF      | Cursor Forward                  |
| CSI  | ^[ n   D | CUB      | Cursor Back                     |
| CSI  | ^[ n   E | CNL      | Cursor Next Line                |
| CSI  | ^[ n   F | CPL      | Cursor Previous Line            |
| CSI  | ^[ n   G | CHA      | Cursor Horizontal Absolute      |
| CSI  | ^[ n;m H | CUP      | Cursor Position                 |
| CSI  | ^[ n   J | ED       | Erase Display                   |
| CSI  | ^[ n   K | EL       | Erase Line                      |
| CSI  | ^[ n   P | DCH      | Delete Character                |
| CSI  | ^[ n   X | ECH      | Erase Character                 |
| CSI  | ^[ n   d | VPA      | Vertical Position Absolute      |
| CSI  | ^[ n   ` | HPA      | Horizontal Position Absolute    |
| CSI  | ^[ n;m f | HVP      | Horizontal / Vertical position  |
| CSI  | ^[ n;m m |          | Set Text Attributes             |
| CSI  | ^[     s | SCP      | Save Cursor Position            |
| CSI  | ^[     u | RCP      | Restore Cursor Position         |
| DEC  | ^[ n;m r | DECSTBM  | Set Top and Bottom Margins      |
| DEC  | ^[? 7  h | DECAWM   | Auto Wrap Mode / Set            |
| DEC  | ^[? 7  l | DECAWM   | Auto Wrap Mode / Reset          |
| DEC  | ^[ 25  h | DECTCEM  | Text Cursor Enable Mode / Set   |
| DEC  | ^[ 25  l | DECTCEM  | Text Cursor Enable Mode / Reset |
| DEC  | ^[?1049h |          | Alternate Screen / Set          |
| DEC  | ^[?1049l |          | Alternate Screen / Reset        |
|      | ^[?2004h |          | Enable Bracket Paste Mode       |
|      | ^[?2004l |          | Disable Bracket Paste Mode      |


### Features still left to handle

- documentation
- font mapping for utf 8,16,13 characters to base 256 map
- embed event stream in gif as control header data
- time period ( capture partial recording based on time stamps x-y)
- add progress bar to top/bottom of gif with n of y H:M:I:S
- palette flags, monochrome,  grayscale, system, custom, count [n]<256
- gif color consoladataion, for lower bit count (<8) compression 
- asciicast v1 support
- cursor emulation
- image underlay (branding)
- image overlay (branding)
- cliping
- origin x,y
- logging with ansi stripping
- split every n seconds or size
- export as frames
- theme/solarized/bright/microsoft
- frames, windows 95, x11, mac, fedora, gnome, cinnamon
- start and end frames, with delays


## The benchmark for speed

- A medium density 60 second screen recording can be rendered to gif in less than 5 seconds.

## ttygif-assets

The following resources are located in the [ttygif-assets](https://github.com/chris17453/ttygif-assets) repo

### Examples
some random pics from the asciinema.org website, and my computer

## htop
![htop](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/examples/encode/test.gif)

## pipe
![htop](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/examples/encode/pipe.gif)

## [Terminal ray tracing](https://asciinema.org/a/174524)
![asciicast-174524](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/examples/encode/174524.gif)

## [term-tris dt cannon](https://asciinema.org/a/232377)
![asciicast-232377](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/examples/encode/232377.gif)

## [Denariusd compile on 30 cores!](https://asciinema.org/a/234628)
![asciicast-234628](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/examples/encode/234628.gif)

## [surpirsed Pikachu](https://asciinema.org/a/236096)
![asciicast-236096](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/examples/encode/236096.gif)

## [CACA_DRIVER=ncurses cacademo](https://asciinema.org/a/687)
![asciicast-687](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/examples/encode/687.gif)


## Notes

asciicast may split data between events, causing escape codes not to be recognised.
ttygif moves all trailing unformed escape codes to the next event.
the gif techincal minimum for internal delays is 1ms. I default to 3ms. Testing
shows various applications randnomly do not obey values from 1ms to  10ms.
