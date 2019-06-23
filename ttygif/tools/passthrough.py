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
    ts = time.time()
    events=[]
    try:
        while has_stdin():
            sys.stdin.flush()
            o= sys.stdin.readline()
            if ""==o: # empyt line will be \n
                break
            timestamp=time.time()-ts
            print timestamp
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
