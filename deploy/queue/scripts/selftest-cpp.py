#!/usr/bin/env python3
"""Autoteste do runner C++ nativo após a instalação (sem dados de alunos)."""
from pathlib import Path
import json
import os
import shutil
import time

from cpp_runner import ROOT, BACKEND, judge

os.umask(0o077)
base = ROOT/'selftest'
shutil.rmtree(base, ignore_errors=True)
problem = base/'problem'
for child in ['in', 'out']:
    (problem/child).mkdir(mode=0o700, parents=True)
(problem/'in/input1.txt').write_text('2 3\n')
(problem/'out/output1.txt').write_text('5\n')
cases = {
    'accepted': ('#include <iostream>\nint main(){int a,b;std::cin>>a>>b;std::cout<<a+b<<"\\n";}\n', 10000),
    'wrong': ('#include <iostream>\nint main(){std::cout<<42;}\n', 0),
    'no_network': ('#include <sys/socket.h>\n#include <arpa/inet.h>\n#include <unistd.h>\n#include <iostream>\n'
                   'int main(){int s=socket(AF_INET,SOCK_STREAM,0);sockaddr_in a{};a.sin_family=AF_INET;'
                   'a.sin_port=htons(443);inet_pton(AF_INET,"1.1.1.1",&a.sin_addr);'
                   'std::cin.ignore(9);std::cout<<(connect(s,(sockaddr*)&a,sizeof(a))==0?0:5);close(s);}\n', 10000),
}
(problem/'out/output1.txt').write_text('5\n')
report = {'backend': BACKEND, 'cases': {}}
for name, (code, expected) in cases.items():
    source = base/(name+'.cpp')
    source.write_text(code)
    started = time.monotonic()
    result = judge(source, problem, seconds=1, output_bytes=8192)
    report['cases'][name] = {'passed': result.get('pre_score') == expected,
                             'status': result['status'], 'seconds': round(time.monotonic()-started, 3)}
shutil.rmtree(base, ignore_errors=True)
print(json.dumps(report))
assert BACKEND == 'native' and all(c['passed'] for c in report['cases'].values()), report
