<?php
defined('BASEPATH') OR exit('No direct script access allowed');
$instance = getenv('LABOO_INSTANCE');
if (!in_array($instance, ['aula','ep','monitoria','piloto','teste'], true)) {
    throw new RuntimeException('Instância LABOO não configurada.');
}
$private = getenv('LABOO_PRIVATE_DIR') ?: '/run/laboo-private';
require $private.'/instances/'.$instance.'/database.php';
