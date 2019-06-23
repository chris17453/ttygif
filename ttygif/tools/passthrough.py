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
            if sys.stdin.closed:
                break
            o= sys.stdin.readline()
            #if ""==o: # empty line will be \n
            #    continue
            timestamp=round(time.time(),8)-ts
            #print timestamp
            events.append([timestamp,'o',o])
        print len(events)
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
