import json 

class asciicast_reader:
    def __init__(self,debug=None):
        self.debug=debug

    def load(self,filename):
        cast={}
        header={}
        events=[]
        with open(filename,'r') as content:
            header=json.loads(content.readline())
            for line in  content:
                events.append(json.loads(line))
        
        if 'title' not in header:
            header['title']=''
        

        return {'version':header['version'],
                'width':header['width'],
                'height':header['height'],
                'timestamp':header['timestamp'],
                'title':header['title'],
                'env':header['env'],
                'events':events
        }

