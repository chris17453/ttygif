# ttygif

A fast stdio to gif conversion utility, that works with pipes and asciicast files.

## install

```bash
## requirements gcc and python development libs
pip install ttygif --user
```

## It's portable

ttygif is self contained with no dependencys other than python. GIF encoding 
and termal emulation are both implimented with internal cython code. The 
terminal font is embeded within the code. All you need to get ttygif to work
is a c compiler, python and its development libs. ttygif is a cython project.


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
ttygif --input  232377.cast --output 232377.gif --fps=33
```

## pipe to gif

```bash
ls -lhatsR | ttygif --output 232377.gif --fps=0
```

## slow down gif

```bash
ls -lhatsR | ttygif --output 232377.gif --fps=0 --dilate 10
```

## speed up gif

```bash
ls -lhatsR | ttygif --output 232377.gif --fps=0 --dilate .5
```


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


### Features still left to handle

- documentation
- embed event stream in gif as control header data
- output piped stream as cast file
- time period ( capture partial recording based on time stamps x-y)
- add progress bar to top/bottom of gif with n of y H:M:I:S
- font generation app
- font mapping for utf 8,16,13 characters to base 256 map
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

### Term Font

![DOS VGA FONT](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/examples/src_gifs/VGA_8x19font.gif)

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
