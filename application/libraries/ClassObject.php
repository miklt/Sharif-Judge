<?php defined('BASEPATH') OR exit('No direct script access allowed');

//Classe para criação de objetos classe
class ClassObject{

	// Class with their users: 
    public function __construct($params)
    {
    	$number_params = count($params);
    	if ($number_params == 9){
    		$this->class_id = $params['class_id'];
	    	$this->class_name = $params['class_name'];
			$this->day = $params['day'];
			$this->time_start = $params['time_start'];
			$this->time_end = $params['time_end'];
			$this->classroom = $params['classroom'];
			$this->teachers = $params['teachers'];
			$this->assistants = $params['assistants'];
			$this->new_students = $params['students'];
    	} else if ($number_params == 6){
    		$this->class_id = $params['class_id'];
	    	$this->class_name = $params['class_name'];
			$this->day = $params['day'];
			$this->time_start = $params['time_start'];
			$this->time_end = $params['time_end'];
			$this->classroom = $params['classroom'];
    	}	
    }
}