#ttygif
A asciicast data file to gif conversion utility

## install
```bash
pip install ttygif --user
```

## usage
```bash
ttygif -i ascii.cast -o outpu t.gif
```

### 
Normal/colorized output work fine.

### Features still left to handle.
- cursor position saving
- cursor emulation
- erase screen with default bg color
- overflow on cursor position out of bounds
- cythonic definitions for speed improvment
- image underlay (branding)
- image overlay (branding)


### Examples
![asciicast-174524](https://raw.githubusercontent.com/chris17453/ttygif/master/examples/encode/174524.gif)
![asciicast-232377](https://raw.githubusercontent.com/chris17453/ttygif/master/examples/encode/232377.gif)
![asciicast-234628](https://raw.githubusercontent.com/chris17453/ttygif/master/examples/encode/234628.gif)
![asciicast-236096](https://raw.githubusercontent.com/chris17453/ttygif/master/examples/encode/236096.gif)

