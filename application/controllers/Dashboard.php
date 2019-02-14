<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
/**
 * Sharif Judge online judge
 * @file Dashboard.php
 * @author Mohammad Javad Naderi <mjnaderi@gmail.com>
 */
defined('BASEPATH') OR exit('No direct script access allowed');

class Dashboard extends CI_Controller
{


	public function __construct()
	{
		parent::__construct();
		if ( ! $this->db->table_exists('sessions')) // Se não existir banco de dados, redirecionar para a página de instalação.
			redirect('install');
		if ( ! $this->session->userdata('logged_in')) // Se não estiver logado, redirecionar para a página de login.
			redirect('login');
		$this->load->model('notifications_model')->helper('text'); // Carregar "notifications_model".
	}


	// ------------------------------------------------------------------------


	public function index()
	{
		$data = array(
			'week_start'=>$this->settings_model->get_setting('week_start'),
			'wp'=>$this->user->get_widget_positions(), // Retorna as posições dos widgets específicas do usuário logado.
			'notifications' => $this->notifications_model->get_latest_notifications() // Retorna as últimas dez notificações.
		);
		
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

		// detecting errors in the installation:
		$data['errors'] = array();
		if($this->user->level === 3){
			$path = $this->settings_model->get_setting('assignments_root');
			if ( ! file_exists($path))
				array_push($data['errors'], 'The path to folder "assignments" is not set correctly. Move this folder somewhere not publicly accessible, and set its full path in Settings.');
			elseif ( ! is_writable($path))
				array_push($data['errors'], 'The folder <code>"'.$path.'"</code> is not writable by PHP. Make it writable. But make sure that this folder is only accessible by you. Codes will be saved in this folder!');

			$path = $this->settings_model->get_setting('tester_path');
			if ( ! file_exists($path))
				array_push($data['errors'], 'The path to folder "tester" is not set correctly. Move this folder somewhere not publicly accessible, and set its full path in Settings.');
			elseif ( ! is_writable($path))
				array_push($data['errors'], 'The folder <code>"'.$path.'"</code> is not writable by PHP. Make it writable. But make sure that this folder is only accessible by you.');
		}

		$this->twig->display('pages/dashboard.twig', $data); // Carrega a view do Dashboard.
	}


	// ------------------------------------------------------------------------

	/**
	 * Used by ajax request, for saving the user's Dashboard widget positions
	 */
	public function widget_positions()
	{
		if ( ! $this->input->is_ajax_request() )
			show_404();
		if ($this->input->post('positions') !== NULL)
			$this->user->save_widget_positions($this->input->post('positions'));
	}

}
