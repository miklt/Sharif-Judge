# Servidores de prova do Sharif-Judge (LABOO)

Esta pasta cria, a partir de um **Ubuntu 24.04 limpo**, um servidor de prova
com o judge modernizado (PHP 8.5, CodeIgniter 3.1.13 com patches, Twig 3,
PostgreSQL 18), pronto para os alunos. Cada servidor leva cerca de 2 minutos
e é configurado por um único comando Ansible.

Cada servidor de prova tem **uma instância** (`/aula/`) com as **contas e
turmas** do judge de aula do LABOO. Exercícios, envios, placar e avisos das
aulas **não são copiados**: o único exercício do servidor é a prova, criada
depois pelo professor.

## O que é instalado

| Item | Detalhe |
|---|---|
| Web | Apache (mpm_event) + PHP-FPM 8.5 (pool `laboo-live`, usuário `laboo-web`) |
| Banco | PostgreSQL 18 (PGDG), banco `judge_aula`, papel `judge`, fuso de São Paulo |
| Correção | Fila `laboo-queue` (systemd) com compilador **nativo** `g++-11` (`-std=c++11`, como no judge original) |
| Isolamento | Código do aluno roda como `laboo-runner`, sem privilégios, com bubblewrap: sem rede, raiz somente leitura, limites de CPU/memória/processos/saída |
| Acesso | HTTP Basic com o mesmo `htpasswd` do aula (opcional) + login do judge |

Origens dos pacotes no 24.04: PHP 8.5 do PPA `ondrej/php` e PostgreSQL 18 do
PGDG, ambos com fingerprint da chave conferido. A senha do banco e a chave de
criptografia são **geradas no próprio servidor** e não saem dele.

## Pré-requisitos

- Controlador com `ansible-core` 2.21 (por exemplo,
  `python3 -m venv ~/.venvs/ansible && ~/.venvs/ansible/bin/pip install ansible-core==2.21.5`)
  e este repositório.
- Servidores Ubuntu 24.04 com acesso SSH por chave a uma conta com `sudo`
  sem senha (ou use `--ask-become-pass`) e acesso à internet (apt, PPA, PGDG,
  getcomposer.org, packagist).

## 1. Gerar a cópia das contas no LABOO

No LABOO, como root (janela administrativa do responsável):

```sh
sudo bash deploy/scripts/export-instance-snapshot.sh aula judgedb_aula_s2_2026 5434
```

O script grava em `/var/lib/laboo-admin/snapshots/aula-<UTC>/`:
`database.dump` (esquema completo + usuários, turmas e configurações),
`files.tar.gz` (somente `tester/`), `htpasswd`, `manifest.json` e
`SHA256SUMS`. **Contém dados pessoais e hashes de senha**: copie para um
diretório privado do controlador (`chmod 700`) e nunca para o Git.

## 2. Inventário

```sh
cd deploy/ansible
cp inventory.example.yml inventory.yml   # inventory.yml não é versionado
```

Variáveis principais (por grupo ou por servidor):

| Variável | Padrão | Uso |
|---|---|---|
| `laboo_snapshot_dir` | — | Diretório da cópia no controlador (obrigatório) |
| `laboo_public_url` | `http://<ansible_host>:<porta>` | Endereço que os alunos usam (com NAT, a porta pública) |
| `laboo_http_port` | `80` | Porta interna do Apache |
| `laboo_basic_auth` | `true` | Exigir o `htpasswd` do aula antes do login |
| `laboo_basic_auth_bypass_ips` | `[]` | IPs/redes liberados sem a senha Basic |
| `laboo_fpm_max_children` | `16` | Workers PHP simultâneos (1 turma ≈ 30 alunos) |
| `laboo_reimport` | `false` | Recopiar contas/turmas (**apaga a prova já criada**) |
| `laboo_run_smoke` | `false` | Rodar o teste de fumaça ao final |

## 3. Instalar

```sh
ansible-playbook provision.yml -e laboo_run_smoke=true
```

O playbook confere o SHA-256 da cópia, instala tudo, importa as contas,
verifica que o servidor tem **0 exercícios e 0 envios**, roda o autoteste
do C++ nativo e (com `laboo_run_smoke=true`) faz um envio real pela interface:
cria um aluno e um exercício temporários, envia uma solução, espera a nota
10000 da fila e remove tudo. O resumo final mostra a URL para os alunos.

Rodar de novo é seguro: sem `laboo_reimport`, nada é reimportado.

## 4. Antes da prova

1. Entre como professor/admin (contas do aula) e crie o exercício da prova
   em cada servidor. Confira data/hora de início e fim.
2. Rode o teste de fumaça em cada servidor:
   `sudo python3 /srv/laboo/current/deploy/scripts/smoke-exam.py --instance aula --database judge_aula`
3. Ubuntu Cloud aplica atualizações automáticas; para evitar reinícios de
   serviço durante a prova, pause-as na janela da prova:
   `sudo systemctl stop unattended-upgrades apt-daily-upgrade.timer` (e
   reative depois com `start`).

Para atualizar contas novas, gere outra cópia e rode com
`-e laboo_reimport=true` **antes** de criar a prova (a reimportação recria o
banco da instância).

## Teste de carga

`deploy/scripts/load-exam.py` simula uma turma inteira: logins em rajada,
alunos atualizando a página de envios e vários envios por aluno, concentrados
no fim (mistura de corretos, pesados, errados, erro de compilação e estouro
de tempo). Usa alunos e exercício temporários (`laboocarga*`, id 32701).

```sh
# no servidor (root)
sudo python3 /srv/laboo/current/deploy/scripts/load-exam.py setup --students 60 > cred.json
sudo python3 /srv/laboo/current/deploy/scripts/load-exam.py monitor --duration 440 > monitor.json &
# no controlador (ou outra máquina da rede dos alunos)
python3 deploy/scripts/load-exam.py run --base-url http://IP:PORTA/aula --credentials cred.json > run.json
# no servidor, ao final
sudo python3 /srv/laboo/current/deploy/scripts/load-exam.py teardown
```

Regra herdada do judge: enquanto o envio anterior do aluno está na fila, um
novo envio para o mesmo problema é recusado ("still in queue"). Fila rápida
evita essas recusas.

## 5. Depois da prova

Exporte as notas/envios pela interface (Submissions → Excel) e, se precisar
dos fontes, copie `/srv/laboo/live-data/aula/assignments/assignment_<id>/`.
Os servidores de prova podem então ser descartados ou reinstalados.

## Estrutura

```
deploy/
├── ansible/                 playbook (provision.yml) e role laboo_prova
├── queue/scripts/           fila: supervisor, worker (ponte PHP), runner C++ nativo, autoteste
├── queue/sandbox/           limitador de processo e extrator 7z executados no sandbox
└── scripts/
    ├── export-instance-snapshot.sh   cópia só de login, no LABOO
    ├── patch-ci3-php85.py            compatibilidade do CodeIgniter 3 (vendor) com PHP 8.5
    └── smoke-exam.py                 teste de fumaça de ponta a ponta
```

Testado em 16/11/2026 num Ubuntu 24.04.5 limpo: instalação completa em ~100 s,
contas importadas (0 exercícios/envios), autoteste C++ e teste de fumaça com
nota 10000 em ~2 s, reinício do servidor com todos os serviços de volta.
