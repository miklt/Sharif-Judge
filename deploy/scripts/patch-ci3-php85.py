#!/usr/bin/env python3
"""Compatibilidade explícita do contêiner de serviços dinâmico CI3 com PHP 8.5."""
from pathlib import Path
import argparse
import re

parser = argparse.ArgumentParser()
parser.add_argument('vendor', type=Path)
args = parser.parse_args()
system = args.vendor/'codeigniter/framework/system'
assert "CI_VERSION = '3.1.13'" in (system/'core/CodeIgniter.php').read_text()
targets = [('core/'+name+'.php', 'CI_'+name) for name in
           ['Controller', 'Model', 'Loader', 'URI', 'Router', 'Config', 'Input', 'Output', 'Security', 'Lang', 'Benchmark', 'Hooks']]
targets.append(('database/DB_driver.php', 'CI_DB_driver'))
for relative, classname in targets:
    p = system/relative
    text = p.read_text()
    # A primeira revisão posicionava o atributo entre abstract e class.
    text = text.replace('abstract #[\\AllowDynamicProperties]\nclass ', '#[\\AllowDynamicProperties]\nabstract class ')
    declaration = ('abstract ' if classname == 'CI_DB_driver' else '')+'class '+classname+' '
    marker = '#[\\AllowDynamicProperties]\n'+declaration
    if marker not in text:
        assert declaration in text, relative
        p.write_text(text.replace(declaration, marker, 1))
    else:
        p.write_text(text)
p = system/'core/Exceptions.php'
p.write_text(re.sub(r"(?m)^\s*E_STRICT\s*=>[^\n]+\n", '', p.read_text()))
p = system/'libraries/Session/Session.php'
text = p.read_text()
needle = 'protected function _configure_sid_length()\n\t{'
if 'LABOO PHP 8.4+' not in text:
    text = text.replace(needle, needle+"\n\t\t// LABOO PHP 8.4+: formato padrão do runtime, sem alterar INI obsoleto.\n\t\tif (PHP_VERSION_ID >= 80400) { $this->_sid_regexp = '[0-9a-zA-Z,-]{'.strlen(session_create_id()).'}'; return; }\n")
text = text.replace("$this->_sid_regexp = '[0-9a-f]{32}';", "$this->_sid_regexp = '[0-9a-zA-Z,-]{'.strlen(session_create_id()).'}';")
p.write_text(text)
p = system/'libraries/Upload.php'
text = p.read_text()
if 'PHP_VERSION_ID < 80500' not in text:
    text = text.replace('finfo_close($finfo);', 'if (PHP_VERSION_ID < 80500) { finfo_close($finfo); }')
p.write_text(text)
print('CI3: classes com injeção dinâmica de serviços declaradas explicitamente.')
