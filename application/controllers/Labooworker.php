<?php
defined('BASEPATH') OR exit('No direct script access allowed');

/** Ponte CLI: mantém o lock PostgreSQL enquanto o supervisor isola o C++. */
class Labooworker extends CI_Controller
{
    public function __construct()
    {
        parent::__construct();
        if (!is_cli() || getenv('LABOO_WORKER_ENABLED') !== '1') {
            show_404();
        }
        $this->load->model('queue_model')->model('submit_model');
    }

    /**
     * Relatório no formato do tester.sh legado: "Test N - <desc/descN.txt>"
     * seguido do status (verde ACCEPT, vermelho WRONG, laranja os demais).
     */
    private static function result_html(string $directory_problem, array $result): string
    {
        $e = static fn($text) => htmlspecialchars((string)$text, ENT_QUOTES|ENT_SUBSTITUTE, 'UTF-8');
        if ($result['status'] === 'Compilation Error') {
            return "<span class=\"shj_b\">Compile Error</span>\n<span class=\"shj_r\">\n"
                .$e($result['compiler'] ?? '')."\n</span>\n";
        }
        $html = "\n";
        foreach ($result['tests'] ?? [] as $test) {
            $i = (int)$test['case'];
            $desc = @file_get_contents($directory_problem.'/desc/desc'.$i.'.txt');
            $desc = $desc === false ? '' : trim($desc);
            if ($desc !== '' && !mb_check_encoding($desc, 'UTF-8')) {
                $desc = mb_convert_encoding($desc, 'UTF-8', 'ISO-8859-1');
            }
            $class = $test['status'] === 'ACCEPT' ? 'shj_g' : ($test['status'] === 'WRONG' ? 'shj_r' : 'shj_o');
            $html .= '<span class="shj_b">Test '.$i.($desc === '' ? '' : ' - '.$e($desc))."</span>\n"
                .'<span class="'.$class.'">'.$e($test['status'])."</span>\n";
        }
        return $html;
    }

    private function emit(array $message): void
    {
        echo json_encode($message, JSON_THROW_ON_ERROR)."\n";
        flush();
    }

    public function run(): void
    {
        $instance = getenv('LABOO_INSTANCE');
        $lock = crc32($instance) & 0x7fffffff;
        $result = $this->db->query('SELECT pg_try_advisory_lock(1010557, ?) AS acquired', [$lock])->row();
        if (!in_array($result->acquired, [true, 't', '1', 1], true)) {
            $this->emit(['state'=>'busy']); return;
        }
        try {
            if ($this->settings_model->get_setting('laboo_queue_paused') === '1') {
                $this->emit(['state'=>'paused']); return;
            }
            $item = $this->queue_model->get_first_item();
            if ($item === null) { $this->emit(['state'=>'idle']); return; }
            $submission = $this->submit_model->get_submission($item['username'], $item['assignment'], $item['problem'], $item['submit_id']);
            $problem = $this->assignment_model->problem_info($item['assignment'], $item['problem']);
            if (!$submission || !$problem || $submission['file_type'] !== 'cpp') {
                throw new RuntimeException('Tipo ou submissão não validado pelo worker moderno.');
            }
            $this->settings_model->set_setting('queue_is_working', '1');
            $this->emit(['state'=>'job', 'instance'=>$instance, 'queue'=>$item,
                         'submission'=>$submission, 'problem'=>$problem,
                         'output_bytes'=>(int)$this->settings_model->get_setting('output_size_limit')*1024,
                         'cpp_shield'=>$this->settings_model->get_setting('enable_cpp_shield') === '1']);
            $line = fgets(STDIN, 1024*1024);
            if ($line === false) { throw new RuntimeException('Supervisor desconectado; fila preservada.'); }
            $result = json_decode($line, true, 64, JSON_THROW_ON_ERROR);
            if (!in_array($result['status'] ?? null, ['SCORE','Compilation Error'], true)
                || !is_int($result['pre_score'] ?? null) || $result['pre_score'] < 0 || $result['pre_score'] > 10000) {
                throw new RuntimeException('Resultado inválido; fila preservada.');
            }
            if (!preg_match('/^[a-zA-Z0-9]+$/D', $item['username'])) { throw new RuntimeException('Identificador inválido.'); }
            $directory_problem = rtrim($this->settings_model->get_setting('assignments_root'), '/').'/assignment_'.(int)$item['assignment'].'/p'.(int)$item['problem'];
            $directory = $directory_problem.'/'.$item['username'];
            $html = self::result_html($directory_problem, $result);
            $path = $directory.'/result-'.(int)$item['submit_id'].'.html';
            if (file_put_contents($path.'.tmp', $html, LOCK_EX) === false || !rename($path.'.tmp', $path)) {
                throw new RuntimeException('Não foi possível gravar relatório; fila preservada.');
            }
            // .zip/.7z: fontes concatenados em <arquivo>.cpp, como o tester.sh
            // legado (botão "Code"). Melhor esforço: não prende a fila.
            if (is_string($result['source_listing'] ?? null)
                && preg_match('/^[A-Za-z0-9_-]+$/D', (string)$submission['file_name'])) {
                $code_path = $directory.'/'.$submission['file_name'].'.cpp';
                if (@file_put_contents($code_path.'.tmp', $result['source_listing'], LOCK_EX) === false
                    || !@rename($code_path.'.tmp', $code_path)) {
                    @unlink($code_path.'.tmp');
                }
            }
            // Log para professores/admins (botão "Log") no formato do tester.sh
            // legado; o corpo vem do runner. Melhor esforço: não prende a fila.
            $tl = round((int)$problem['c_time_limit']/1000, 3);
            $log = "cd ".rtrim((string)$this->settings_model->get_setting('tester_path'), '/').";\n"
                ."./cpp_runner.py ".$directory_problem." ".escapeshellarg($item['username'])." "
                .escapeshellarg((string)$submission['main_file_name'])." ".escapeshellarg((string)$submission['file_name'])
                ." cpp ".$tl." ".((int)floor($tl)+1)." ".(int)$problem['memory_limit']." "
                .((int)$this->settings_model->get_setting('output_size_limit')*1024)." "
                .$problem['diff_cmd']." ".$problem['diff_arg']
                ." 1 0 ".($this->settings_model->get_setting('enable_cpp_shield') === '1' ? 1 : 0)." 0 0 0\n"
                .(is_string($result['log'] ?? null) ? $result['log']
                    : "Resultado: ".$result['status'].", nota ".(int)$result['pre_score']." de 10000\n");
            $logpath = $directory.'/log-'.(int)$item['submit_id'];
            if (@file_put_contents($logpath.'.tmp', $log, LOCK_EX) !== false) { @rename($logpath.'.tmp', $logpath); }
            $submission['status'] = $result['status'];
            $submission['pre_score'] = $result['pre_score'];
            $this->db->trans_start();
            $this->queue_model->save_judge_result_in_db($submission, $item['type']);
            $this->queue_model->remove_item($item['username'], $item['assignment'], $item['problem'], $item['submit_id']);
            $this->db->trans_complete();
            if (!$this->db->trans_status()) { throw new RuntimeException('Transação não confirmada; fila preservada.'); }
            $this->emit(['state'=>'saved', 'status'=>$result['status'], 'pre_score'=>$result['pre_score']]);
        } finally {
            $this->settings_model->set_setting('queue_is_working', '0');
            $this->db->query('SELECT pg_advisory_unlock(1010557, ?)', [$lock]);
        }
    }
}
