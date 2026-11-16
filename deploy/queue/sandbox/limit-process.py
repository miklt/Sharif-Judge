#!/usr/bin/env python3
"""PID 1 do container de execução. Só recebe um binário e o stdin do caso."""
import base64
import json
import math
import os
import resource
from pathlib import Path
import shutil
import signal
import subprocess
import sys
import time

seconds=float(sys.argv[1]); memory=int(sys.argv[2]); output=int(sys.argv[3])
assert 0 < seconds <= 60 and 8*1024*1024 <= memory <= 1024**3 and 0 < output <= 8*1024*1024
work=Path('/tmp/work');work.mkdir(mode=0o700)
for source in Path('/code').iterdir():
    if source.name != 'program' and source.is_file() and not source.is_symlink():
        shutil.copyfile(source,work/source.name)

def limits():
    resource.setrlimit(resource.RLIMIT_CPU,(math.ceil(seconds),math.ceil(seconds)+1))
    resource.setrlimit(resource.RLIMIT_AS,(memory,memory))
    resource.setrlimit(resource.RLIMIT_FSIZE,(output,output))
    resource.setrlimit(resource.RLIMIT_CORE,(0,0))
    resource.setrlimit(resource.RLIMIT_NOFILE,(64,64))
    os.setsid()

with open('/tmp/stdout','w+b') as out, open('/tmp/stderr','w+b') as err:
    started=time.monotonic()
    p=subprocess.Popen(['/code/program'],stdin=sys.stdin.buffer,stdout=out,stderr=err,preexec_fn=limits,env={'LANG':'en_US.UTF-8','PATH':'/usr/bin:/bin'},cwd=str(work))
    status='OK'
    try:
        p.wait(timeout=seconds+0.05)
    except subprocess.TimeoutExpired:
        status='Time Limit Exceeded'
        os.killpg(p.pid,signal.SIGKILL)
        p.wait()
    elapsed=time.monotonic()-started
    # Matar descendentes mesmo quando o pai terminou antes do prazo.
    try: os.killpg(p.pid,signal.SIGKILL)
    except ProcessLookupError: pass
    if status=='OK' and p.returncode:
        status='Output Size Limit Exceeded' if p.returncode==-signal.SIGXFSZ else 'Runtime Error'
    out.seek(0); err.seek(0)
    stdout=out.read(output); stderr=err.read(min(output,4096))
    print(json.dumps({'status':status,'exit_code':p.returncode,'seconds':round(elapsed,4),
                      'stdout':base64.b64encode(stdout).decode(),'stderr':base64.b64encode(stderr).decode()}))
