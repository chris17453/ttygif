import re





text="""{"version": 2, "width": 140, "height": 75, "timestamp": 1560804093, "env": {"SHELL": "/bin/bash", "TERM": "xterm-256color"}}
[0.116413, "o", "\u001b]777;notify;Command completed;make upload\u001b\\\u001b]0;nd@nd-dm:~/chris17453/ttygif\u001b\\\u001b]7;file://nd-dm/home/nd/chris17453/ttygif\u001b\\"]
[0.117123, "o", "[nd@nd-dm ttygif]$ "]
[1.566342, "o", "l"]
[1.614358, "o", "s"]
[1.754278, "o", "\r\n"]
[1.755723, "o", "\u001b[0m\u001b[38;5;33mbuild\u001b[0m   \u001b[38;5;40mbump.sh\u001b[0m  \u001b[38;5;33mexamples\u001b[0m  MANIFEST     meta.cast  Pipfile       \u001b[38;5;33mprofile\u001b[0m    setup.py  \u001b[38;5;33mttygif\u001b[0m           version\r\n\u001b[38;5;33mbuilds\u001b[0m  \u001b[38;5;33mdata\u001b[0m     Makefile  MANIFEST.in  notes.md   Pipfile.lock  README.md  \u001b[38;5;33mtest\u001b[0m      \u001b[38;5;33mttygif.egg-info\u001b[0m\r\n"]
[1.759887, "o", "\u001b]777;notify;Command completed;ls\u001b\\\u001b]0;nd@nd-dm:~/chris17453/ttygif\u001b\\\u001b]7;file://nd-dm/home/nd/chris17453/ttygif\u001b\\"]
[1.75998, "o", "[nd@nd-dm ttygif]$ "]
[2.13831, "o", "l"]
[2.229319, "o", "s"]
[2.726444, "o", " "]
[2.896292, "o", "-"]
[3.144268, "o", "l"]
[3.391326, "o", "h"]
[3.441258, "o", "a"]
[3.658291, "o", "t"]
[3.77324, "o", "\r\n"]
[3.774914, "o", "total 100K\r\n"]
[3.775019, "o", "-rw-rw-r--   1 nd nd 1.3K Jun 17 16:41 meta.cast\r\ndrwxrwxr-x  12 nd nd 4.0K Jun 17 16:41 \u001b[0m\u001b[38;5;33m.\u001b[0m\r\ndrwxrwxr-x   8 nd nd 4.0K Jun 17 16:36 \u001b[38;5;33m.git\u001b[0m\r\ndrwxrwxr-x   5 nd nd 4.0K Jun 17 16:36 \u001b[38;5;33mttygif\u001b[0m\r\n-rw-rw-r--   1 nd nd    8 Jun 17 16:36 version\r\ndrwxrwxr-x  80 nd nd 4.0K Jun 16 21:29 \u001b[38;5;33mprofile\u001b[0m\r\ndrwxrwxr-x   2 nd nd 4.0K Jun 16 21:29 \u001b[38;5;33mttygif.egg-info\u001b[0m\r\n-rw-rw-r--   1 nd nd 2.2K Jun 16 19:48 Makefile\r\n-rw-rw-r--   1 nd nd 3.3K Jun 16 13:45 README.md\r\n-rw-rw-r--   1 nd nd   75 Jun 15 21:30 .gitignore\r\ndrwxrwxr-x   4 nd nd 4.0K Jun 15 21:26 \u001b[38;5;33mbuild\u001b[0m\r\n-rw-rw-r--   1 nd nd 5.4K Jun 15 21:26 setup.py\r\ndrwxrwxr-x   2 nd nd 4.0K Jun 15 21:19 \u001b[38;5;33mdata\u001b[0m\r\n-rw-rw-r--   1 nd nd 1.1K Jun 15 20:06 MANIFEST\r\ndrwxrwxr-x. 16 nd nd 4.0K Jun 14 11:47 \u001b[38;5;33m..\u001b[0m\r\ndrwxrwxr-x   2 nd nd 4.0K Jun 14 11:45 \u001b[38;5;33mtest\u001b[0m\r\ndrwxrwxr-x   3 nd nd 4.0K Jun 14 11:44 \u001b[38;5;33mbuilds\u001b[0m\r\ndrwxrwxr-x   6 nd nd 4.0K Jun 14 11:38 \u001b[38;5;33mexamples\u001b[0m\r\n-rw-rw-"]
[3.77512, "o", "r--   1 nd nd 1.8K Jun 14 11:38 notes.md\r\n-rwxrwxr-x   1 nd nd  327 Jun 14 11:38 \u001b[38;5;40mbump.sh\u001b[0m\r\n-rw-rw-r--   1 nd nd   17 Jun 14 11:38 MANIFEST.in\r\n-rw-rw-r--   1 nd nd  135 Jun 14 11:38 Pipfile\r\n-rw-rw-r--   1 nd nd 3.1K Jun 14 11:38 Pipfile.lock\r\ndrwxrwxr-x   3 nd nd 4.0K Jun 14 11:38 \u001b[38;5;33m.vscode\u001b[0m\r\n"]
[3.779237, "o", "\u001b]777;notify;Command completed;ls -lhat\u001b\\ \u001b]0;nd@nd-dm:~/chris17453/ttygif\u001b\\\u001b]7;file://nd-dm/home/nd/chris17453/ttygif\u001b\\"]
[3.779323, "o", "[nd@nd-dm ttygif]$ "]
[4.112293, "o", "e"]
[4.341289, "o", "x"]
[4.523257, "o", "i"]
[4.579226, "o", "t"]
[4.829272, "o", "\r\n"]
[4.829417, "o", "exit\r\n"]
"""
# patterns for filtering out commands from the stream
ANSI_SINGLE       ='[\001b|\033]([cDEHMZ78>=])'
ANSI_CHAR_SET     = '[\001b|\033]\\%([@G*])'
ANSI_G0           = '[\001b|\033]\\(([B0UK])'
ANSI_G1           = '[\001b|\033]\\)([B0UK])'
ANSI_CSI_RE       = '[\001b|\033]\\[((?:\\d|;|<|>|=|\?)*)([a-zA-Z])\002?'
ANSI_OSC_777_REGEX='[\001b|\033]\\]777[;]([._:A-Za-z0-9\-\s]*)[;]([._:A-Za-z0-9\-\s]*)[;]([._:A-Za-z0-9\-\s]*)\001?\\\\'
#ANSI_OS           ='[\001b|\033]\\]((?:.|;)*?)\001?[7]'
ANSI_OS ='(?:\001?\\]|\x9d).*?(?:\001?\\\\|[\a\x9c])'

#while (<>) {
#    s/ \e[ #%()*+\-.\/]. |
#       \e\[ [ -?]* [@-~] | # CSI ... Cmd
#       \e\] .*? (?:\e\\|[\a\x9c]) | # OSC ... (ST|BEL)
#       \e[P^_] .*? (?:\e\\|\x9c) | # (DCS|PM|APC) ... ST
#       \e. //xg;
#    print;
#}
#while (<>) {
#    s/ \e[ #%()*+\-.\/]. |
#       (?:\e\[|\x9b) [ -?]* [@-~] | # CSI ... Cmd
#       (?:\e\]|\x9d) .*? (?:\e\\|[\a\x9c]) | # OSC ... (ST|BEL)
#       (?:\e[P^_]|[\x90\x9e\x9f]) .*? (?:\e\\|\x9c) | # (DCS|PM|APC) ... ST
#       \e.|[\x80-\x9f] //xg;
#    print;
#}

#ANSI_OSC_777_REGEX
ESC_SEQUENCES=[ANSI_SINGLE,ANSI_CHAR_SET,ANSI_G0,ANSI_G1,ANSI_CSI_RE,ANSI_OS]

#ANSI_OS           ='[\0x1b|\033]\\]((?:.|;)*?)\002?'
#ANSI_SINGLE,ANSI_CHAR_SET,ANSI_G0,ANSI_G1,ANSI_CSI_RE,

ANSI_REGEX="("+")|(".join(ESC_SEQUENCES)+")"
#ANSI_REGEX0=ANSI_OSC_777_REGEX
print ANSI_REGEX
            
        
ANSI=re.compile(ANSI_REGEX)
cursor=0
print ("START")
print text
for match in ANSI.finditer(text):
    name=""
    start, end = match.span()
    print text[start:end]
    cursor = end
    groups=match.groups()
    print groups


print ("End")
