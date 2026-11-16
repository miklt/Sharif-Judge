<?php
defined('BASEPATH') OR exit('No direct script access allowed');
require_once LABOO_VENDOR_AUTOLOAD;
class Phpexcel extends \PhpOffice\PhpSpreadsheet\Spreadsheet {
    public function __construct() {
        parent::__construct();
        $this->setValueBinder((new \PhpOffice\PhpSpreadsheet\Cell\StringValueBinder())->setFormulaConversion(true));
    }
}
