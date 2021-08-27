# cython: profile=True
# cython: linetrace=True
# cython: binding=True
# cython: language_level=2

import json 
import copy
import re

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

    def write(self,file,stream):
        
        with open(file,"w") as outfile:
            header="{{'version':{0},'width':{1},'height':{2},'timestamp':{3},'title':{4},'env':{5}}}\n".format(stream['version'],stream['width'],stream['height'],stream['timestamp'],stream['title'],stream['env'])
            outfile.write(header)
            
            for event in stream['events']:
                o=copy.deepcopy(event[2])
                o = re.escape(o)

                outfile.write("[{0:.10f},'{1}',{2}]\n".format(event[0],event[1],repr(o)))
