<?php if (!defined('BASEPATH')) exit('No direct script access allowed');
/**
 * Library to wrap Twig layout engine. Originally from Bennet Matschullat.
 * Code cleaned up to CodeIgniter standards by Erik Torsner
 *
 * PHP Version 5.3
 *
 * @category Layout
 * @package  Twig
 * @author   Bennet M	atschullat <bennet@3mweb.de>
 * @author   Erik Torsner <erik@torgesta.com>
 * @license  Don't be a dick http://www.dbad-license.org/
 * @link     https://github.com/bmatschullat/Twig-Codeigniter
 */

/**
 * Main (and only) class for the Twig wrapper library
 */
class Twig
{
	const TWIG_CONFIG_FILE = 'twig';

	/**
	 * Path to templates. Usually application/views.
	 *
	 * @var string
	 */
	protected $template_dir;

	/**
	 * Path to cache.  Usually applcation/cache.
	 *
	 * @var string
	 */
	protected $cache_dir;

	/**
	 * Reference to code CodeIgniter instance.
	 *
	 * @var CodeIgniter object
	 */
	private $_ci;

	/**
	 * Twig environment see http://twig.sensiolabs.org/api/v1.8.1/Twig_Environment.html.
	 *
	 * @var Twig_Envoronment object
	 */
	private $twig;

	/**
	 * constructor of twig ci class
	 */
	public function __construct()
	{
		$this->_ci = & get_instance();
		$this->_ci->config->load(self::TWIG_CONFIG_FILE); // load config file
		// set include path for twig
		//ini_set('include_path', ini_get('include_path') . PATH_SEPARATOR . ');
		require_once LABOO_VENDOR_AUTOLOAD;
		// register autoloader
		
		log_message('debug', 'twig autoloader loaded');
		// init paths
		$this->template_dir = $this->_ci->config->item('template_dir');
		$this->cache_dir = $this->_ci->config->item('cache_dir');
		// load environment
		$loader = new \Twig\Loader\FilesystemLoader($this->template_dir);
		$this->twig = new \Twig\Environment($loader, array(
			'cache' => $this->cache_dir,
			'auto_reload' => TRUE
		));
		$this->ci_function_init();
	}

	/**
	 * render a twig template file
	 *
	 * @param string $template template name
	 * @param array $data contains all varnames
	 * @param boolean $render render or return raw?
	 *
	 * @return string
	 *
	 */
	public function render($template, $data = array(), $render = TRUE)
	{
		$template = $this->twig->load($template);
		return ($render) ? $template->render($data) : $template;
	}


	/** returns an array with data that should be displayed in every page **/
	 public function displayData()
	 {
		 $data = array();
		 $data['SHJ_VERSION'] = SHJ_VERSION;
		 $data['enable_scoreboard'] = $this->_ci->settings_model->get_setting('enable_scoreboard');
		 return $data;
	 }


	 /**
 	 * Execute the template and send to CI output
 	 *
 	 * @param string $template Name of template
 	 * @param array $data Parameters for template
 	 *
 	 * @return void
 	 *
 	 */
	public function display($template, $data = array())
	{
		if ($template != 'pages/admin/install.twig') {
			// merging param data and displayData
			$data = array_merge($data, $this->displayData());
		}
		$template = $this->twig->load($template);
		$this->_ci->output->append_output($template->render($data));
	}

	/**
	 * Entry point for controllers (and the likes) to register
	 * callback functions to be used from Twig templates
	 *
	 * @param string $name name of function
	 * @param \Twig\TwigFunction $function Function pointer
	 *
	 * @return void
	 *
	 */
	public function register_function($name, \Twig\TwigFunction $function)
	{
		$this->twig->addFunction($function);
	}

	/**
	 * Initialize standard CI functions
	 *
	 * @return void
	 */
	public function ci_function_init()
	{

		/* Functions */
		$this->twig->addFunction(new \Twig\TwigFunction('base_url', 'base_url', array('is_safe' => array('html'))));
		// Token CSRF para chamadas AJAX (o cookie é HttpOnly e não pode ser lido pelo JS).
		$this->twig->addFunction(new \Twig\TwigFunction('csrf_hash', fn() => $this->_ci->security->get_csrf_hash()));
		$this->twig->addFunction(new \Twig\TwigFunction('site_url', 'site_url', array('is_safe' => array('html'))));
		$this->twig->addFunction(new \Twig\TwigFunction('anchor', 'anchor'));
		$this->twig->addFunction(new \Twig\TwigFunction('shj_now_str', 'shj_now_str', array('is_safe' => array('html'))));
		$this->twig->addFunction(new \Twig\TwigFunction('rtrim', 'rtrim'));
		$this->twig->addFunction(new \Twig\TwigFunction('floor', 'floor'));
		$this->twig->addFunction(new \Twig\TwigFunction('ceil', 'ceil'));
		$this->twig->addFunction(new \Twig\TwigFunction('isset', static fn($value) => isset($value)));
		$this->twig->addFunction(new \Twig\TwigFunction('time_hhmm', 'time_hhmm', array('is_safe' => array('html'))));
		$this->twig->addFunction(new \Twig\TwigFunction('md5', 'md5', array('is_safe' => array('html'))));
		// form functions
		$this->twig->addFunction(new \Twig\TwigFunction('form_open', 'form_open', array('is_safe' => array('html'))));
		$this->twig->addFunction(new \Twig\TwigFunction('form_open_multipart', 'form_open_multipart', array('is_safe' => array('html'))));
		$this->twig->addFunction(new \Twig\TwigFunction('form_error', 'form_error', array('is_safe' => array('html'))));
		$this->twig->addFunction(new \Twig\TwigFunction('set_value', 'set_value'));
		$this->twig->addFunction(new \Twig\TwigFunction('set_checkbox', 'set_checkbox'));
		/*$this->twig->addFunction(new \Twig\TwigFunction('form_hidden', 'form_hidden'));
		$this->twig->addFunction(new \Twig\TwigFunction('form_input', 'form_input'));
		$this->twig->addFunction(new \Twig\TwigFunction('form_password', 'form_password'));
		$this->twig->addFunction(new \Twig\TwigFunction('form_upload', 'form_upload'));
		$this->twig->addFunction(new \Twig\TwigFunction('form_textarea', 'form_textarea'));
		$this->twig->addFunction(new \Twig\TwigFunction('form_dropdown', 'form_dropdown'));
		$this->twig->addFunction(new \Twig\TwigFunction('form_multiselect', 'form_multiselect'));
		$this->twig->addFunction(new \Twig\TwigFunction('form_fieldset', 'form_fieldset'));
		$this->twig->addFunction(new \Twig\TwigFunction('form_fieldset_close', 'form_fieldset_close'));
		$this->twig->addFunction(new \Twig\TwigFunction('form_checkbox', 'form_checkbox'));
		$this->twig->addFunction(new \Twig\TwigFunction('form_radio', 'form_radio'));
		$this->twig->addFunction(new \Twig\TwigFunction('form_submit', 'form_submit'));
		$this->twig->addFunction(new \Twig\TwigFunction('form_label', 'form_label'));
		$this->twig->addFunction(new \Twig\TwigFunction('form_reset', 'form_reset'));
		$this->twig->addFunction(new \Twig\TwigFunction('form_button', 'form_button'));
		$this->twig->addFunction(new \Twig\TwigFunction('form_close', 'form_close'));
		$this->twig->addFunction(new \Twig\TwigFunction('form_prep', 'form_prep'));
		$this->twig->addFunction(new \Twig\TwigFunction('set_select', 'set_select'));
		$this->twig->addFunction(new \Twig\TwigFunction('set_checkbox', 'set_checkbox'));
		$this->twig->addFunction(new \Twig\TwigFunction('set_radio', 'set_radio'));*/

		// This filter is used in add_assignment.twig
		$this->twig->addFilter(
			new \Twig\TwigFilter(
				'extra_time_formatter',
				function ($extra_time) {
					// convert to minutes
					$extra_time = floor($extra_time/60);
					// convert to H*60
					if ($extra_time % 60 == 0 )
						$extra_time = ($extra_time/60) . '*60';
					return $extra_time;
				}
			)
		);

		$this->_ci->load->model('user');
		$this->twig->addGlobal('user', $this->_ci->user);

	}
}

/* End of file Twig.php */
/* Location: ./libraries/Twig.php */
