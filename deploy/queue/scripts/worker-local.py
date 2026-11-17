#!/usr/bin/env python3
"""Processa uma submissão da cópia local; PHP e aluno ficam em containers separados."""
from pathlib import Path
import argparse
import json
import os
import subprocess
from cpp_runner import ROOT,judge
from local_support import DATABASES

def run(instance):
    assert instance in DATABASES
    environment=None
    if os.environ.get('LABOO_NATIVE_BRIDGE')=='1':
        assert os.geteuid()==0, 'A ponte nativa exige coordenador administrativo.'
        environment={**os.environ,'LABOO_WORKER_ENABLED':'1','LABOO_INSTANCE':instance,
                     'LABOO_BASE_URL':os.environ['LABOO_PUBLIC_URL'].rstrip('/')+'/'+instance+'/',
                     'LABOO_STATE_DIR':str(ROOT/'cli-state'/instance)}
        args=['runuser','-u','laboo-web','--','/usr/bin/php8.5',
              os.environ['LABOO_ENTRYPOINT'],'labooworker','run']
    else:
        args=['docker','exec','-i','-e','LABOO_WORKER_ENABLED=1','-e','LABOO_INSTANCE='+instance,
          '-e','LABOO_BASE_URL=http://127.0.0.1:9080/'+instance+'/',
          '-e','LABOO_STATE_DIR=/state/'+instance,'laboo-modern-php-1',
          'php8.5','/app/index.php','labooworker','run']
    with (ROOT/'reports/worker-private.log').open('ab') as log:
        bridge=subprocess.Popen(args,stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=log,text=True,env=environment)
        try:
            line=bridge.stdout.readline()
            if not line:raise RuntimeError('Ponte CLI sem resposta; consultar logs privados.')
            job=json.loads(line)
            if job['state']!='job':
                assert bridge.wait(timeout=15)==0
                return job
            item=job['queue'];submission=job['submission'];problem_info=job['problem']
            assert job['instance']==instance and submission['file_type']=='cpp'
            assignment=int(item['assignment']);problem_id=int(item['problem'])
            assert assignment>0 and problem_id>0
            root=ROOT/'data'/instance/'assignments'
            problem=root/f'assignment_{assignment}'/f'p{problem_id}'
            directory=problem/item['username']
            assert directory.resolve().is_relative_to(problem.resolve()) and directory.is_dir()
            candidates=[directory/(submission['file_name']+ext) for ext in ['.zip','.7z','.cpp']]
            source=next((p for p in candidates if p.is_file()),None)
            assert problem_info['diff_cmd']=='diff', 'Modo de comparação ainda não validado.'
            if source is None:
                # Ex.: .rar (aceito pelo formulário antigo). Nota ao aluno, sem prender a fila.
                result={'status':'Compilation Error','pre_score':0,'tests':[],
                        'compiler':'Formato não suportado: envie .cpp, .zip ou .7z.'}
            else:
                assert source.resolve().is_relative_to(directory.resolve())
                result=judge(source,problem,seconds=int(problem_info['c_time_limit'])/1000,
                             memory_kb=int(problem_info['memory_limit']),output_bytes=int(job['output_bytes']),
                             diff_arg=problem_info['diff_arg'],
                             shield=ROOT/'data'/instance/'tester/shield' if job['cpp_shield'] else None)
            bridge.stdin.write(json.dumps(result)+'\n');bridge.stdin.flush();bridge.stdin.close()
            saved=json.loads(bridge.stdout.readline())
            assert bridge.wait(timeout=20)==0 and saved['state']=='saved'
            return saved
        finally:
            if bridge.poll() is None:
                bridge.stdin.close()
                try:bridge.wait(timeout=5)
                except subprocess.TimeoutExpired:bridge.terminate();bridge.wait(timeout=5)

if __name__=='__main__':
    os.umask(0o077)
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('instance',choices=DATABASES)
    args=parser.parse_args()
    print(json.dumps(run(args.instance)))
