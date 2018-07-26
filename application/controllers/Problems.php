<?php
/**
 * Sharif Judge online judge
 * @file Problems.php
 * @author Mohammad Javad Naderi <mjnaderi@gmail.com>
 */
defined('BASEPATH') OR exit('No direct script access allowed');

class Problems extends CI_Controller
{

	private $all_assignments;
	private $data; //data sent to view
	private $assignment_root;
	private $problems; //Vetor com todos os problems relacionados ao assignment escolhido
	private $problem;//submitted problem id
	private $filetype; //type of submitted file
	private $ext; //uploaded file extension
	private $file_name; //uploaded file name without extension
	private $coefficient;


	// ------------------------------------------------------------------------


	public function __construct()
	{
		parent::__construct();
		if ( ! $this->session->userdata('logged_in')) // if not logged in
			redirect('login');

		$this->all_assignments = $this->assignment_model->all_assignments();
		$this->load->library('upload')->model('queue_model');
		$this->assignment_root = $this->settings_model->get_setting('assignments_root');
		$this->problems = $this->assignment_model->all_problems($this->user->selected_assignment['id']); //Vetor com todos os problems relacionados ao assignment escolhido

		$extra_time = $this->user->selected_assignment['extra_time'];
		$delay = shj_now()-strtotime($this->user->selected_assignment['finish_time']);;
		ob_start();
		if ( eval($this->user->selected_assignment['late_rule']) === FALSE )
			$coefficient = "error";
		if (!isset($coefficient))
			$coefficient = "error";
		ob_end_clean();
		$this->coefficient = $coefficient;
	}


	// ------------------------------------------------------------------------


  /**
  * Displays detail description of given problem
  *
  * @param int $assignment_id
  * @param int $problem_id
  */
  public function index($assignment_id = NULL, $problem_id = 1)
  {

    // If no assignment is given, use selected assignment
    if ($assignment_id === NULL)
      $assignment_id = $this->user->selected_assignment['id'];
    if ($assignment_id == 0){
			//show_error('No assignment selected.');
      $data['problem'] = array(
        'id' => NULL,
        'description' => '<p>Please select an assignment first.</p>',
        'allowed_languages' => NULL,
        'has_pdf' => FALSE
      );
    } else {
      $assignment = $this->assignment_model->assignment_info($assignment_id);

      $data = array(
        'all_problems' => $this->assignment_model->all_problems($assignment_id),
        'description_assignment' => $assignment,
        'can_submit' => TRUE
      );

      if ( ! is_numeric($problem_id) || $problem_id < 1 || $problem_id > $data['description_assignment']['problems'])
        show_404();

      $languages = explode(',',$data['all_problems'][$problem_id]['allowed_languages']);

      $assignments_root = rtrim($this->settings_model->get_setting('assignments_root'),'/');
      $problem_dir = "$assignments_root/assignment_{$assignment_id}/p{$problem_id}";
      $data['problem'] = array(
        'id' => $problem_id,
        'description' => '<p>Description not found</p>',
        'allowed_languages' => $languages,
        'has_pdf' => glob("$problem_dir/*.pdf") != FALSE
      );

      $path = "$problem_dir/desc.html";
      if (file_exists($path))
        $data['problem']['description'] = file_get_contents($path);
    }

    //Obtendo todos os assignments para top-bar:
		$this->load->model('class_model');
		$user_id = $this->user_model->username_to_user_id($this->user->username);
		if ($this->user->level == 0){//Estudantes veem apenas os assignments de sua própria classe
			$classes_id = array();
			foreach ($this->class_model->get_parameters_Classes_user($user_id) as $class){
				array_push($classes_id, $class->class_id);
			}
			$data['all_assignments'] = $this->assignment_model->all_assignments_classes($classes_id);
		} else{
			$data['all_assignments'] = $this->assignment_model->all_assignments();
		}

    if ( $assignment_id == 0
      OR ( $this->user->level == 0 && ! $assignment['open'] )
      OR shj_now() < strtotime($assignment['start_time'])
      OR shj_now() > strtotime($assignment['finish_time'])+$assignment['extra_time'] // deadline = finish_time + extra_time
      OR ! $this->assignment_model->is_participant($assignment['participants'], $this->user->username)
    )
      $data['can_submit'] = FALSE;

    $possible_assignments_ids = array();
    foreach ($data['all_assignments'] as $possible_assignment) {
    	array_push($possible_assignments_ids, $possible_assignment['id']);    
    }
    if(!in_array($assignment_id, $possible_assignments_ids) && ($this->user->level == 0)){
    	show_404();
    }
	  $this->twig->display('pages/problems.twig', $data);
	}


	// ------------------------------------------------------------------------


	/**
	 * Edit problem description as html/markdown
	 *
	 * $type can be 'md', 'html', or 'plain'
	 *
	 * @param string $type
	 * @param int $assignment_id
	 * @param int $problem_id
	 */
	public function edit($type = 'md', $assignment_id = NULL, $problem_id = 1)
	{
		if ($type !== 'html' && $type !== 'md' && $type !== 'plain')
			show_404();

		if ($this->user->level <= 1)
			show_404();

		switch($type)
		{
			case 'html':
				$ext = 'html'; break;
			case 'md':
				$ext = 'md'; break;
			case 'plain':
				$ext = 'html'; break;
		}

		if ($assignment_id === NULL)
			$assignment_id = $this->user->selected_assignment['id'];
		if ($assignment_id == 0)
			show_error('No assignment selected.');

		$data = array(
			'all_assignments' => $this->assignment_model->all_assignments(),
			'description_assignment' => $this->assignment_model->assignment_info($assignment_id),
			'enable_scoreboard'=>$this->settings_model->get_setting('enable_scoreboard')
		);

		if ( ! is_numeric($problem_id) || $problem_id < 1 || $problem_id > $data['description_assignment']['problems'])
			show_404();

		$this->form_validation->set_rules('text', 'text' ,''); /* todo: xss clean */
		if ($this->form_validation->run())
		{
			$this->assignment_model->save_problem_description($assignment_id, $problem_id, $this->input->post('text'), $ext);
			redirect('problems/'.$assignment_id.'/'.$problem_id);
		}

		$data['problem'] = array(
			'id' => $problem_id,
			'description' => ''
		);

		$path = rtrim($this->settings_model->get_setting('assignments_root'),'/')."/assignment_{$assignment_id}/p{$problem_id}/desc.".$ext;
		if (file_exists($path))
			$data['problem']['description'] = file_get_contents($path);


		$this->twig->display('pages/admin/edit_problem_'.$type.'.twig', $data);

	}


	// ------------------------------------------------------------------------


	public function _language_to_type($language)
	{
		$language = strtolower ($language);
		switch ($language) {
			case 'c': return 'c';
			case 'c++': return 'cpp';
			case 'python 2': return 'py2';
			case 'python 3': return 'py3';
			case 'java': return 'java';
			case 'zip': return 'zip';
			case 'pdf': return 'pdf';
			default: return FALSE;
		}
	}


	// ------------------------------------------------------------------------


	public function _match($type, $extension)
	{
		$compressedformats = array('zip', 'rar', '7z');
		switch ($type) {
			case 'c': return (($extension==='c' or in_array($extension, $compressedformats))?TRUE:FALSE);
			case 'cpp': return (($extension==='cpp' or in_array($extension, $compressedformats))?TRUE:FALSE);
			case 'py2': return ($extension==='py'?TRUE:FALSE);
			case 'py3': return ($extension==='py'?TRUE:FALSE);
			case 'java': return ($extension==='java'?TRUE:FALSE);
			case 'zip': return ($extension==='zip'?TRUE:FALSE);
			case 'pdf': return ($extension==='pdf'?TRUE:FALSE);
		}
	}


	// ------------------------------------------------------------------------


	public function _check_language($str)
	{
		if ($str=='0')
			return FALSE;
		if (in_array( strtolower($str),array('c', 'c++', 'python 2', 'python 3', 'java', 'zip', 'pdf')))
			return TRUE;
		return FALSE;
	}

	// ------------------------------------------------------------------------


	/**
	 * Validate form
	 *
	 *
	 */
	public function form_validation() // Validação do form de envio de problemas.
	{
		// Atribuindo regras`ao envio do problema:
		$this->form_validation->set_rules('problem', 'problem', 'required|integer|greater_than[0]', array('greater_than' => 'Select a %s.'));
		$this->form_validation->set_rules('language', 'language', 'required|callback__check_language', array('_check_language' => 'Select a valid %s.'));

		// Se a submissão seguir as regras definidas acima, chama a função "_upload()" e redireciona para a página de todas as submissões:
		if ($this->form_validation->run())
		{
			if ($this->_upload())
				redirect('submissions/all');
			else
				show_error('Error Uploading File: '.$this->upload->display_errors());
		}

		$this->data = array(
			'all_assignments' => $this->assignment_model->all_assignments(), // Vetor com todos os assignments
			'problems' => $this->problems, //Vetor com todos os problems relacionados ao assignment escolhido
			'in_queue' => FALSE,
			'coefficient' => $this->coefficient,
			'upload_state' => '',
			'problems_js' => '',
			'error' => '',
		);
		foreach ($this->problems as $problem)
		{
			//OBS.: A função "explode" cria um vetor com as linguagens permitidas pelo problema em posições diferentes, a partir de uma string.
			$languages = explode(',', $problem['allowed_languages']);
			$items='';
			foreach ($languages as $language)
			{
				$items = $items."'".trim($language)."',"; // Cria uma única string com as linguagens permitidas.
			}
			$items = substr($items,0,strlen($items)-1); // Retira a última virgúla da string.
			$this->data['problems_js'] .= "shj.p[{$problem['id']}]=[{$items}]; ";//?????
		}

	//Verificação de erros no envio do assignment:

		//Erro 1: Assignment não selecionado
		if ($this->user->selected_assignment['id'] == 0)
			$this->data['error']='Please select an assignment first.';
		//Erro 2: Usuário é estudante e o assignment está fechado (professores ainda podem enviar)
		elseif ($this->user->level == 0 && ! $this->user->selected_assignment['open'])
			$this->data['error'] = 'Selected assignment is closed.';
		//Erro 3: Assignment ainda não começou
		elseif (shj_now() < strtotime($this->user->selected_assignment['start_time']))
			$this->data['error'] = 'Selected assignment has not started.';
		//Erro 4: Assigment já acabou
		elseif (shj_now() > strtotime($this->user->selected_assignment['finish_time'])+$this->user->selected_assignment['extra_time']) // deadline = finish_time + extra_time
			$this->data['error'] = 'Selected assignment has finished.';
		//Erro 5: Usuário não participa desse assignment
		elseif ( ! $this->assignment_model->is_participant($this->user->selected_assignment['participants'],$this->user->username) )
			$this->data['error'] = 'You are not registered for submitting.';
		else
			$this->data['error'] = 'none';

	//Redireciona para a view do submit

		$this->data['form_validation'] = TRUE;
		$this->twig->display('pages/problems.twig', $this->data);
	}


	// ------------------------------------------------------------------------


	/**
	 * Saves submitted code and adds it to queue for judging
	 */
	private function _upload()
	{
		$now = shj_now();
		foreach($this->problems as $item)
			if ($item['id'] == $this->input->post('problem'))
			{
				$this->problem = $item;
				break;
			}
		$this->filetype = $this->_language_to_type(strtolower(trim($this->input->post('language'))));
		$this->ext = substr(strrchr($_FILES['userfile']['name'],'.'),1); // uploaded file extension
		$this->file_name = basename($_FILES['userfile']['name'], ".{$this->ext}"); // uploaded file name without extension
		if ( $this->queue_model->in_queue($this->user->username,$this->user->selected_assignment['id'], $this->problem['id']) )
			show_error('You have already submitted for this problem. Your last submission is still in queue.');
		if ($this->user->level==0 && !$this->user->selected_assignment['open'])
			show_error('Selected assignment has been closed.');
		if ($now < strtotime($this->user->selected_assignment['start_time']))
			show_error('Selected assignment has not started.');
		if ($now > strtotime($this->user->selected_assignment['finish_time'])+$this->user->selected_assignment['extra_time'])
			show_error('Selected assignment has finished.');
		if ( ! $this->assignment_model->is_participant($this->user->selected_assignment['participants'],$this->user->username) )
			show_error('You are not registered for submitting.');
		$filetypes = explode(",",$this->problem['allowed_languages']);
		foreach ($filetypes as &$filetype)
		{
			$filetype = $this->_language_to_type(strtolower(trim($filetype)));
		}
		if ($_FILES['userfile']['error'] == 4)
			show_error('No file chosen.');
		if ( ! in_array($this->filetype, $filetypes))
			show_error('This file type is not allowed for this problem.');
		if ( ! $this->_match($this->filetype, $this->ext) )
			show_error('This file type does not match your selected language.');
		if ( ! preg_match('/^[a-zA-Z0-9_\-()]+$/', $this->file_name) )
			show_error('Invalid characters in file name.');

		$user_dir = rtrim($this->assignment_root, '/').'/assignment_'.$this->user->selected_assignment['id'].'/p'.$this->problem['id'].'/'.$this->user->username;
		if ( ! file_exists($user_dir))
			mkdir($user_dir, 0700);

		$config['upload_path'] = $user_dir;
		$config['allowed_types'] = '*';
		$config['max_size']	= $this->settings_model->get_setting('file_size_limit');
		$config['file_name'] = $this->file_name."-".($this->user->selected_assignment['total_submits']+1).".".$this->ext;
		$config['max_file_name'] = 20;
		$config['remove_spaces'] = TRUE;
		$this->upload->initialize($config);

		if ($this->upload->do_upload('userfile'))
		{
			$result = $this->upload->data();
			$this->load->model('submit_model');

			$submit_info = array(
				'submit_id' => $this->assignment_model->increase_total_submits($this->user->selected_assignment['id']),
				'username' => $this->user->username,
				'assignment' => $this->user->selected_assignment['id'],
				'problem' => $this->problem['id'],
				'weight'  => $this->problem['weight'],
				'file_name' => $result['raw_name'],
				'main_file_name' => $this->file_name,
				'file_type' => $this->filetype,
				'coefficient' => $this->coefficient,
				'pre_score' => 0,
				'time' => shj_now_str(),
			);
			if ($this->problem['is_upload_only'] == 0)
			{
				$this->queue_model->add_to_queue($submit_info);
				process_the_queue();
			}
			else
			{
				$this->submit_model->add_upload_only($submit_info);
			}

			return TRUE;
		}

		return FALSE;
	}


}
