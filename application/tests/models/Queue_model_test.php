<?php
/**
 * Part of ci-phpunit-test
 *
 * @author     Kenji Suzuki <https://github.com/kenjis>
 * @license    MIT License
 * @copyright  2015 Kenji Suzuki
 * @link       https://github.com/kenjis/ci-phpunit-test
 */

class Queue_model_test extends TestCase
{
    public function setUp()
	{
		$this->obj = $this->newModel('Queue_model');
	}
	public function test_empty_method()
	{
		$this->obj->empty_queue();
        $list = $this->obj->get_queue();
        $this->assertEquals([], $list);
	}
}