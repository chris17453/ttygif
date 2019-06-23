import sys
import time
import select


def has_stdin():
    mode=1
    if mode==1:
        if sys.stdin.isatty():
            return True
    else:
        if select.select([sys.stdin,],[],[],0.0)[0]:
            return True
    return None

def read_stdin():
    ts = time.time()
    events=[]
    try:
        while True:
            o= sys.stdin.read(1)
            timestamp=time.time()-ts
            events.append([timestamp,'o',o])
    except KeyboardInterrupt:
        sys.stdout.flush()
        pass

    stream={'version':2,
        'width':80,
        'height':25,
        'timestamp':ts,
        'title':'',
        'env':'',
        'events':events}

    return stream
