#!/usr/bin/env python3
"""Supervisor serial de filas exclusivamente do laboratório LABOO local."""
from pathlib import Path
import argparse
import datetime
import importlib.util
import json
import os
import signal
import subprocess
import sys
import time
from local_support import ROOT,DATABASES

os.umask(0o077)
script=Path(__file__).resolve();pidfile=ROOT/'supervisor.pid'
parser=argparse.ArgumentParser(description=__doc__)
mode=parser.add_mutually_exclusive_group()
mode.add_argument('--background',action='store_true')
mode.add_argument('--stop',action='store_true')
args=parser.parse_args()

def active_pid():
    if not pidfile.exists():return None
    pid=int(pidfile.read_text())
    try:command=Path(f'/proc/{pid}/cmdline').read_bytes().split(b'\0')
    except FileNotFoundError:return None
    assert str(script).encode() in command, 'PID não pertence ao supervisor LABOO.'
    return pid

if args.stop:
    pid=active_pid()
    if pid:os.kill(pid,signal.SIGTERM)
    print('Parada solicitada; a tarefa atual será concluída antes de sair.')
    sys.exit(0)
assert active_pid() is None,'Supervisor já está ativo.'
if args.background:
    with (ROOT/'reports/supervisor-private.log').open('ab') as log:
        process=subprocess.Popen([sys.executable,str(script)],stdin=subprocess.DEVNULL,
                                 stdout=log,stderr=log,start_new_session=True)
    time.sleep(0.3)
    assert process.poll() is None
    print('Supervisor ativo; processamento serial das filas configuradas.');sys.exit(0)
pidfile.write_text(str(os.getpid()))
spec=importlib.util.spec_from_file_location('worker',str(script.with_name('worker-local.py')))
worker=importlib.util.module_from_spec(spec);spec.loader.exec_module(worker)
running=True
def stop(signum,frame):
    global running
    running=False
signal.signal(signal.SIGTERM,stop);signal.signal(signal.SIGINT,stop)
try:
    while running:
        failed=False
        for instance in DATABASES:
            if not running:break
            try:
                result=worker.run(instance)
                if result['state']=='saved':
                    print(json.dumps({'time':datetime.datetime.now(datetime.timezone.utc).isoformat(),
                                      'instance':instance,**result}),flush=True)
            except Exception as error:
                # Nenhum payload/identidade/SQL na mensagem de supervisão.
                print(json.dumps({'instance':instance,'error_type':type(error).__name__,
                                  'queue_preserved':True}),flush=True)
                failed=True
        for i in range(50 if failed else 20):
            if not running:break
            time.sleep(0.1)
finally:
    if pidfile.exists() and pidfile.read_text()==str(os.getpid()):pidfile.unlink()
