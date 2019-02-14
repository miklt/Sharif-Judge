<?php
/**
 * Sharif Judge online judge
 * @file Classes.php
 * @author Pedro Viganó da Silva Santos <pedro.vigano.santos@usp.br>
 */
defined('BASEPATH') OR exit('No direct script access allowed');

class Classes extends CI_Controller
{
	public function __construct()
	{
		parent::__construct();
		if ( ! $this->session->userdata('logged_in')) // if not logged in
			redirect('login');
	}


	// ------------------------------------------------------------------------


	public function index()
	{
		$this->load->model('class_model');
		$this->load->model('assignment_model');
		$user_id = $this->user_model->username_to_user_id($this->user->username);
		
		if ($this->user->level == 0){//Estudantes veem apenas sua própria classe
			$classes_id = array();
			foreach ($this->class_model->get_parameters_Classes_user($user_id) as $class){
				array_push($classes_id, $class->class_id);
			}
			$data = array(
				'all_assignments' => $this->assignment_model->all_assignments_classes($classes_id),
				'classes' => $this->class_model->getClasses_user($user_id),
			);
			$this->twig->display('pages/classes.twig', $data); 
		} else {
			$data = array(
				'all_assignments' => $this->assignment_model->all_assignments(),
				'classes' => $this->class_model->getClasses()
			);
			$this->twig->display('pages/classes.twig', $data); // Carrega a view "classes".
		}
	}


	// ------------------------------------------------------------------------
	
	//Add class
	public function add()
	{
		if ( $this->user->level == 0) // Estudantes não podem ver esta página.
			show_404();

		$data = array(//array com os professores e monitores cadastrados
			'teachers' => $this->user_model->get_all_teachers(),
			'assistants' => $this->user_model->get_all_assistants());

		// Tornando todos os campos do forms obrigatórios:
		$this->form_validation->set_rules('class_name', 'Class Name', 'required');
		$this->form_validation->set_rules('day', 'Day', 'required');
		$this->form_validation->set_rules('time_start', 'Starting Time', 'required');
		$this->form_validation->set_rules('time_end', 'Ending Time', 'required');
		$this->form_validation->set_rules('teachers', 'Teachers', 'required');

		if ($this->form_validation->run())
		{
			$this->load->model('class_model');
			$this->class_model->create_class(
				$this->input->post('class_name'),
				$this->input->post('day'), 
				$this->input->post('time_start'), 
				$this->input->post('time_end'), 
				$this->input->post('classroom'), 
				$this->input->post('teachers'), 
				$this->input->post('assistants'), 
				$this->input->post('new_students')
			);
			$data = array(
				'classes' => $this->class_model->getClasses()
			);
			$this->twig->display('pages/classes.twig', $data); // Carrega a view "classes".
		}
		else
		{
			$this->twig->display('pages/admin/add_class.twig', $data);
		}
	}

	// ------------------------------------------------------------------------
	//Delete class


	public function delete($class_id)
	{
		if ( $this->user->level == 0) // Estudantes não podem ver esta página.
			show_404();

		$this->load->model('class_model');
		$this->class_model->delete_class($class_id);
		$data = array('classes' => $this->class_model->getClasses());
		$this->twig->display('pages/classes.twig', $data); // Carrega a view "classes"
	}

	public function displayClass($class_id)
	{
		$this->load->model('class_model');
		$data = array('class' => $this->class_model->getClass($class_id), 'edit' => 0);

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

		//Estudantes não podem visualizar outras classes:
    if(($this->user->level == 0) && (!in_array($class_id, $classes_id))){
    	show_404();
    }
		$this->twig->display('pages/class.twig', $data); 
	}

	public function selection()
	{
		if ( $this->user->level == 0) // Estudantes não podem ver esta página.
			show_404();
			
		$this->load->model('class_model');
		if($this->input->post('class_selection') == "0"){
			$data = array(
				'classes' => $this->class_model->getClasses(),
				'class_selection' => $this->input->post('class_selection')
			);
			$this->twig->display('pages/classes.twig', $data);
		} 
		elseif ($this->input->post('class_selection') == "1"){
			$user_id = $this->user_model->username_to_user_id($this->user->username);
			$data = array(
				'classes' => $this->class_model->getClasses_user($user_id),
				'class_selection' => $this->input->post('class_selection')
			);
			$this->twig->display('pages/classes.twig', $data); 
		}

	}

	public function edit($class_id)
	{
		if ( $this->user->level == 0) // Estudantes não podem ver esta página.
			show_404();

		$this->load->model('class_model');
		$data = array(//array com os professores e monitores cadastrados
			'teachers' => $this->user_model->get_all_teachers(),
			'assistants' => $this->user_model->get_all_assistants(),
			'class' => $this->class_model->getClass($class_id),
			'edit' => 1
		);

		// Tornando os campos do forms obrigatórios:
		$this->form_validation->set_rules('class_name', 'Class Name', 'required');
		$this->form_validation->set_rules('day', 'Day', 'required');
		$this->form_validation->set_rules('time_start', 'Starting Time', 'required');
		$this->form_validation->set_rules('time_end', 'Ending Time', 'required');


		if ($this->form_validation->run())
		{
			$this->load->model('class_model');
			$this->class_model->edit_class(
				$class_id,
				$this->input->post('class_name'),
				$this->input->post('day'), 
				$this->input->post('time_start'), 
				$this->input->post('time_end'), 
				$this->input->post('classroom')
			);
			$data = array(//update do array data
				'teachers' => $this->user_model->get_all_teachers(),
				'assistants' => $this->user_model->get_all_assistants(),
				'class' => $this->class_model->getClass($class_id),
				'edit' => 1
			);
		}
		$this->twig->display('pages/class.twig', $data);
	}

	public function add_user($class_id, $responsible)
	{
		if ( $this->user->level == 0) // Estudantes não podem ver esta página.
			show_404();

		if ($responsible == 0){//Adicionando estudantes
			$this->form_validation->set_rules('new_students', 'New Students', 'required');
			if ($this->form_validation->run())
			{
				$this->load->model('user_model');
				$this->load->model('class_model');
				$lines = preg_split('/\r?\n|\n?\r/', $this->input->post('new_students'));
				$students_id = array();
				// loop over lines of $text :
				foreach ($lines as $line)
				{
					$line = trim($line);

					if (strlen($line) == 0 OR $line[0] == '#')
						continue; //ignore comments and empty lines

					array_push($students_id, $this->user_model->username_to_user_id($line));//array com ids dos estudantes
				} // end of loop
				$this->class_model->add_students($students_id, $class_id, $responsible);
			}
		} elseif ($responsible == 1){//Adicionando monitores
			$this->form_validation->set_rules('assistant', 'Assistant Name', 'required');
			if ($this->form_validation->run())
			{
				$this->load->model('class_model');
				$this->load->model('user_model');
				$assistant_id = $this->user_model->username_to_user_id($this->input->post('assistant'));
				$this->class_model->add_user($assistant_id, $class_id, $responsible);
			}
		} elseif ($responsible == 2) {//Adicionando professores
			$this->form_validation->set_rules('teacher', 'Teacher Name', 'required');
			if ($this->form_validation->run())
			{
				$this->load->model('class_model');
				$this->load->model('user_model');
				$teacher_id = $this->user_model->username_to_user_id($this->input->post('teacher'));
				$this->class_model->add_user($teacher_id, $class_id, $responsible);
			}
		}
		$data = array(//update do array data
				'teachers' => $this->user_model->get_all_teachers(),
				'assistants' => $this->user_model->get_all_assistants(),
				'class' => $this->class_model->getClass($class_id),
				'edit' => 1
		);
		$this->twig->display('pages/class.twig', $data);

		

	}

	public function remove_user($class_id, $user_id, $responsible)
	{
		if ( $this->user->level == 0) // Estudantes não podem ver esta página.
			show_404();

		$this->load->model('class_model');
		//Removendo o usuário
		$this->class_model->remove_user($class_id, $user_id, $responsible);	

		//Reload da página:
		$data = array(//array com os professores e monitores cadastrados
			'teachers' => $this->user_model->get_all_teachers(),
			'assistants' => $this->user_model->get_all_assistants(),
			'class' => $this->class_model->getClass($class_id),
			'edit' => 1
		);
		$this->twig->display('pages/class.twig', $data);


	}


}