<?php
defined('BASEPATH') OR exit('No direct script access allowed');

/**
 * Falha de CSRF em formulário comum (token velho: página aberta há mais de
 * 2 h, outra aba, ou duas cargas simultâneas da página): em vez da página
 * "The action you requested is not allowed", volta ao mesmo endereço por GET,
 * que mostra o formulário com um token válido. Chamadas AJAX mantêm o 403.
 */
class MY_Security extends CI_Security {

	public function csrf_show_error()
	{
		$ajax = strtolower($_SERVER['HTTP_X_REQUESTED_WITH'] ?? '') === 'xmlhttprequest';
		$uri = $_SERVER['REQUEST_URI'] ?? '';
		if ( ! $ajax && ($_SERVER['REQUEST_METHOD'] ?? '') === 'POST'
			&& $uri !== '' && $uri[0] === '/' && strncmp($uri, '//', 2) !== 0
			&& strpos($uri, 'csrf_retry=') === FALSE)
		{
			$uri .= (strpos($uri, '?') === FALSE ? '?' : '&').'csrf_retry=1';
			header('Location: '.$uri, TRUE, 303);
			exit;
		}
		parent::csrf_show_error();
	}
}
