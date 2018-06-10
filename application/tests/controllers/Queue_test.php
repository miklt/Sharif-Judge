<?php
/**
 * <TODO:> USAR MOCK https://github.com/kenjis/ci-phpunit-test/blob/master/docs/HowToWriteTests.md#examine-dom-in-controller-output </TODO:>
 * 
 * 
 * Part of ci-phpunit-test
 *
 * @author     Kenji Suzuki <https://github.com/kenjis>
 * @license    MIT License
 * @copyright  2015 Kenji Suzuki
 * @link       https://github.com/kenjis/ci-phpunit-test
 */

class Queue_test extends TestCase
{
	public function test_index()
	{
        $this->login();
        $output = $this->request('GET','queue');
		$this->assertContains('<title>Submission Queue - Sharif Judge</title>', $output);
	}

    public function login() {
        $output = $this->request('POST','login', ['username' => 'admin', 'password' => '123456']);
    }
    
}
