# cython: profile=True
# cython: linetrace=True
# cython: binding=True

import sys
import time
import select


def has_stdin():
    if select.select([sys.stdin,],[],[],0.0)[0]:
        if sys.stdin.isatty()==True:
            return None
        else:
            return True
    return None

def read_stdin():
    ts = round(time.time(),8)
    events=[]
    try:
        o="start"
        sys.stdin.flush()
        while o:
            #if sys.stdin.closed:

            o= sys.stdin.readline()
            #print o
            timestamp=round(time.time(),8)-ts
            #print timestamp
            events.append([timestamp,'o',o])
        #print len(events)
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
