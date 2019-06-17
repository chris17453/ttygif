import re





text="""
\u001b]777;notify;Command completed;ls -lhat\
\u001b]777;notify;Command completed;ls -lhat\\u001bfdsfsdfsd
\u001b]777;notify;Command completed;ls -lhat\

"""
# patterns for filtering out commands from the stream
ANSI_SINGLE       ='[\001b|\033]([cDEHMZ78>=])'
ANSI_CHAR_SET     = '[\001b|\033]\\%([@G*])'
ANSI_G0           = '[\001b|\033]\\(([B0UK])'
ANSI_G1           = '[\001b|\033]\\)([B0UK])'
ANSI_CSI_RE       = '[\001b|\033]\\[((?:\\d|;|<|>|=|\?)*)([a-zA-Z])\002?'
ANSI_OSC_777_REGEX='[\0x1b|\033]\]777[;]([._:A-Za-z0-9\-\s]*)[;]([._:A-Za-z0-9\-\s]*)[;]([._:A-Za-z0-9\-\s]*)'

ESC_SEQUENCES=[ANSI_SINGLE,ANSI_CHAR_SET,ANSI_G0,ANSI_G1,ANSI_CSI_RE,ANSI_OSC_777_REGEX]

ANSI_REGEX="("+")|(".join(ESC_SEQUENCES)+")"

            
        
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
