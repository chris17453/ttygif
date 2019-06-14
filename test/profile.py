import os
import sys
import cProfile 
import pstats
from .context import ttygif
from subprocess import Popen,PIPE


run=['cast']

dirs=[  "profile/{0}".format(ttygif.version.__version__),
        "profile/{0}/proc".format(ttygif.version.__version__),
        "profile/{0}/callgraph".format(ttygif.version.__version__)
]
print ("Director creation")
for dir in dirs:
    if os.path.exists(dir)==False:
        os.mkdir(dir)
        print("Created Directory {0}".format(dir))

print ("Function execution")

for func in run:
    profile_name="profile/{0}/proc/{1}.prof".format(ttygif.version.__version__,func)
    callgraph_name="profile/{0}/callgraph/{1}.png".format(ttygif.version.__version__,func)
    if os.path.exists(profile_name)==True:
        os.remove(profile_name)
        print("Deleted {0}".format(profile_name))
    
    
    #ttygif.cast2gif.cast2gif('data/234628.cast','a.gif',1,'1',None)
    cProfile.runctx("ttygif.cast2gif.cast2gif('data/232377.cast','a.gif',1,'1',None)".format(func)   , globals(), locals())
    
    print profile_name
    s = pstats.Stats(profile_name)
    s.strip_dirs().sort_stats("time").print_stats()
    print "gprof2dot -f pstats {0} | dot -Tpng -o output.png".format(profile_name)
    print 'test/callgraph.sh',profile_name,callgraph_name
    os_cmd(['test/callgraph.sh',profile_name,callgraph_name],"Callgrapoh failed")

