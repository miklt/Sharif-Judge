<?php
/**
 * Part of ci-phpunit-test
 *
 * @author     Kenji Suzuki <https://github.com/kenjis>
 * @license    MIT License
 * @copyright  2015 Kenji Suzuki
 * @link       https://github.com/kenjis/ci-phpunit-test
 */

class Submissions_test extends TestCase
{
	public function test_final()
	{
        $this->login();
        $output = $this->request('GET','submissions/final');
		$this->assertContains('<title>Final Submissions - Sharif Judge</title>', $output);
	}   

    public function test_all() {
        $this->login();
        $output = $this->request('GET','submissions/all');
		$this->assertContains('<title>All Submissions - Sharif Judge</title>', $output);
    }

    public function login() {
        $output = $this->request('POST','login', ['username' => 'aluno', 'password' => '123456']);
    }

}
