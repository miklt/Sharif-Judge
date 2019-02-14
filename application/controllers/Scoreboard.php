<?php
/**
 * Sharif Judge online judge
 * @file Scoreboard.php
 * @author Mohammad Javad Naderi <mjnaderi@gmail.com>
 */
defined('BASEPATH') OR exit('No direct script access allowed');

class Scoreboard extends CI_Controller
{


	public function __construct()
	{
		parent::__construct();
		if ($this->input->is_cli_request())
			return;
		if ( ! $this->session->userdata('logged_in')) // if not logged in
			redirect('login');
	}


	// ------------------------------------------------------------------------


	public function index()
	{

		$this->load->model('scoreboard_model');

		$data = array(
			'scoreboard' => $this->scoreboard_model->get_scoreboard($this->user->selected_assignment['id'])
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

		$this->twig->display('pages/scoreboard.twig', $data);
	}


}