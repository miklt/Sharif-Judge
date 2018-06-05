<?php defined('BASEPATH') OR exit('No direct script access allowed');

//Classe para criação de objetos classe
class ClassObject{

    public function __construct($params)
    {
    	$this->class_id = $params['class_id'];
    	$this->class_name = $params['class_name'];
		$this->day = $params['day'];
		$this->time_start = $params['time_start'];
		$this->time_end = $params['time_end'];
		$this->classroom = $params['classroom'];
		$this->teachers = $params['teachers'];
		$this->assistants = $params['assistants'];
		$this->new_students = $params['students'];
    }
}