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

def os_cmd(cmd,err_msg):
    p = Popen(cmd, stdin=PIPE, stdout=PIPE, stderr=PIPE)
    output, err = p.communicate()
    rc = p.returncode
    if rc!=0:
        print(output)
        print(err)
        raise Exception("{0}: Exit Code {1}".format(err_msg,rc))
    return output
    


print ("Function execution")

for func in run:
    profile_name="profile/{0}/proc/{1}.prof".format(ttygif.version.__version__,func)
    callgraph_name="profile/{0}/callgraph/{1}.png".format(ttygif.version.__version__,func)
    if os.path.exists(profile_name)==True:
        os.remove(profile_name)
        print("Deleted {0}".format(profile_name))
    
    
    #ttygif.cast2gif.cast2gif('data/234628.cast','a.gif',1,'1',None)
    #events=None,dilation=1,loop_count=0xFFFF,frame_rate=100,loop_delay=1000,natural=None,debug=None,width=None,height=None,underlay=None                                          ():
    cProfile.runctx("ttygif.cast2gif.cast2gif(cast_file='assets/cast/232377.cast',gif_file='assets/encode/232377_profile.gif',frame_rate=12,theme_name='windows7')".format(func)   , globals(), locals(),profile_name)
    
    print profile_name
    s = pstats.Stats(profile_name)
    s.strip_dirs().sort_stats("time").print_stats()
    print "gprof2dot -f pstats {0} | dot -Tpng -o output.png".format(profile_name)
    print 'test/callgraph.sh',profile_name,callgraph_name
    os_cmd(['test/callgraph.sh',profile_name,callgraph_name],"Callgrapoh failed")

