<?php
/**
 * Sharif Judge online judge
 * @file Class_model.php
 * @author Pedro Viganó da Silva Santos <pedro.vigano.santos@usp.br> 
 */
defined('BASEPATH') OR exit('No direct script access allowed');

class Class_model extends CI_Model
{

	public function __construct()
	{
		parent::__construct();
	}

	// ------------------------------------------------------------------------
	/**
	 * Create Class
	 *
	 *
	 * @param $class_name
	 * @param $teachers
	 * @param $assistants
	 * @param $students
	 * @param $day
	 * @param $time_start
	 * @param $time_end
	 * @param $classroom
	 */

	public function create_class($class_name, $day, $time_start, $time_end, $classroom, $teachers, $assistants, $new_students)
	{
		$lines = preg_split('/\r?\n|\n?\r/', $new_students);
		$students = array();
		// loop over lines of $text :
		foreach ($lines as $line)
		{
			$line = trim($line);

			if (strlen($line) == 0 OR $line[0] == '#')
				continue; //ignore comments and empty lines

			array_push($students, $line);
		} // end of loop

		$class = array(
			'class_name' => $class_name,
			'day' => $day,
			'time_start' => $time_start,
			'time_end' => $time_end,
			'classroom' => $classroom
		);
		$this->db->insert('classes', $class);//Criando uma classe
		$class_id = $this->db->insert_id();//$class_id recebe o id da última classe adicionada 
		$assigned_teachers_id = array();
		foreach ($teachers as $teacher) {//Adicionando professores à classe
			//Checando se o mesmo professor já não foi adicionado:
			if (!in_array($this->user_model->username_to_user_id($teacher), $assigned_teachers_id)){
				$data_teacher = array(
					'user_id' => $this->user_model->username_to_user_id($teacher),
					'class_id' => $class_id,
					'responsible' => 2
				);
				$this->db->insert('users_classes', $data_teacher);
				array_push($assigned_teachers_id, $this->user_model->username_to_user_id($teacher));
			}	
		}
		$assigned_assistants_id = array();
		foreach ($assistants as $assistant) {//Adicionando monitores à classe
			//Checando se o mesmo monitor já não foi adicionado:
			if (!in_array($this->user_model->username_to_user_id($assistant), $assigned_assistants_id)){
				$data_assistant = array(
					'user_id' => $this->user_model->username_to_user_id($assistant),
					'class_id' => $class_id,
					'responsible' => 1
				);
				$this->db->insert('users_classes', $data_assistant);
				array_push($assigned_assistants_id, $this->user_model->username_to_user_id($assistant));
			}	
		}
		$assigned_students_id = array();
		foreach ($students as $student) {//Adicionando alunos à classe
			//Checando se o mesmo estudante já não foi adicionado:
			if (!in_array($this->user_model->username_to_user_id($student), $assigned_students_id)){
				$data_student = array(
					'user_id' => $this->user_model->username_to_user_id($student),
					'class_id' => $class_id,
					'responsible' => 0
				);
				$this->db->insert('users_classes', $data_student);
				array_push($assigned_students_id, $this->user_model->username_to_user_id($student));
			}	
		}

	}
// ------------------------------------------------------------------------
	/**
	 * Edit Class
	 *
	 * @param $class_id
	 * @param $class_name
	 * @param $teachers
	 * @param $assistants
	 * @param $students
	 * @param $day
	 * @param $time_start
	 * @param $time_end
	 * @param $classroom
	 */

	public function edit_class($class_id, $class_name, $day, $time_start, $time_end, $classroom)
	{

		$class = array(
			'class_name' => $class_name,
			'day' => $day,
			'time_start' => $time_start,
			'time_end' => $time_end,
			'classroom' => $classroom
		);
		$this->db->set($class);
		$this->db->where('id', $class_id);
		$this->db->update('classes');//Editando uma classe
	}

	// ------------------------------------------------------------------------
	/*
	 * Delete Classes
	 *
	 */
	public function delete_class($class_id){
		$this->db->delete('classes', array('id' => $class_id));
		$this->db->delete('users_classes', array('class_id' => $class_id));	
	}

	// ------------------------------------------------------------------------
	/**
	 * Get Classes and users of classes
	 *
	 *
	 * @return array of all classes
	 */
	public function getClasses()
	{
		$this->db->order_by('class_name', 'ASC');
		$query_classes = $this->db->get('classes');
		$classes = array();
		$teachers = array();
		$assistants = array();
		$students = array();

		foreach ($query_classes->result() as $row)
		{
			$query_users = $this->db->get_where('users_classes', array('class_id' => $row->id));
			foreach ($query_users->result() as $user)
			{	
				//vetor com professores:
				if($user->responsible == 2){
					array_push($teachers, $this->user_model->user_id_to_username($user->user_id));
				}
				//vetor com monitores:
				if($user->responsible == 1){
					array_push($assistants, $this->user_model->user_id_to_username($user->user_id));
				}
				//vetor com alunos:
				if($user->responsible == 0){
					array_push($students, $this->user_model->user_id_to_username($user->user_id));
				}
			}
        	$params = array(
        		"class_id" => $row->id,
        		"class_name" => $row->class_name,
        		"day" => $row->day,
        		"time_start" => $row->time_start,
        		"time_end" => $row->time_end,
        		"classroom" => $row->classroom,
        		"teachers" => $teachers,
        		"assistants" => $assistants,
        		"students" => $students
        	);
        	$this->load->library('classObject', $params);
        	$class = new ClassObject($params);
        	array_push($classes, $class);
        	$teachers = array();
        	$assistants = array();
        	$students = array();
		}
		return $classes;
	}

// ------------------------------------------------------------------------
	/**
	 * Get Classes without users of classes
	 *
	 *
	 * @return array of all classes without their users
	 */
	public function get_parameters_Classes()
	{
		$this->db->order_by('class_name', 'ASC');
		$query_classes = $this->db->get('classes');
		$classes = array();

		foreach ($query_classes->result() as $row)
		{
        	$params = array(
        		"class_id" => $row->id,
        		"class_name" => $row->class_name,
        		"day" => $row->day,
        		"time_start" => $row->time_start,
        		"time_end" => $row->time_end,
        		"classroom" => $row->classroom
        	);
        	$this->load->library('classObject', $params);
        	$class = new ClassObject($params);
        	array_push($classes, $class);
		}
		return $classes;
	}


// ------------------------------------------------------------------------
	/**
	 * Get Classes of user
	 *
	 *
	 * @return array of all classes the user participates
	 */
	public function getClasses_user($user_id)
	{
		$this->db->select('class_id');
		$query_classes_user = $this->db->get_where('users_classes', array('user_id' => $user_id));
		$classes_id = array();
		foreach ($query_classes_user->result() as $row) {
			array_push($classes_id, $row->class_id);
		}
		if ($classes_id) {
			$this->db->where_in('id', $classes_id);	
		}
		$this->db->order_by('class_name', 'ASC');
		$query_classes = $this->db->get('classes');
		$classes = array();
		$teachers = array();
		$assistants = array();
		$students = array();


		if ($query_classes) {
			foreach ($query_classes->result() as $row)
			{
				$query_users = $this->db->get_where('users_classes', array('class_id' => $row->id));
				foreach ($query_users->result() as $user)
				{	
					//vetor com professores:
					if($user->responsible == 2){
						array_push($teachers, $this->user_model->user_id_to_username($user->user_id));
					}
					//vetor com monitores:
					if($user->responsible == 1){
						array_push($assistants, $this->user_model->user_id_to_username($user->user_id));
					}
					//vetor com alunos:
					if($user->responsible == 0){
						array_push($students, $this->user_model->user_id_to_username($user->user_id));
					}
				}
				$params = array(
					"class_id" => $row->id,
					"class_name" => $row->class_name,
					"day" => $row->day,
					"time_start" => $row->time_start,
					"time_end" => $row->time_end,
					"classroom" => $row->classroom,
					"teachers" => $teachers,
					"assistants" => $assistants,
					"students" => $students
				);
				$this->load->library('classObject', $params);
				$class = new ClassObject($params);
				array_push($classes, $class);
				$teachers = array();
				$assistants = array();
				$students = array();
			}
		}
		return $classes;
	}

// ------------------------------------------------------------------------
	/**
	 * Get Classes of user
	 *
	 *
	 * @return array of parameters of all classes the user participates 
	 */
	public function get_parameters_Classes_user($user_id)
	{
		$this->db->select('class_id');
		$query_classes_user = $this->db->get_where('users_classes', array('user_id' => $user_id));
		$classes_id = array();
		foreach ($query_classes_user->result() as $row) {
			array_push($classes_id, $row->class_id);
		}
		if (!$classes_id) {
			return [];
		}
		$this->db->where_in('id', $classes_id);
		$query_classes = $this->db->get('classes');
		$classes = array();
	
		foreach ($query_classes->result() as $row)
		{
        	$params = array(
        		"class_id" => $row->id,
        		"class_name" => $row->class_name,
        		"day" => $row->day,
        		"time_start" => $row->time_start,
        		"time_end" => $row->time_end,
        		"classroom" => $row->classroom
        	);
        	$this->load->library('classObject', $params);
        	$class = new ClassObject($params);
        	array_push($classes, $class);
		}
		return $classes;
	}	

// ------------------------------------------------------------------------
	/**
	 * Get Class by ID
	 *
	 *
	 * @return object class
	 */
	public function getClass($class_id)
	{
		$query_class = $this->db->get_where('classes', array('id' => $class_id));
		$teachers = array();
		$assistants = array();
		$students = array();


		foreach ($query_class->result() as $row)
		{
			$query_users = $this->db->get_where('users_classes', array('class_id' => $row->id));
			foreach ($query_users->result() as $user)
			{	
				//vetor com professores:
				if($user->responsible == 2)
				{
					$query_user = $this->db->get_where('users', array('id' => $user->user_id));
					$user_data = $query_user->row();
	        		$user_params = array(
		        		"id" => $user_data->id,
		        		"username" => $user_data->username,
		        		"display_name" => $user_data->display_name,
		        		"email" => $user_data->email,
		        		"role" => $user_data->role,
		        		"first_login_time" => $user_data->first_login_time,
		        		"last_login_time" => $user_data->last_login_time
	        		);
		        	$this->load->library('userObject', $user_params);
		        	$userObject = new userObject($user_params);
		        	array_push($teachers, $userObject);
				}
				//vetor com monitores:
				if($user->responsible == 1)
				{
					$query_user = $this->db->get_where('users', array('id' => $user->user_id));
					$user_data = $query_user->row();
	        		$user_params = array(
		        		"id" => $user_data->id,
		        		"username" => $user_data->username,
		        		"display_name" => $user_data->display_name,
		        		"email" => $user_data->email,
		        		"role" => $user_data->role,
		        		"first_login_time" => $user_data->first_login_time,
		        		"last_login_time" => $user_data->last_login_time
	        		);
		        	$this->load->library('userObject', $user_params);
		        	$userObject = new userObject($user_params);
		        	array_push($assistants, $userObject);
				}
				//vetor com alunos:
				if($user->responsible == 0)
				{
					$query_user = $this->db->get_where('users', array('id' => $user->user_id));
					$user_data = $query_user->row();
	        		$user_params = array(
		        		"id" => $user_data->id,
		        		"username" => $user_data->username,
		        		"display_name" => $user_data->display_name,
		        		"email" => $user_data->email,
		        		"role" => $user_data->role,
		        		"first_login_time" => $user_data->first_login_time,
		        		"last_login_time" => $user_data->last_login_time
	        		);
		        	$this->load->library('userObject', $user_params);
		        	$userObject = new userObject($user_params);
		        	array_push($students, $userObject);
				}
			}
        	$params = array(
        		"class_id" => $row->id,
        		"class_name" => $row->class_name,
        		"day" => $row->day,
        		"time_start" => $row->time_start,
        		"time_end" => $row->time_end,
        		"classroom" => $row->classroom,
        		"teachers" => $teachers,
        		"assistants" => $assistants,
        		"students" => $students
        	);
        	$this->load->library('classObject', $params);
        	$class = new ClassObject($params);
		}
		return $class;	
	}
// ------------------------------------------------------------------------

	public function remove_user($class_id, $user_id, $responsible){
		$query_users = $this->db->get_where('users_classes', 
			array('class_id' => $class_id, 'responsible' => $responsible));
		if ((($query_users->num_rows() > 1) && $responsible == 2 ) || $responsible < 2){
			$this->db->delete('users_classes', array('class_id' => $class_id, 'user_id' => $user_id));
		}
	}

// ------------------------------------------------------------------------

	public function add_user($user_id, $class_id, $responsible){
		$data = array(
	        'user_id' => $user_id,
	        'class_id' => $class_id,
	        'responsible' => $responsible
		);
		$this->db->insert('users_classes', $data);
	}

// ------------------------------------------------------------------------

	public function add_students($students_id, $class_id, $responsible)
	{	
		//Obtendo vetor com os estudantes já cadastrados:
		$this->db->select('user_id');
		$query_assigned_students = $this->db->get_where('users_classes', 
		array('class_id' => $class_id, 'responsible' => $responsible));

		$assigned_students_id = array();
		foreach ($query_assigned_students->result() as $assigned_student){
			array_push($assigned_students_id, $assigned_student->user_id);		
		}
		foreach ($students_id as $student_id) 
		{	
			//Checando se estudante já não foi adicionado:
			if (!in_array($student_id, $assigned_students_id)){
				$data = array(
					'user_id' => $student_id,
		        	'class_id' => $class_id,
		        	'responsible' => $responsible
				);
				$this->db->insert('users_classes', $data);
				array_push($assigned_students_id, $student_id);
			}
		}	
	}
}
