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
        while has_stdin():
            sys.stdin.flush()
            o= sys.stdin.readline()
            o= o.replace("\n","\\n")
            o= o.replace("\r","\\r")
            o= o.replace("\t","\\t")
            o =o.replace("\b","\\b")
            if ""==o: # empyt line will be \n
                break
            timestamp=round(time.time(),8)-ts
            #print timestamp
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
