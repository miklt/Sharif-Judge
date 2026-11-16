"""Operações apenas no laboratório LABOO, com saída privada por padrão."""
from pathlib import Path
import http.client
import json
import os
import socket
import subprocess

ROOT = Path(os.environ.get('LABOO_RUNTIME_ROOT','/home/michelet/laboo-local'))
DATABASES = {'aula':'judgedb_aula_s2_2026','ep':'judgedb_ep_s1_2026',
             'monitoria':'judgedb_monitoria_2023','piloto':'piloto_s2_2026','teste':'judgedb_teste_s1_2023'}
# Servidores novos (ex.: prova) declaram suas instâncias: {"aula": "judge_aula"}.
if os.environ.get('LABOO_INSTANCES'):
    DATABASES = json.loads(os.environ['LABOO_INSTANCES'])
    assert DATABASES and all(isinstance(k, str) and k.isalnum() for k in DATABASES), 'LABOO_INSTANCES inválido.'
NATIVE_TESTING = os.environ.get('LABOO_NATIVE_TESTING') == '1'
if NATIVE_TESTING:
    assert ROOT == Path('/srv/laboo/stage-20261116')
    DATABASES = {name:'laboo_stage_'+name+'_20261116' for name in DATABASES}

def sql(query, database='postgres'):
    if NATIVE_TESTING:
        assert os.geteuid()==0 and database in DATABASES.values()
        command=['sudo','-u','postgres','psql','-X','-p','5434','-d',database,'-qAt','-v','ON_ERROR_STOP=1']
    else:
        command=['docker','exec','-i','laboo-modern-db-1','psql','-X','-U','postgres',
                 '-d',database,'-qAt','-v','ON_ERROR_STOP=1']
    with (ROOT/'reports/sql-private.log').open('ab') as log:
        p = subprocess.run(command,
                           input=query.encode(), stdout=subprocess.PIPE, stderr=log)
    if p.returncode:
        raise RuntimeError('Falha SQL; consultar relatório privado.')
    return p.stdout.decode().strip()

def literal(s):
    return "'"+str(s).replace("'","''")+"'"

class UnixHTTP(http.client.HTTPConnection):
    def connect(self):
        self.sock = socket.socket(socket.AF_UNIX,socket.SOCK_STREAM)
        self.sock.settimeout(40)
        self.sock.connect(str(ROOT/'http-socket/http.sock'))

class Browser:
    def __init__(self):
        self.cookies = {}

    def request(self, path, body=None, content_type='application/x-www-form-urlencoded'):
        c = http.client.HTTPConnection('127.0.0.1',18085,timeout=40) if NATIVE_TESTING else UnixHTTP('127.0.0.1',9080,timeout=40)
        headers = {'Host':'127.0.0.1:'+('18085' if NATIVE_TESTING else '9080'),'Cookie':'; '.join(k+'='+v for k,v in self.cookies.items())}
        if body is not None:
            headers['Content-Type'] = content_type
        c.request('POST' if body is not None else 'GET',path,body=body,headers=headers)
        r = c.getresponse()
        data = r.read()
        for k,v in r.getheaders():
            if k.lower()=='set-cookie':
                key, value = v.split(';',1)[0].split('=',1)
                self.cookies[key]=value
        result=(r.status,dict(r.getheaders()),data)
        c.close()
        return result

def save_report(name, report):
    (ROOT/'reports'/name).write_text(json.dumps(report,indent=2))
