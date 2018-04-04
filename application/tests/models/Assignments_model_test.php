<?php

class Assignment_model_test extends TestCase
{
	public function setUp()
	{
		$this->resetInstance();
		$this->CI->load->model('Assignment_model');
		$this->obj = $this->CI->Assignment_model;
	}

	public function sum_of_problems()
	{
        $expected = 100;
        $assignments = $this->obj->all_assignments();
		foreach ($assignments as $assignment) {
            $problems = $this->obj->all_problems($assignment['id']);
            $sum = 0;
            foreach ($problems as $problem) {
                $sum = $sum + $problem['weight'];
            }
            if ($sum != $expected) {
                $flag = FALSE;
            }
        }
        $this->assertEquals(TRUE, $flag);
    }
    
}