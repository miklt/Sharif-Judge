#!/usr/bin/env bash
# Exporta o necessário para os alunos LOGAREM num servidor de prova: contas,
# turmas e configurações da instância, mais o diretório tester e o htpasswd.
# NÃO leva exercícios, problemas, envios, placar, fila, sessões nem avisos:
# o único exercício do servidor de prova será a própria prova.
# Executar como root no servidor de origem (LABOO).
#
#   export-instance-snapshot.sh <instância> <banco> [porta-pg]
#   ex.: export-instance-snapshot.sh aula judgedb_aula_s2_2026 5434
#
# Saída: /var/lib/laboo-admin/snapshots/<instância>-<UTC>/ (0700), com
#   database.dump (pg_dump -Fc: esquema completo + dados de login),
#   files.tar.gz (somente tester/),
#   htpasswd (se existir) e manifest.json com contagens e SHA-256.
# Contém dados pessoais e hashes de senha: nunca versionar nem publicar.
set -euo pipefail
[[ $EUID == 0 ]] || { echo 'Execute como root.' >&2; exit 1; }
instance=${1:?instância}; database=${2:?banco}; port=${3:-5434}
[[ $instance =~ ^[a-z0-9]{2,20}$ ]] || { echo 'Instância inválida.' >&2; exit 1; }
data=${LABOO_DATA_ROOT:-/srv/laboo/live-data}/$instance
htpasswd=${LABOO_HTPASSWD:-/var/www/judge/$instance/.htpasswd}
[[ -d $data/tester ]] || { echo "Diretório tester ausente em $data." >&2; exit 1; }
umask 077
stamp=$(date -u +%Y%m%dT%H%M%SZ)
out=/var/lib/laboo-admin/snapshots/$instance-$stamp
install -d -m 0700 "$out"
psql() { runuser -u postgres -- psql -X -p "$port" -d "$database" -qAt -v ON_ERROR_STOP=1 "$@"; }
counts() { psql -c "SELECT json_build_object('users',(SELECT count(*) FROM shj_users),'classes',(SELECT count(*) FROM shj_classes),'users_classes',(SELECT count(*) FROM shj_users_classes))"; }
# Tabelas cujo conteúdo fica de fora (só o esquema vai no dump).
excluded=(shj_assignments shj_assignments_classes shj_problems shj_submissions shj_queue
          shj_scoreboard shj_sessions shj_notifications)

before=$(counts)
runuser -u postgres -- pg_dump -p "$port" -Fc --no-owner --no-acl \
  $(printf -- '--exclude-table-data=public.%s ' "${excluded[@]}") -d "$database" > "$out/database.dump"
tar -C "$data" --numeric-owner -czf "$out/files.tar.gz" tester
[[ -f $htpasswd ]] && install -m 0600 "$htpasswd" "$out/htpasswd"
after=$(counts)
[[ $before == "$after" ]] || { echo 'Houve escrita durante a exportação; repita.' >&2; exit 1; }

settings=$(psql -c "SELECT json_object_agg(shj_key, shj_value) FROM shj_settings WHERE shj_key IN ('assignments_root','tester_path','timezone')")
( cd "$out" && sha256sum database.dump files.tar.gz $( [[ -f htpasswd ]] && echo htpasswd ) > SHA256SUMS )
python3 - "$out" "$instance" "$database" "$before" "$settings" <<'PY'
import json, sys, pathlib, datetime
out, instance, database, counts, settings = sys.argv[1:]
manifest = {'format': 2, 'profile': 'login-only', 'instance': instance, 'source_database': database,
            'created_utc': datetime.datetime.now(datetime.UTC).isoformat(timespec='seconds'),
            'counts': json.loads(counts), 'settings': json.loads(settings),
            'files': {l.split()[1]: l.split()[0] for l in pathlib.Path(out, 'SHA256SUMS').read_text().splitlines()}}
pathlib.Path(out, 'manifest.json').write_text(json.dumps(manifest, indent=2))
PY
echo "$out"
