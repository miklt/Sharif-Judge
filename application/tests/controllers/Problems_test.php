<?php
/**
 * Part of ci-phpunit-test
 *
 * @author     Kenji Suzuki <https://github.com/kenjis>
 * @license    MIT License
 * @copyright  2015 Kenji Suzuki
 * @link       https://github.com/kenjis/ci-phpunit-test
 */

class Problems_test extends TestCase
{
	public function test_index()
	{
        $this->login();
        $output = $this->request('GET','problems');
		$this->assertContains('<table class="sharif_table">', $output);
	}

    public function login() {
        $output = $this->request('POST','login', ['username' => 'aluno', 'password' => '123456']);
    }

}
