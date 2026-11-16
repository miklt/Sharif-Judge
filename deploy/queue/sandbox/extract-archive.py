#!/usr/bin/env python3
"""Descompacta 7z no tmpfs limitado do container; devolve somente fontes permitidas."""
from pathlib import Path
import base64
import json
import resource
import subprocess

resource.setrlimit(resource.RLIMIT_FSIZE,(8*1024*1024,8*1024*1024))
root=Path('/tmp/extracted');root.mkdir(mode=0o700)
with open('/tmp/unpack.log','wb') as log:
    p=subprocess.run(['7z','e','-y','-o'+str(root),'/input/archive'],stdout=log,stderr=log,timeout=15)
assert p.returncode==0
files=list(root.iterdir())
assert len(files)<=128 and sum(p.lstat().st_size for p in files)<=8*1024*1024
assert all(p.is_file() and not p.is_symlink() and p.suffix.lower() in ['.cpp','.h','.hpp','.txt'] for p in files)
print(json.dumps({p.name:base64.b64encode(p.read_bytes()).decode() for p in files}))
