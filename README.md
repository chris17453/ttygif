# ttygif

A full featured text to gif conversion utility, that just works. It's in beta, so expect rough edges.

## Why use ttygif?
- its fast, and easy to install
- can be used with a pipe
- it can be scripted
- it can read asciicast files
- it runs headless
- perfect fit for CI/CD
- works with python 2 and 3
- works on linux, mac, raspberry PI
- it has a few neat themes
- you can easily make your own theme
- you can add background images from the CLI


## easy install

```bash
## requirements gcc and python development libs
pip install ttygif --user
```

## dev install 
This will pull the project and submodule assets from github.
```
git clone https://github.com/chris17453/ttygif.git
cd ttygif
make pull-assets
```

## dev build
```bash
pipenv shell
make build
```

## It's portable

ttygif is self contained with no dependencys other than python. GIF encoding 
and termal emulation are both implimented with internal cython code. No system 
fonts are required.  All you need to get ttygif to work is a c compiler,
python and its development libs. ttygif is a cython project.


## usage

```
[nd@radical-edward ttygif]$ ttygif 
ttygif version [1.2.630]

 - Compiled against Python: 3.9.6 (default, Jul 16 2021, 00:00:00)  [GCC 11.1.1 20210531 (Red Hat 11.1.1-3)]
usage: ttygif [-h] [--input FILE] [--output FILE] [--record FILE] [--theme THEME] [--loop COUNT] [--delay MS] [--trailer] [--speed RATE] [--fps FPS]
              [--title TITLE] [--underlay FILE] [--no-autowrap] [--font NAME] [--columns WIDTH] [--rows HEIGHT]

tty output to gif

optional arguments:
  -h, --help                 show this help message and exit
  --input FILE, -i FILE      asciinema .cast file
  --output FILE, -o FILE     gif output file. will default to ttygif-xx
  --record FILE              output generated cast data to file
  --underlay FILE            Add an image as a background, (Internal)

Gif:
  Effects

  --theme THEME, -t THEME    load theme: game,windows7,mac,fwdm,opensource,scripted,bar. User themes can be loaded by file or ~./ttygif. .theme is added to any
                             user input
  --loop COUNT, -l COUNT     number of loops to play, 0=unlimited
  --delay MS, -d MS          delay before restarting gif in milliseconds
  --trailer                  Append an ending to the gif
  --speed RATE               process events at a faster or slower rate of time. Pipes are sped up 10,000 automatically
  --fps FPS                  encode at (n) frames per second (0-100) 0=speed of cast file, min 3ms
  --title TITLE              If using a theme, you can add a title text

Term:
  Default settings

  --no-autowrap              turn off line wrap in the terminal
  --font NAME, -f NAME       which internal font to use
  --columns WIDTH, -c WIDTH  change character width of gif, default is 80 or what is in the cast file
  --rows HEIGHT, -r HEIGHT   change character height of gif, default is 25 or what is in the cast file

[nd@radical-edward ttygif]$ 


```

## themes
Theming is based on the idea of branding your work for display in project repositories, ci/cd and online.

### theme support

- user directory. custom themes can be placed in the user directory under '~/.ttygif'
- layers above and below the terminal image
- transparency in layers
- layers modes are copy, scale, tile, 3slice, 9slice (scale and tiled)
- layers support cropping and positioning
- palettes are defined by themes
- all layers are mapped to the theme palette
- title rendering from cli argument, positioned by theme elements with font scaling
- custom theme template -> [test.theme](docs/test.theme)

### shipped themes

- default (256 color xterm palette)
- default-4bit  (16 colorxterm palette)
- default-2bit  (monochrome palette)
- windows7 (windows style wrapped terminal)
- game (8 bit inspired frame)
- mac (mac styled window)
- fwdm (old linux style window)
- scripted (bottom bar with text)
- opensouirce (bottom bar with text)
- bar (bottom bar with NO text)


## file size

Gif's are not the best compresed video format, however ttygif has all ability the format allows.
Bit reduction results in slightly smaller files For example The folowing table is made from the htop example:

- Specs: 79 frames at 1 FPS for 13.5 seconds

| COLORS | Bit Depth | Size | Change |
|--------|-----------|------|--------|
|  256   | 8         | 189k | 0%     |
|  16    | 4         | 175k | 7.5%   |
   2     | 2         | 133k | 29.7%  |


## cast file to gif

```bash
ttygif --input  232377.cast --output ls_pipe.gif --fps=33
```

## pipe to gif

```bash
ls -lhatsR | ttygif 
```

## slow down gif

```bash
ls -lhatsR | ttygif --output ls_pipe.gif  --speed 10
```

## speed up gif

```bash
ls -lhatsR | ttygif --output ls_pipe.gif  --speed .5
```

## Supported fonts
- All fonts came from [https://int10h.org/oldschool-pc-fonts](https://int10h.org/oldschool-pc-fonts/)
- copyright FON conversion © 2015 VileR, license: CC BY-SA 4.0
- ttygif supports the "fd" font format. Basicly text files.
- All .FON files have been exported to fd files for portability.
- All fonts are copyright of their perspective owners, not me.
- default font=Verite_9x16

Check them all out here -> [fonts.md](/docs/fonts.md)



### ESCAPE CODE SUPPORT

- the letters n and m in the middle of the escape sequence are numeric substitutions
- ignore whitespace
- 

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


### Features I'd like to add

These are ideas that just pop in my head, or are gathered via discussion.

- documentation
- font /codepage mapping for utf 8,16,13 characters to base 256 map
- embed event stream in gif as control header data
- time period ( capture partial recording based on time stamps x-y)
- add progress bar to top/bottom of gif with n of y H:M:I:S
- logging with ansi stripping
- split gif every n seconds or size
- export as frames, png
- output as webm/mp4

## The benchmark for speed

- A medium density 60 second screen recording can be rendered to gif in less than 5-8 seconds,
- tested on a 2021'ish 3.8 ghz 24 core Ryzen on Fedora 34

## ttygif-assets

The following resources are located in the [ttygif-assets](https://github.com/chris17453/ttygif-assets) repo

### Examples
some random pics from the asciinema.org website, and my computer

## htop
- with windows7 theme
![htop](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/encode/test.gif)

## pipe
![htop](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/encode/pipe.gif)

## [Terminal ray tracing](https://asciinema.org/a/174524)
![asciicast-174524](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/encode/174524.gif)

## [term-tris dt cannon](https://asciinema.org/a/232377)
- with game theme
![asciicast-232377](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/encode/232377.gif)

## [Denariusd compile on 30 cores!](https://asciinema.org/a/234628)
![asciicast-234628](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/encode/234628.gif)

## [surpirsed Pikachu](https://asciinema.org/a/236096)
![asciicast-236096](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/encode/236096.gif)

## [CACA_DRIVER=ncurses cacademo](https://asciinema.org/a/687)
![asciicast-687](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/encode/687.gif)


## Notes

asciicast may split data between events, causing escape codes not to be recognised.
ttygif moves all trailing unformed escape codes to the next event.
the gif techincal minimum for internal delays is 1ms. I default to 3ms. Testing
shows various applications randnomly do not obey values from 1ms to  10ms.
