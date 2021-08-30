# ttygif

A full featured text to gif conversion utility, that just works. It's in beta, so expect rough edges.

## ttygif in action
![htop](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/encode/htop.gif)

## Whats the hell is this?
- It's sparkling fantastic colorfull terminal output AUTOMATION!

## how do i get it!?
```bash
## requirements gcc, python development libs, cython
pip3 install ttygif --user
```

## What are the benifits 
- pipe output into beautifuly themed gifs
- asciicast to gif
- perfect fit for CI/CD
- it runs headless
- it can be scripted
- works with python 2 and 3
- works on linux, mac, raspberry PI
- its fast, and easy to install
- it has themes
- you can make custom themes!
- you can add background images from the CLI


## It's portable

ttygif is self contained with no dependencys other than python/cython. GIF encoding 
and termal emulation are both implimented with internal cython code. No system 
fonts are required.  All you need to get ttygif to work is a c compiler,
python and its development libs. ttygif is a cython project.

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


## Supported fonts
- All fonts came from [https://int10h.org/oldschool-pc-fonts](https://int10h.org/oldschool-pc-fonts/)
- copyright FON conversion © 2015 VileR, license: CC BY-SA 4.0
- ttygif supports the "fd" font format. Basicly text files.
- All .FON files have been exported to fd files for portability.
- All fonts are copyright of their perspective owners, not me.
- default font=Verite_9x16

Check them all out here -> [fonts.md](/docs/fonts.md)


## ttygif-assets

The following resources are located in the [ttygif-assets](https://github.com/chris17453/ttygif-assets) repo

### Examples
some random pics from the asciinema.org website, and my computer


## pipe
![pipe](https://raw.githubusercontent.com/chris17453/ttygif-assets/master/encode/pipe.gif)

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

