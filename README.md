# ttygif

A self contained asciicast data file to gif conversion utility

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

```bash
ttygif version 1.0.752
usage: ttygif [-h] [--input FILE] [--output FILE] [--loop COUNT] [--delay MS]
              [--dilation RATE] [--fps FPS] [--width WIDTH] [--height HEIGHT]
              [--debug]

tty output to gif

optional arguments:
  -h, --help            show this help message and exit
    --input FILE          asciinema .cast file (default: None)
  --output FILE         gif output file (default: None)
  --loop COUNT          number of loops to play, 0=unlimited (default: 0)
  --delay MS            delay before restarting gif in milliseconds (default:
                        100)
  --dilation RATE       process events at a faster or slower rate of time
                        (default: 1)
  --fps FPS             encode at (n) frames per second (0-25) 0=speed of cast
                        file, min 1ms (default: 0)
  --width WIDTH         change character width of gif, default is 80 or what
                        is in the cast file (default: None)
  --height HEIGHT       change character height of gif, default is 25 or what
                        is in the cast file (default: None)
--debug               show debuging statistics (default: None)

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


### Finished Features

- ansi escape string parsing CSI, OSC and basic Control Characters
- standard I/O
- colors, default term, and rgb
- cursor positioning
- erase line modes 1,2,3
- erase screen
- r,g,b palette mapping to curent palette
- piped stdout with auto cast generation/emulated timestamps


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
- gif error handeling
- file io error handeling
- cursor position saving
- cursor emulation
- erase screen with default bg color
- overflow on cursor position out of bounds
- cythonic definitions for speed improvment - Mostly Done
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

### Profile Times

- minimal speed gains have been put into place about 40% original speed increase
- an additional 20-30% boost once I update to cythonic variables
- 38% drawing characters
- 23% converting stream text to bufer
- 18% frame bounding for giff diff's
- 14% compressing image frames
- 07% other


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
