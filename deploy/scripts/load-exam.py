#!/usr/bin/env python3
"""Teste de carga de prova para o judge (sem dados de alunos reais).

Fluxo:
  1. No servidor (root):   load-exam.py setup --students 60 > cred.json   (privado)
  2. No servidor (root):   load-exam.py monitor --duration 420 > monitor.json   (em paralelo)
  3. No controlador:       load-exam.py run --base-url URL --credentials cred.json
  4. No servidor (root):   load-exam.py teardown

O setup cria alunos laboocargaNNN, uma turma, o exercício 32701 (10 casos) e
uma senha HTTP Basic temporária. O teardown remove tudo, inclusive envios e
arquivos. Os envios misturam soluções corretas, pesadas, erradas, com erro de
compilação e com estouro de tempo (pior caso da fila serial).
"""
import argparse
import base64
import http.client
import json
import os
import random
import re
import secrets
import shutil
import statistics
import subprocess
import sys
import threading
import time
import urllib.parse
from pathlib import Path

ASSIGNMENT = 32701
PREFIX = 'laboocarga'
CLASS_NAME = 'LABOO carga'
BASIC_USER = 'laboocargabasic'
CASES = 10
SOLUTIONS = {
    'ok': '#include <iostream>\nint main(){long long a,b;std::cin>>a>>b;std::cout<<a+b<<"\\n";}\n',
    'heavy': ('#include <iostream>\n#include <vector>\n#include <algorithm>\nint main(){long long a,b;std::cin>>a>>b;'
              'std::vector<int> v(2000000);for(size_t i=0;i<v.size();i++)v[i]=(i*7919)%1000003;'
              'std::sort(v.begin(),v.end());std::cout<<a+b+(v[0]-v[0])<<"\\n";}\n'),
    'wrong': '#include <iostream>\nint main(){long long a,b;std::cin>>a>>b;std::cout<<a-b<<"\\n";}\n',
    'ce': '#include <iostream>\nint main(){ std::cout << ; }\n',
    'tle': '#include <iostream>\nint main(){long long a,b;std::cin>>a>>b;volatile long long x=0;for(;;)x++;}\n',
}
EXPECTED = {'ok': 'SCORE|10000', 'heavy': 'SCORE|10000', 'wrong': 'SCORE|0', 'ce': 'Compilation Error|0', 'tle': 'SCORE|0'}


# ---------------------------------------------------------------- servidor
def sql(args, query):
    p = subprocess.run(['runuser', '-u', 'postgres', '--', 'psql', '-X', '-qAt', '-p', args.pg_port,
                        '-d', args.database, '-v', 'ON_ERROR_STOP=1'], input=query.encode(), capture_output=True)
    if p.returncode:
        raise RuntimeError('SQL falhou: ' + p.stderr.decode(errors='replace')[:300])
    return p.stdout.decode().strip()


def htpasswd_path(args):
    return Path(args.htpasswd or f'/etc/apache2/laboo-{args.instance}.htpasswd')


def setup(args):
    assert os.geteuid() == 0
    root = sql(args, "SELECT shj_value FROM shj_settings WHERE shj_key = 'assignments_root'")
    assert sql(args, f'SELECT count(*) FROM shj_assignments WHERE id = {ASSIGNMENT}') == '0', 'Rode teardown antes.'
    password, basic_password = secrets.token_urlsafe(15), secrets.token_urlsafe(15)
    hashed = subprocess.run(['php', '-r', 'echo password_hash(stream_get_contents(STDIN), PASSWORD_BCRYPT);'],
                            input=password.encode(), capture_output=True, check=True).stdout.decode()
    users = [f'{PREFIX}{i:03d}' for i in range(1, args.students + 1)]
    values = ','.join(f"('{u}', '{hashed}', 'Carga {u[-3:]}', '{u}@example.invalid', 'student', {ASSIGNMENT})" for u in users)
    sql(args, f"""
        INSERT INTO shj_users (username, password, display_name, email, role, selected_assignment) VALUES {values};
        INSERT INTO shj_assignments (id, name, problems, total_submits, open, scoreboard, javaexceptions, description,
            start_time, finish_time, extra_time, late_rule, participants)
          VALUES ({ASSIGNMENT}, 'LABOO carga', 1, 0, 1, 1, 0, 'Teste de carga', now() - interval '1 hour',
            now() + interval '3 hours', 0, '$coefficient = 100;', 'ALL');
        INSERT INTO shj_problems (assignment, id, name, score, is_upload_only, c_time_limit, python_time_limit,
            java_time_limit, memory_limit, allowed_languages, diff_cmd, diff_arg, weight)
          VALUES ({ASSIGNMENT}, 1, 'Soma', 100, 0, 1000, 1500, 2000, 131072, 'C++', 'diff', '-bB', 1);
        WITH c AS (INSERT INTO shj_classes (time_start, time_end, day, classroom, class_name)
                   VALUES ('00:00', '23:59', 1, 'Carga', '{CLASS_NAME}') RETURNING id)
        INSERT INTO shj_assignments_classes (assignment_id, class_id) SELECT {ASSIGNMENT}, id FROM c;
        INSERT INTO shj_users_classes (user_id, class_id, responsible)
          SELECT u.id, c.id, 0 FROM shj_users u, shj_classes c
          WHERE u.username LIKE '{PREFIX}%' AND c.class_name = '{CLASS_NAME}';
        INSERT INTO shj_settings (shj_key, shj_value) SELECT 'laboo_queue_paused', '0'
          WHERE NOT EXISTS (SELECT 1 FROM shj_settings WHERE shj_key = 'laboo_queue_paused');
    """)
    problem = Path(root) / f'assignment_{ASSIGNMENT}' / 'p1'
    for child in ['in', 'out']:
        (problem / child).mkdir(parents=True, exist_ok=True)
    rnd = random.Random(7)
    for i in range(1, CASES + 1):
        a, b = rnd.randint(-10**9, 10**9), rnd.randint(-10**9, 10**9)
        (problem / f'in/input{i}.txt').write_text(f'{a} {b}\n')
        (problem / f'out/output{i}.txt').write_text(f'{a + b}\n')
    (problem / 'desc.html').write_text('<p>Some dois inteiros (teste de carga).</p>')
    subprocess.run(['chown', '-R', 'laboo-web:laboo-web', str(Path(root) / f'assignment_{ASSIGNMENT}')], check=True)
    ht = htpasswd_path(args)
    if ht.is_file():
        flag = {'bcrypt': '-B', 'apr1': '-m'}[args.basic_hash]
        subprocess.run(['htpasswd', '-i', flag, str(ht), BASIC_USER], input=basic_password.encode(),
                       capture_output=True, check=True)
    print(json.dumps({'assignment': ASSIGNMENT, 'students': users, 'password': password,
                      'basic': f'{BASIC_USER}:{basic_password}' if ht.is_file() else None}))


def teardown(args):
    assert os.geteuid() == 0
    root = sql(args, "SELECT shj_value FROM shj_settings WHERE shj_key = 'assignments_root'")
    counts = sql(args, f"SELECT count(*) FROM shj_submissions WHERE assignment = {ASSIGNMENT}")
    sql(args, f"""
        DELETE FROM shj_queue WHERE assignment = {ASSIGNMENT};
        DELETE FROM shj_submissions WHERE assignment = {ASSIGNMENT};
        DELETE FROM shj_scoreboard WHERE assignment = {ASSIGNMENT};
        DELETE FROM shj_assignments_classes WHERE assignment_id = {ASSIGNMENT};
        DELETE FROM shj_problems WHERE assignment = {ASSIGNMENT};
        DELETE FROM shj_assignments WHERE id = {ASSIGNMENT};
        DELETE FROM shj_users_classes WHERE user_id IN (SELECT id FROM shj_users WHERE username LIKE '{PREFIX}%');
        DELETE FROM shj_classes WHERE class_name = '{CLASS_NAME}';
        DELETE FROM shj_users WHERE username LIKE '{PREFIX}%';
    """)
    shutil.rmtree(Path(root) / f'assignment_{ASSIGNMENT}', ignore_errors=True)
    ht = htpasswd_path(args)
    if ht.is_file():
        subprocess.run(['htpasswd', '-D', str(ht), BASIC_USER], capture_output=True)
    left = sql(args, f"SELECT (SELECT count(*) FROM shj_users WHERE username LIKE '{PREFIX}%') + "
                     f"(SELECT count(*) FROM shj_assignments WHERE id = {ASSIGNMENT})")
    print(json.dumps({'removed_submissions': int(counts), 'leftover_rows': int(left)}))


def cpu_times():
    fields = Path('/proc/stat').read_text().splitlines()[0].split()[1:]
    values = list(map(int, fields))
    return sum(values), values[3] + values[4]


def monitor(args):
    assert os.geteuid() == 0
    seen, samples = {}, []
    end = time.monotonic() + args.duration
    last_total, last_idle = cpu_times()
    while time.monotonic() < end:
        rows = sql(args, f"SELECT submit_id || '|' || status || '|' || pre_score || '|' || "
                         f"extract(epoch FROM localtimestamp - time) FROM shj_submissions "
                         f"WHERE assignment = {ASSIGNMENT}")
        pending = 0
        for row in filter(None, rows.splitlines()):
            sid, status, score, age = row.split('|')
            if status == 'PENDING':
                pending += 1
            elif sid not in seen:
                seen[sid] = {'result': f'{status}|{score}', 'latency': float(age)}
        total, idle = cpu_times()
        mem = dict(l.split(':', 1) for l in Path('/proc/meminfo').read_text().splitlines())
        fpm = subprocess.run(['pgrep', '-c', '-f', 'php-fpm: pool laboo-live'], capture_output=True, text=True).stdout.strip()
        samples.append({'t': round(time.time(), 1), 'pending': pending, 'graded': len(seen),
                        'cpu': round(100 * (1 - (idle - last_idle) / max(1, total - last_total)), 1),
                        'load1': float(Path('/proc/loadavg').read_text().split()[0]),
                        'mem_available_mb': int(mem['MemAvailable'].split()[0]) // 1024,
                        'fpm_workers': int(fpm or 0)})
        last_total, last_idle = total, idle
        time.sleep(1)
    print(json.dumps({'graded': seen, 'samples': samples}))


# ---------------------------------------------------------------- cliente
class Student:
    def __init__(self, base, basic):
        self.url = urllib.parse.urlsplit(base.rstrip('/'))
        self.cookies, self.basic = {}, basic

    def request(self, path, body=None, ctype='application/x-www-form-urlencoded'):
        cls = http.client.HTTPSConnection if self.url.scheme == 'https' else http.client.HTTPConnection
        c = cls(self.url.netloc, timeout=60)
        headers = {'Cookie': '; '.join(k + '=' + v for k, v in self.cookies.items()), 'User-Agent': 'laboo-load-test'}
        if self.basic:
            headers['Authorization'] = 'Basic ' + base64.b64encode(self.basic.encode()).decode()
        if body is not None:
            headers['Content-Type'] = ctype
        started = time.monotonic()
        try:
            c.request('POST' if body is not None else 'GET', self.url.path + '/' + path, body=body, headers=headers)
            r = c.getresponse()
            data = r.read()
            for k, v in r.getheaders():
                if k.lower() == 'set-cookie':
                    key, value = v.split(';', 1)[0].split('=', 1)
                    self.cookies[key] = value
            return r.status, data, time.monotonic() - started
        finally:
            c.close()


def token(body):
    m = re.search(rb'name="([^"]*csrf[^"]*)" value="([^"]+)"', body)
    if not m:
        raise RuntimeError('sem token CSRF')
    return m[1].decode(), m[2].decode()


def run(args):
    cred = json.loads(Path(args.credentials).read_text())
    mix = [(k, float(v)) for k, v in (p.split('=') for p in args.mix.split(','))]
    stats, lock, submitted = {}, threading.Lock(), []
    t0 = time.monotonic()

    def record(kind, status, seconds, ok):
        with lock:
            s = stats.setdefault(kind, {'n': 0, 'errors': 0, 'times': [], 'codes': {}})
            s['n'] += 1
            s['times'].append(seconds)
            s['codes'][str(status)] = s['codes'].get(str(status), 0) + 1
            if not ok:
                s['errors'] += 1

    def call(st, kind, path, ok_codes, body=None, ctype='application/x-www-form-urlencoded'):
        try:
            status, data, sec = st.request(path, body, ctype)
        except Exception as e:  # timeout/conexão recusada contam como erro
            record(kind, type(e).__name__, 60.0, False)
            raise
        record(kind, status, sec, status in ok_codes)
        if status not in ok_codes:
            raise RuntimeError(f'{kind}: HTTP {status}')
        return data

    def student(username, rnd):
        st = Student(args.base_url, cred.get('basic'))
        try:
            time.sleep(rnd.uniform(0, args.login_ramp))
            data = call(st, 'login_get', 'login', [200])
            name, value = token(data)
            call(st, 'login_post', 'login', [302, 303],
                 urllib.parse.urlencode({'username': username, 'password': cred['password'], name: value}))
            call(st, 'problem_get', f'problems/{ASSIGNMENT}/1', [200])
            # Envios: espalhados na janela, o último concentrado no fim (pico de entrega).
            window = args.submit_window
            times = sorted(rnd.uniform(args.login_ramp, window) for _ in range(args.submissions - 1))
            times.append(window + rnd.uniform(0, args.final_burst))
            for when in times:
                while time.monotonic() - t0 < when:
                    call(st, 'submissions_poll', 'submissions/all', [200])
                    time.sleep(min(rnd.uniform(0.6, 1.4) * args.poll, max(0.1, when - (time.monotonic() - t0))))
                kind = rnd.choices([k for k, _ in mix], [w for _, w in mix])[0]
                first_try = time.monotonic()
                while True:
                    data = call(st, 'problem_get', f'problems/{ASSIGNMENT}/1', [200])
                    name, value = token(data)
                    boundary = 'LABOOload' + secrets.token_hex(8)
                    parts = [f'--{boundary}\r\nContent-Disposition: form-data; name="{k}"\r\n\r\n{v}\r\n'.encode()
                             for k, v in [('problem', '1'), ('language', 'C++'), (name, value)]]
                    parts.append(f'--{boundary}\r\nContent-Disposition: form-data; name="userfile"; filename="main.cpp"\r\n'
                                 'Content-Type: text/x-c++src\r\n\r\n'.encode() + SOLUTIONS[kind].encode() + b'\r\n')
                    parts.append(f'--{boundary}--\r\n'.encode())
                    status, body, sec = st.request('problems/form_validation', b''.join(parts),
                                                   'multipart/form-data; boundary=' + boundary)
                    if status == 500 and b'still in queue' in body:
                        # Regra do judge: um envio pendente por problema. O aluno espera e reenvia.
                        record('submit_rejected_in_queue', status, sec, True)
                        call(st, 'submissions_poll', 'submissions/all', [200])
                        time.sleep(rnd.uniform(0.6, 1.4) * args.poll)
                        continue
                    record('submit', status, sec, status in (302, 303))
                    if status not in (302, 303):
                        raise RuntimeError(f'submit: HTTP {status}')
                    break
                with lock:
                    submitted.append({'user': username, 'kind': kind, 't': round(time.monotonic() - t0, 2),
                                      'waited_for_queue_s': round(time.monotonic() - first_try - sec, 1)})
            end = window + args.final_burst + args.tail
            while time.monotonic() - t0 < end:
                call(st, 'submissions_poll', 'submissions/all', [200])
                time.sleep(rnd.uniform(0.6, 1.4) * args.poll)
        except Exception as e:
            with lock:
                stats.setdefault('student_aborted', {'n': 0, 'errors': 0, 'times': [], 'codes': {}})
                stats['student_aborted']['n'] += 1
                stats['student_aborted']['codes'][str(e)[:60]] = stats['student_aborted']['codes'].get(str(e)[:60], 0) + 1

    threads = [threading.Thread(target=student, args=(u, random.Random(i))) for i, u in enumerate(cred['students'])]
    for th in threads:
        th.start()
    for th in threads:
        th.join()

    def pct(values, p):
        values = sorted(values)
        return round(values[min(len(values) - 1, int(p * len(values)))], 3) if values else None
    summary = {k: {'n': v['n'], 'errors': v['errors'], 'codes': v['codes'], 'p50': pct(v['times'], 0.5),
                   'p95': pct(v['times'], 0.95), 'max': pct(v['times'], 1.0)} for k, v in stats.items()}
    print(json.dumps({'base': args.base_url, 'students': len(cred['students']), 'duration_s': round(time.monotonic() - t0, 1),
                      'http': summary, 'submitted': submitted}))


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest='cmd', required=True)
    for name in ['setup', 'teardown', 'monitor']:
        p = sub.add_parser(name)
        p.add_argument('--instance', default='aula')
        p.add_argument('--database', default='judge_aula')
        p.add_argument('--pg-port', default='5432')
        p.add_argument('--htpasswd')
        if name == 'setup':
            p.add_argument('--students', type=int, default=60)
            p.add_argument('--basic-hash', choices=['bcrypt', 'apr1'], default='bcrypt')
        if name == 'monitor':
            p.add_argument('--duration', type=int, default=420)
    p = sub.add_parser('run')
    p.add_argument('--base-url', required=True, help='ex.: http://IP:PORTA/aula')
    p.add_argument('--credentials', required=True)
    p.add_argument('--login-ramp', type=float, default=30)
    p.add_argument('--submit-window', type=float, default=240)
    p.add_argument('--final-burst', type=float, default=45)
    p.add_argument('--tail', type=float, default=60)
    p.add_argument('--submissions', type=int, default=3)
    p.add_argument('--poll', type=float, default=10)
    p.add_argument('--mix', default='ok=0.55,heavy=0.15,wrong=0.15,ce=0.10,tle=0.05')
    args = parser.parse_args()
    {'setup': setup, 'teardown': teardown, 'monitor': monitor, 'run': run}[args.cmd](args)


if __name__ == '__main__':
    main()
