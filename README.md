# ttygif

A asciicast data file to gif conversion utility

## install

```bash
pip install ttygif --user
```

## usage
```bash
ttygif version 1.0.287
usage: ttygif [-h] [--input FILE] [--output FILE] [--loop COUNT] [--delay MS]
              [--fps FPS]

tty output to gif

optional arguments:
  -h, --help     show this help message and exit
  --input FILE   asciinema .cast file (default: None)
  --output FILE  gif output file (default: None)
  --loop COUNT   number of loops to play, 0=unlimited (default: 0)
  --delay MS     delay before restarting gif in milliseconds (default: 1000)
  --fps FPS      encode at (n) frames per second (0-25) 0=speed of cast file
                 (default: 8)

# Example
#ttygif --input data/232377.cast --output 232377.gif --fps=10

```

### status

- full output terminal emulation support not ready
- support for standard I/O -> Done
- support for colors -> Done
- support for cursor positioning -> Done
- Support for erase line modes 1,2,3 -> Done
- Support for erase screen  -> Done

Normal/colorized output work fine.

### Features still left to handle

- piped stdout with auto cast generation/emulated timestamps
- asciicast v1 support
- documentation
- gif error handeling
- file io error handeling
- cursor position saving
- cursor emulation
- erase screen with default bg color
- overflow on cursor position out of bounds
- cythonic definitions for speed improvment
- image underlay (branding)
- image overlay (branding)
- palette flags, monochrome,  grayscale, system, custom, count [n]<256
- font generation app
- font mapping for utf 8,16,13 characters to base 256 map

### Profile Times

- minimal speed gains have been put into place about 40% original speed increase
- an additional 20-30% boost once I update to cythonic variables
- 38% drawing characters
- 23% converting stream text to bufer
- 18% frame bounding for giff diff's
- 14% compressing image frames
- 07% other


### Examples
some random pics from the asciinema.org website

## [Terminal ray tracing](https://asciinema.org/a/174524)
- ![asciicast-174524](https://raw.githubusercontent.com/chris17453/ttygif/master/examples/encode/174524.gif)

## [term-tris dt cannon](https://asciinema.org/a/232377)
- ![asciicast-232377](https://raw.githubusercontent.com/chris17453/ttygif/master/examples/encode/232377-natural.gif)

## [Denariusd compile on 30 cores!](https://asciinema.org/a/234628)
- ![asciicast-234628](https://raw.githubusercontent.com/chris17453/ttygif/master/examples/encode/234628.gif)

## [surpirsed Pikachu](https://asciinema.org/a/236096)
- ![asciicast-236096](https://raw.githubusercontent.com/chris17453/ttygif/master/examples/encode/236096.gif)

## [CACA_DRIVER=ncurses cacademo](https://asciinema.org/a/687)
![asciicast-687](https://raw.githubusercontent.com/chris17453/ttygif/master/examples/encode/687.gif)
