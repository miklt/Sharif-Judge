<?php
defined('BASEPATH') OR exit('No direct script access allowed');

/*
| -------------------------------------------------------------------
| E-mail (LABOO)
| -------------------------------------------------------------------
| As credenciais SMTP ficam fora do código, em LABOO_PRIVATE_DIR/mail.php,
| que retorna o array de configuração da biblioteca Email do CodeIgniter.
| Sem esse arquivo, vale o padrão do CodeIgniter (mail() do PHP).
| O initialize() chamado pelo User_model só sobrescreve mailtype/charset.
*/
$config = array();
$laboo_private_dir = getenv('LABOO_PRIVATE_DIR');
if ($laboo_private_dir && is_readable($laboo_private_dir.'/mail.php'))
{
	$laboo_mail = include $laboo_private_dir.'/mail.php';
	if (is_array($laboo_mail))
	{
		$config = $laboo_mail;
	}
}
unset($laboo_private_dir, $laboo_mail);
