#!/usr/bin/env python3
"""Teste de fumaça do servidor de prova: login → envio C++ → fila → nota.

Executar como root NO servidor, antes da prova:
    python3 smoke-exam.py --instance aula --database judge_aula

Cria um aluno, uma turma e um exercício temporários (id 32700), passa pelo
HTTP Basic com um usuário temporário, envia uma solução pela interface e
espera a nota 10000 da fila. Tudo o que foi criado é removido no final,
inclusive em caso de falha. Não lê nem altera dados de alunos reais.
"""
import argparse
import http.client
import json
import re
import secrets
import shutil
import subprocess
import sys
import time
import urllib.parse
from pathlib import Path

ASSIGNMENT = 32700  # shj_assignments.id é smallint
USERNAME = 'labooexamsmoke'
CLASS_NAME = 'LABOO smoke test'

parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
parser.add_argument('--instance', default='aula')
parser.add_argument('--database', default='judge_aula')
parser.add_argument('--pg-port', default='5432')
parser.add_argument('--http-port', type=int, default=80)
parser.add_argument('--htpasswd', help='padrão: /etc/apache2/laboo-<instância>.htpasswd, se existir')
parser.add_argument('--timeout', type=int, default=90)
args = parser.parse_args()
assert re.fullmatch(r'[a-z0-9]{2,20}', args.instance)
htpasswd = Path(args.htpasswd or f'/etc/apache2/laboo-{args.instance}.htpasswd')


def sql(query):
    p = subprocess.run(['runuser', '-u', 'postgres', '--', 'psql', '-X', '-qAt', '-p', args.pg_port,
                        '-d', args.database, '-v', 'ON_ERROR_STOP=1'],
                       input=query.encode(), capture_output=True)
    if p.returncode:
        raise RuntimeError('SQL falhou: ' + p.stderr.decode(errors='replace')[:300])
    return p.stdout.decode().strip()


class Browser:
    def __init__(self, basic=None):
        self.cookies, self.basic = {}, basic

    def request(self, path, body=None, content_type='application/x-www-form-urlencoded'):
        c = http.client.HTTPConnection('127.0.0.1', args.http_port, timeout=40)
        headers = {'Cookie': '; '.join(k + '=' + v for k, v in self.cookies.items())}
        if self.basic:
            headers['Authorization'] = 'Basic ' + self.basic
        if body is not None:
            headers['Content-Type'] = content_type
        c.request('POST' if body is not None else 'GET', f'/{args.instance}/{path}', body=body, headers=headers)
        r = c.getresponse()
        data = r.read()
        for k, v in r.getheaders():
            if k.lower() == 'set-cookie':
                key, value = v.split(';', 1)[0].split('=', 1)
                self.cookies[key] = value
        c.close()
        return r.status, data


def token(body):
    m = re.search(rb'name="([^"]*csrf[^"]*)" value="([^"]+)"', body)
    assert m, 'Token CSRF ausente na página.'
    return m[1].decode(), m[2].decode()


def cleanup(root):
    sql(f"""
        DELETE FROM shj_queue WHERE assignment = {ASSIGNMENT};
        DELETE FROM shj_submissions WHERE assignment = {ASSIGNMENT};
        DELETE FROM shj_assignments_classes WHERE assignment_id = {ASSIGNMENT};
        DELETE FROM shj_problems WHERE assignment = {ASSIGNMENT};
        DELETE FROM shj_assignments WHERE id = {ASSIGNMENT};
        DELETE FROM shj_users_classes WHERE user_id IN (SELECT id FROM shj_users WHERE username = '{USERNAME}');
        DELETE FROM shj_classes WHERE class_name = '{CLASS_NAME}';
        DELETE FROM shj_users WHERE username = '{USERNAME}';
    """)
    if root:
        shutil.rmtree(Path(root) / f'assignment_{ASSIGNMENT}', ignore_errors=True)
    if htpasswd.is_file():
        subprocess.run(['htpasswd', '-D', str(htpasswd), USERNAME], capture_output=True)


root = sql("SELECT shj_value FROM shj_settings WHERE shj_key = 'assignments_root'")
assert root and Path(root).is_dir(), 'assignments_root inválido.'
assert sql(f'SELECT count(*) FROM shj_assignments WHERE id = {ASSIGNMENT}') == '0', \
    'Exercício 32700 já existe; remova resíduos de um teste anterior.'
password = secrets.token_urlsafe(18)
report = {'instance': args.instance}
started = time.monotonic()
try:
    hashed = subprocess.run(['php', '-r', 'echo password_hash(stream_get_contents(STDIN), PASSWORD_BCRYPT);'],
                            input=password.encode(), capture_output=True, check=True).stdout.decode()
    sql(f"""
        INSERT INTO shj_users (username, password, display_name, email, role, selected_assignment)
          VALUES ('{USERNAME}', '{hashed}', 'Teste de fumaça', '{USERNAME}@example.invalid', 'student', {ASSIGNMENT});
        INSERT INTO shj_assignments (id, name, problems, total_submits, open, scoreboard, javaexceptions, description,
            start_time, finish_time, extra_time, late_rule, participants)
          VALUES ({ASSIGNMENT}, 'LABOO smoke test', 1, 0, 1, 0, 0, 'Teste automático', now() - interval '1 hour',
            now() + interval '1 hour', 0, '$coefficient = 100;', '{USERNAME}');
        INSERT INTO shj_problems (assignment, id, name, score, is_upload_only, c_time_limit, python_time_limit,
            java_time_limit, memory_limit, allowed_languages, diff_cmd, diff_arg, weight)
          VALUES ({ASSIGNMENT}, 1, 'Soma', 100, 0, 1000, 1500, 2000, 65536, 'C++', 'diff', '-bB', 1);
        WITH c AS (INSERT INTO shj_classes (time_start, time_end, day, classroom, class_name)
                   VALUES ('00:00', '23:59', 1, 'Teste', '{CLASS_NAME}') RETURNING id)
        INSERT INTO shj_assignments_classes (assignment_id, class_id) SELECT {ASSIGNMENT}, id FROM c;
        INSERT INTO shj_users_classes (user_id, class_id, responsible)
          SELECT u.id, c.id, 0 FROM shj_users u, shj_classes c WHERE u.username = '{USERNAME}' AND c.class_name = '{CLASS_NAME}';
    """)
    problem = Path(root) / f'assignment_{ASSIGNMENT}' / 'p1'
    for child in ['in', 'out']:
        (problem / child).mkdir(parents=True, exist_ok=True)
    (problem / 'in/input1.txt').write_text('2 3\n')
    (problem / 'out/output1.txt').write_text('5\n')
    (problem / 'desc.html').write_text('<p>Some dois inteiros.</p>')
    shutil.chown(Path(root) / f'assignment_{ASSIGNMENT}', 'laboo-web', 'laboo-web')
    subprocess.run(['chown', '-R', 'laboo-web:laboo-web', str(Path(root) / f'assignment_{ASSIGNMENT}')], check=True)

    basic = None
    if htpasswd.is_file():
        subprocess.run(['htpasswd', '-i', '-B', str(htpasswd), USERNAME], input=password.encode(),
                       capture_output=True, check=True)
        import base64
        basic = base64.b64encode(f'{USERNAME}:{password}'.encode()).decode()
    browser = Browser(basic)
    status, body = browser.request('login')
    assert status == 200, ('login GET', status)
    name, value = token(body)
    status, body = browser.request('login', urllib.parse.urlencode({'username': USERNAME, 'password': password, name: value}))
    assert status in (302, 303), ('login POST', status)
    status, body = browser.request(f'problems/{ASSIGNMENT}/1')
    assert status == 200, ('problema', status)
    name, value = token(body)
    boundary = 'LABOOsmoke' + secrets.token_hex(8)
    source = b'#include <iostream>\nint main(){int a,b;std::cin>>a>>b;std::cout<<a+b<<"\\n";}\n'
    parts = [f'--{boundary}\r\nContent-Disposition: form-data; name="{k}"\r\n\r\n{v}\r\n'.encode()
             for k, v in [('problem', '1'), ('language', 'C++'), (name, value)]]
    parts.append(f'--{boundary}\r\nContent-Disposition: form-data; name="userfile"; filename="main.cpp"\r\n'
                 'Content-Type: text/x-c++src\r\n\r\n'.encode() + source + b'\r\n')
    parts.append(f'--{boundary}--\r\n'.encode())
    status, body = browser.request('problems/form_validation', b''.join(parts), 'multipart/form-data; boundary=' + boundary)
    assert status in (302, 303), ('envio', status)
    submitted = time.monotonic()
    while True:
        state = sql(f"SELECT status || '|' || pre_score FROM shj_submissions WHERE assignment = {ASSIGNMENT} "
                    f"AND username = '{USERNAME}' ORDER BY submit_id DESC LIMIT 1")
        if state and not state.startswith('PENDING'):
            break
        assert time.monotonic() - submitted < args.timeout, 'A fila não corrigiu dentro do prazo.'
        time.sleep(0.3)
    report.update({'result': state, 'queue_seconds': round(time.monotonic() - submitted, 2)})
    assert state == 'SCORE|10000', state
    report['passed'] = True
finally:
    cleanup(root)
    report['total_seconds'] = round(time.monotonic() - started, 2)
    print(json.dumps(report))
