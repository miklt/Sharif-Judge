<?php defined('BASEPATH') OR exit('No direct script access allowed');

//Classe para criação de objetos classe
class UserObject{

    public function __construct($params)
    {
    	$this->id = $params['id'];
    	$this->username = $params['username'];
		$this->display_name = $params['display_name'];
		$this->email = $params['email'];
		$this->role = $params['role'];
		$this->first_login_time = $params['first_login_time'];
		$this->last_login_time = $params['last_login_time'];
    }
}