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
            $directory = rtrim($this->settings_model->get_setting('assignments_root'), '/').'/assignment_'.(int)$item['assignment'].'/p'.(int)$item['problem'].'/'.$item['username'];
            $html = '';
            foreach ($result['tests'] ?? [] as $test) {
                $html .= '<div>Test '.(int)$test['case'].': '.htmlspecialchars($test['status'], ENT_QUOTES|ENT_SUBSTITUTE, 'UTF-8').'</div>';
            }
            if ($result['status'] === 'Compilation Error') {
                $html .= '<pre>'.htmlspecialchars($result['compiler'] ?? '', ENT_QUOTES|ENT_SUBSTITUTE, 'UTF-8').'</pre>';
            }
            $path = $directory.'/result-'.(int)$item['submit_id'].'.html';
            if (file_put_contents($path.'.tmp', $html, LOCK_EX) === false || !rename($path.'.tmp', $path)) {
                throw new RuntimeException('Não foi possível gravar relatório; fila preservada.');
            }
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
