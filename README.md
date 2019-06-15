#ttygif

A asciicast data file to gif conversion utility

## install

```bash
pip install ttygif --user
```

## usage

```bash
ttygif -i ascii.cast -o output.gif -f 10
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
- I percieve an additional 20-30% boost once I update to cythonic variables
- 38% drawing characters
- 23% converting stream text to bufer
- 18% frame bounding for giff diff's
- 14% compressing image frames
- 07% other

### Examples, including failures

- [Terminal ray tracing]: https://asciinema.org/a/174524
![asciicast-174524](https://raw.githubusercontent.com/chris17453/ttygif/master/examples/encode/174524.gif)

- [term-tris dt cannon]: https://asciinema.org/a/232377
![asciicast-232377](https://raw.githubusercontent.com/chris17453/ttygif/master/examples/encode/232377-natural.gif)

- [Denariusd compile on 30 cores!]: https://asciinema.org/a/234628
![asciicast-234628](https://raw.githubusercontent.com/chris17453/ttygif/master/examples/encode/234628.gif)

- []surpirsed Pikachu]: https://asciinema.org/a/236096
![asciicast-236096](https://raw.githubusercontent.com/chris17453/ttygif/master/examples/encode/236096.gif)

- [CACA_DRIVER=ncurses cacademo]: https://asciinema.org/a/687
![asciicast-687](https://raw.githubusercontent.com/chris17453/ttygif/master/examples/encode/687.gif)
