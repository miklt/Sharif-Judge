"""Runner C++11 isolado; nunca monta DB, sockets administrativos ou respostas no aluno.

Backend padrão (16/11/2026, decisão do responsável): compilador NATIVO
(g++-11, mesmo major do legado) com sandbox bubblewrap como usuário
dedicado sem privilégios, sem rede e com limites por rlimit. O backend
Docker permanece só como retorno (LABOO_RUNNER_BACKEND=docker).
"""
from pathlib import Path
import base64
import json
import os
import pwd
import re
import shutil
import subprocess
import tempfile
import time
import uuid
from datetime import datetime
import zipfile

ROOT=Path(os.environ.get('LABOO_RUNTIME_ROOT','/home/michelet/laboo-local'))
BACKEND=os.environ.get('LABOO_RUNNER_BACKEND','native')
IMAGE=os.environ.get('LABOO_RUNNER_IMAGE','laboo-php85-jammy:20261105')
# Ferramentas do sandbox: 'sandbox/' no repositório; 'docker/' na implantação LABOO de 16/11.
_TOOLS=Path(__file__).resolve().parents[1]
LIMITER=(_TOOLS/'sandbox' if (_TOOLS/'sandbox').is_dir() else _TOOLS/'docker')/'limit-process.py'
FLAGS=['-fno-asm','-Dasm=error','-lm','-O2','-std=c++11','-Wfatal-errors','-Werror=return-type','-w']
NATIVE_CXX=os.environ.get('LABOO_NATIVE_CXX','/usr/bin/g++-11')
RUNNER_USER=os.environ.get('LABOO_RUNNER_USER','laboo-runner')
assert BACKEND in {'native','docker'}

class RunnerInfrastructureError(RuntimeError):
    """Falha do executor; não deve virar erro de compilação/nota do aluno."""

class ExecutionTimeout(RunnerInfrastructureError):
    """Comando excedeu o limite externo (ex.: compilação longa)."""

def _runner_ids():
    if BACKEND=='docker':
        return 1000,1000
    entry=pwd.getpwnam(RUNNER_USER)
    assert entry.pw_uid not in (0,1000) and entry.pw_uid<60000, 'Usuário do runner inválido.'
    return entry.pw_uid,entry.pw_gid

def _size(value):
    value=str(value)
    return int(value[:-1])*1024*1024 if value.endswith('m') else int(value)

def container(command, mounts, stdin=None, timeout=35, memory='512m', pids=64):
    if BACKEND=='native':
        return _native(command, mounts, stdin, timeout, memory, pids)
    return _docker(command, mounts, stdin, timeout, memory, pids)

def _prepare_mounts(mounts):
    # Coordenador nativo root: só os artefatos descartáveis do job passam
    # ao UID sem privilégios do runner. Nunca mudar dono dos dados reais.
    if os.geteuid()==0:
        uid,gid=_runner_ids()
        for source, _, _ in mounts:
            source=Path(source)
            if source.resolve().is_relative_to((ROOT/'jobs').resolve()):
                items=[source,*source.rglob('*')] if source.is_dir() else [source]
                for item in items:
                    assert not item.is_symlink(), 'Link inesperado no job isolado.'
                    os.chown(item,uid,gid)
            else:
                assert source.resolve() in {LIMITER.resolve(),(LIMITER.parent/'extract-archive.py').resolve()}

def _tool_copy(source):
    # Ferramentas (limitador/extrator) podem estar sob diretório root 0700;
    # o runner recebe só uma cópia somente leitura em jobs/.tools.
    tools=ROOT/'jobs'/'.tools';tools.mkdir(mode=0o711,exist_ok=True);tools.chmod(0o711)
    target=tools/source.name
    data=source.read_bytes()
    if not target.is_file() or target.read_bytes()!=data:
        temp=tools/('.'+source.name+'.tmp');temp.write_bytes(data);temp.chmod(0o644);temp.replace(target)
    return target

def _native(command, mounts, stdin, timeout, memory, pids):
    _prepare_mounts(mounts)
    allowed={LIMITER.resolve(),(LIMITER.parent/'extract-archive.py').resolve()}
    mounts=[(_tool_copy(Path(s)) if Path(s).resolve() in allowed else s,t,w) for s,t,w in mounts]
    # O job fica sob ROOT/jobs (0700 root); o runner só alcança seus binds.
    limit=_size(memory)
    if command and command[0]=='g++':
        # RLIMIT_AS é virtual (cgroup do Docker media RSS): folga para cc1plus.
        command=[NATIVE_CXX,*command[1:]];limit=max(limit,2048*1024*1024)
    elif command and command[0]=='python3':
        command=['/usr/bin/python3','-I',*command[1:]]
    args=[]
    if os.geteuid()==0:
        uid,gid=_runner_ids()
        args+=['setpriv',f'--reuid={uid}',f'--regid={gid}','--clear-groups','--no-new-privs',
               '--inh-caps=-all','--bounding-set=-all']
    # rlimits herdados pelo sandbox: espaço de endereço, processos, core.
    args+=['prlimit',f'--as={limit}',f'--nproc={pids}','--core=0','--nofile=256','--']
    args+=['bwrap','--unshare-all','--die-with-parent','--new-session','--cap-drop','ALL',
           '--clearenv','--setenv','PATH','/usr/bin:/bin','--setenv','LANG','C.UTF-8',
           '--ro-bind','/usr','/usr','--symlink','usr/bin','/bin','--symlink','usr/lib','/lib',
           '--symlink','usr/lib64','/lib64','--symlink','usr/sbin','/sbin',
           '--ro-bind-try','/etc/ld.so.cache','/etc/ld.so.cache',
           '--ro-bind-try','/etc/alternatives','/etc/alternatives',
           '--proc','/proc','--dev','/dev',
           '--size',str(64*1024*1024),'--perms','1777','--tmpfs','/tmp','--chdir','/tmp']
    for source,target,writable in mounts:
        args+=['--bind' if writable else '--ro-bind',str(source),target]
    # Raiz do sandbox somente leitura; só /tmp e binds graváveis aceitam escrita.
    args+=['--remount-ro','/']
    try:
        result=subprocess.run(args+['--']+command,input=stdin,capture_output=True,timeout=timeout)
    except subprocess.TimeoutExpired:
        # --die-with-parent encerra o sandbox quando bwrap é morto.
        raise ExecutionTimeout('Judge Error: limite externo de execução excedido.') from None
    except FileNotFoundError:
        raise RunnerInfrastructureError('Judge Error: executor nativo indisponível.') from None
    if result.stderr.startswith((b'bwrap:',b'setpriv:',b'prlimit:')):
        raise RunnerInfrastructureError('Judge Error: sandbox nativo falhou.')
    return result

def _docker(command, mounts, stdin, timeout, memory, pids):
    _prepare_mounts(mounts)
    name='laboo-job-'+uuid.uuid4().hex
    args=['docker','run','--pull=never','--rm','--name',name,'--network=none','--read-only','--cap-drop=ALL',
          '--security-opt=no-new-privileges:true','--user','1000:1000','--pids-limit',str(pids),
          '--memory',memory,'--memory-swap',memory,'--cpus','1','--ulimit','core=0',
          '--tmpfs','/tmp:rw,nosuid,nodev,size=64m,mode=1777','--log-driver=none','-i']
    for source,target,writable in mounts:
        args+=['--mount',f'type=bind,src={source},dst={target}'+('' if writable else ',readonly')]
    try:
        result=subprocess.run(args+[IMAGE]+command,input=stdin,capture_output=True,timeout=timeout)
        if result.returncode in [125,126,127]:
            raise RunnerInfrastructureError('Judge Error: executor indisponível ou comando de runtime inválido.')
        return result
    except subprocess.TimeoutExpired:
        subprocess.run(['docker','kill',name],capture_output=True)
        subprocess.run(['docker','rm','-f',name],capture_output=True)
        raise ExecutionTimeout('Judge Error: limite externo de execução excedido.') from None

COMPILE_TIMEOUT=int(os.environ.get('LABOO_COMPILE_TIMEOUT','120'))

def compile_cpp(directory, executable='program', sources=None, flags=None):
    sources=sources or sorted(p.name for p in directory.glob('*.cpp') if not p.name.startswith('.'))
    assert sources, 'Sem fontes C++.'
    assert all(re.fullmatch(r'[A-Za-z0-9_.-]+',s) and not s.startswith('-') for s in sources)
    p=container(['g++',*[str(Path('/work')/s) for s in sources],*(FLAGS if flags is None else flags),'-o','/work/'+executable],
                 [(directory,'/work',True)],timeout=COMPILE_TIMEOUT)
    return p

def run_case(binary, data, seconds, memory_kb, output_bytes):
    p=container(['python3','/runner.py',str(seconds),str(memory_kb*1024),str(output_bytes)],
                [(binary.parent,'/code',False),(LIMITER,'/runner.py',False)],
                stdin=data,timeout=seconds+12,memory=str(max(64*1024*1024,memory_kb*1024+32*1024*1024)),pids=16)
    if p.returncode:
        raise RuntimeError('Judge Error: container não retornou relatório válido.')
    result=json.loads(p.stdout)
    result['stdout']=base64.b64decode(result['stdout']);result['stderr']=base64.b64decode(result['stderr'])
    return result

def judge(source, problem, seconds=1, memory_kb=65536, output_bytes=1024*1024, diff_arg='-bB', shield=None):
    """Só devolve escore após todos os casos. Falhas de infraestrutura deixam fila intacta."""
    assert source.is_file() and problem.is_dir()
    workroot=ROOT/'jobs';workroot.mkdir(mode=0o700,exist_ok=True)
    # Nativo: o runner sem privilégios precisa atravessar (não listar) até o job.
    traverse=0o711 if BACKEND=='native' else 0o700
    workroot.chmod(traverse)
    with tempfile.TemporaryDirectory(prefix='job-',dir=workroot) as temp:
        work=Path(temp);work.chmod(traverse)
        code=work/'compile';code.mkdir(mode=0o700)
        # Log no formato do tester.sh legado (botão "Log" da interface).
        started=time.monotonic();log=[]
        ms=lambda t0:int((time.monotonic()-t0)*1000)
        def done(r):
            if r['status']=='SCORE':log.append(f"\nScore from 10000: {r['pre_score']}")
            log.append(f'\nTotal Execution Time: {ms(started)} ms')
            r['log']='\n'.join(log)+'\n';return r
        log+=['Starting tester...',datetime.now().astimezone().strftime('%a %b %e %I:%M:%S %p %Z %Y'),
              'Language: cpp',f'Time Limit: {seconds:g} s',f'Memory Limit: {memory_kb} kB',
              f'Output size limit: {output_bytes} bytes','EasySandbox: false',
              f"C/C++ Shield: {'true' if shield is not None else 'false'}"]
        # Problemas no arquivo do aluno viram Compilation Error com mensagem:
        # nunca erro de infraestrutura, que prenderia a fila (serial) inteira.
        def invalid(message):
            log.extend(['Compile Error',message])
            return done({'status':'Compilation Error','pre_score':0,'compiler':message,'tests':[]})
        def wanted(name):
            # Como o "7z e" do tester original: fontes entram; o resto (desktop.ini,
            # __MACOSX, ocultos, nomes estranhos) é ignorado.
            return (re.fullmatch(r'[A-Za-z0-9_.-]+',name) and not name.startswith(('-','.'))
                    and Path(name).suffix.lower() in ['.cpp','.h','.hpp','.txt'])
        if source.suffix.lower()=='.zip':
            try:
                with zipfile.ZipFile(source) as archive:
                    members=archive.infolist()
                    if len(members)>128 or sum(m.file_size for m in members)>8*1024*1024:
                        return invalid('Arquivo .zip excede os limites (128 arquivos, 8 MB).')
                    seen=set()
                    for m in members:
                        if m.is_dir():continue
                        path=Path(m.filename)
                        if path.is_absolute() or '..' in path.parts or (m.external_attr>>16)&0o170000==0o120000:
                            continue
                        name=path.name
                        if '__MACOSX' in path.parts or not wanted(name) or name in seen:
                            continue
                        seen.add(name);(code/name).write_bytes(archive.read(m))
            except (zipfile.BadZipFile, zipfile.LargeZipFile, NotImplementedError, RuntimeError, EOFError):
                return invalid('Arquivo .zip inválido, corrompido ou protegido por senha.')
        elif source.suffix.lower()=='.7z':
            staged=work/'submission.7z'
            shutil.copyfile(source,staged)
            extractor=LIMITER.parent/'extract-archive.py'
            p=container(['python3','/extract.py'],[(staged,'/input/archive',False),(extractor,'/extract.py',False)],timeout=25)
            if p.returncode:
                return invalid('Arquivo .7z inválido, corrompido ou acima dos limites (128 arquivos, 8 MB).')
            entries=json.loads(p.stdout)
            for name, data in entries.items():
                if wanted(name):
                    (code/name).write_bytes(base64.b64decode(data))
        elif source.suffix.lower()=='.cpp':
            # Como o tester original: o fonte único do aluno vira code.cpp, para
            # não ser sobrescrito por um main.cpp injetado pelo professor.
            shutil.copyfile(source,code/'code.cpp')
        else:
            return invalid('Formato não suportado: envie .cpp, .zip ou .7z.')
        # Injeção do professor substitui homônimos, como no tester original.
        if (problem/'inject').is_dir():
            for f in (problem/'inject').iterdir():
                assert f.is_file() and not f.is_symlink() and re.fullmatch(r'[A-Za-z0-9_.-]+',f.name)
                shutil.copyfile(f,code/f.name)
        if source.suffix.lower() in ('.zip','.7z'):
            # Arquivo compactado: o main.cpp (do aluno ou injetado pelo professor)
            # é o programa, como o "mv main.$EXT code.c" do tester original.
            if not (code/'main.cpp').is_file():
                return invalid('O arquivo compactado precisa conter main.cpp.')
            (code/'main.cpp').rename(code/'code.cpp')
        if shield is not None:
            main=code/'code.cpp'
            assert main.is_file() and shield.is_dir()
            if '#undef' in re.sub(r'\s','',main.read_text(errors='replace')):
                return invalid('#undef is not allowed')
            (code/'code.c').write_bytes(b'#define main themainmainfunction\n'+main.read_bytes())
            shutil.copyfile(shield/'shield.cpp',code/'shield.cpp')
            shutil.copyfile(shield/'defcpp.h',code/'def.h')
        log.append('Compiling as cpp')
        if shield is not None:log.append('Enabling Shield For C/C++')
        t0=time.monotonic()
        try:
            compiled=compile_cpp(code,sources=['shield.cpp'] if shield else None)
        except ExecutionTimeout:
            # Compilação sem fim (código do aluno) não pode prender a fila.
            return invalid(f'Compilation timed out ({COMPILE_TIMEOUT} s).')
        log.append(f'Compiled. Exit Code={compiled.returncode}  Execution Time: {ms(t0)} ms')
        if compiled.returncode:
            cerr=compiled.stderr.decode(errors='replace')
            log.extend(['Compile Error','\n'.join(cerr.replace('/work/','').splitlines()[:10])])
            return done({'status':'Compilation Error','pre_score':0,'compiler':cerr[:4096],'tests':[]})
        inputs=list((problem/'in').glob('input*.txt'))
        assert inputs and len(inputs)<=1000
        log.extend(['\nTesting...',f'{len(inputs)} test cases found'])
        # Checker só vê saídas quando o container do aluno já terminou.
        checker=None
        if (problem/'tester.executable').is_file():
            # Contrato do legado: um checker já compilado prevalece sobre o
            # fonte. Recompilar silenciosamente pode alterar notas se o fonte
            # tiver sido editado depois. Executá-lo continua sendo isolado.
            checker=work/'checker';checker.mkdir(mode=0o700)
            shutil.copyfile(problem/'tester.executable',checker/'program')
            (checker/'program').chmod(0o700)
            log.append('Copying tester executable to current directory')
        elif (problem/'tester.cpp').is_file():
            checker=work/'checker';checker.mkdir(mode=0o700)
            shutil.copyfile(problem/'tester.cpp',checker/'checker.cpp')
            # O checker legado usa g++ -lm -O2, sem os avisos/flags dos alunos.
            for extra in problem.iterdir():
                if extra.is_file() and extra.suffix in ['.h','.hpp']:
                    shutil.copyfile(extra,checker/extra.name)
            if (problem/'inject').is_dir():
                shutil.copytree(problem/'inject',checker/'inject')
            log.append('Tester file found. Compiling tester...');t0=time.monotonic()
            checked=compile_cpp(checker,flags=['-lm','-O2','-std=gnu++17'])
            if checked.returncode:
                (ROOT/'reports/checker-compile-private.log').write_bytes(checked.stderr)
                raise RuntimeError('Invalid Tester Code')
            log.extend([f'Tester compiled. Execution Time: {ms(t0)} ms','Copying tester executable to current directory'])
        inputs.sort(key=lambda p:int(re.fullmatch(r'input(\d+)\.txt',p.name)[1]))
        tests=[]
        for i,inputfile in enumerate(inputs,1):
            assert inputfile.name==f'input{i}.txt'
            correct=problem/'out'/f'output{i}.txt'
            assert checker or correct.is_file()
            result=run_case(code/'program',inputfile.read_bytes(),seconds,memory_kb,output_bytes)
            log.extend([f'\n=== TEST {i} ===',f"Exit Code = {result['exit_code']}"])
            if result['status'] in ('OK','Runtime Error'):log.append(f"Time: {result['seconds']:.2f} s")
            elif result['status']=='Time Limit Exceeded':log.append(f"Time Limit Exceeded ({result['seconds']:.2f} s)")
            else:log.append(result['status'])
            if result['status']=='Runtime Error':log.append('Runtime Error')
            if result['status'] != 'OK':
                with (ROOT/'reports/last-runtime-private.log').open('ab') as log:
                    log.write(str(result['exit_code']).encode()+b'\n'+result['stderr']+b'\n')
            status=result['status']
            if status=='OK':
                if checker:
                    files=work/'compare';files.mkdir(mode=0o700,exist_ok=True)
                    (files/'input').write_bytes(inputfile.read_bytes());(files/'actual').write_bytes(result['stdout'])
                    if correct.is_file():
                        (files/'expected').write_bytes(correct.read_bytes())
                    elif (files/'expected').exists():
                        (files/'expected').unlink()
                    # Monta a pasta inteira: com tester.executable pronto, a pasta do
                    # checker não passa pela compilação e ficaria inacessível ao runner.
                    p=container(['/checker/program','/case/input','/case/expected','/case/actual'],
                                [(checker,'/checker',False),(files,'/case',False)],timeout=8,memory='128m',pids=16)
                    # O contrato legado aceita exit 0 e rejeita qualquer exit
                    # normal não-zero; sinais/falha do Docker são infraestrutura.
                    if p.returncode<0 or p.returncode in [125,126,127,137,143]:raise RuntimeError('Judge Error: checker falhou.')
                    accepted=p.returncode==0
                elif diff_arg=='ignore':
                    accepted=re.sub(rb'[ \t\n\r\f]',b'',result['stdout'])==re.sub(rb'[ \t\n\r\f]',b'',correct.read_bytes())
                else:
                    assert diff_arg in ['-bB','identical','exact','-wB','-w','-b','-B']
                    files=work/'compare';files.mkdir(mode=0o700,exist_ok=True)
                    (files/'actual').write_bytes(result['stdout']+b'\n');(files/'expected').write_bytes(correct.read_bytes()+b'\n')
                    options=[] if diff_arg in ['identical','exact'] else [diff_arg]
                    p=subprocess.run(['diff','-q',*options,str(files/'actual'),str(files/'expected')],capture_output=True,timeout=5)
                    if p.returncode not in [0,1]:raise RuntimeError('Judge Error: diff falhou.')
                    accepted=p.returncode==0
                status='ACCEPT' if accepted else 'WRONG'
                log.append('ACCEPTED' if accepted else 'WRONG')
            tests.append({'case':i,'status':status,'seconds':result['seconds']})
        passed=sum(t['status']=='ACCEPT' for t in tests)
        return done({'status':'SCORE','pre_score':passed*10000//len(tests),'tests':tests})
