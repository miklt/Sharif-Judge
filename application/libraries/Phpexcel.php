<?php
defined('BASEPATH') OR exit('No direct script access allowed');
require_once LABOO_VENDOR_AUTOLOAD;

/**
 * Mesmo comportamento do PHPExcel legado (números viram números, para somas
 * e ordenação no Excel), exceto texto iniciado por "=", gravado como texto
 * para não virar fórmula (nomes e campos preenchidos por alunos).
 */
class LabooValueBinder extends \PhpOffice\PhpSpreadsheet\Cell\DefaultValueBinder {
    public function bindValue(\PhpOffice\PhpSpreadsheet\Cell\Cell $cell, mixed $value): bool {
        if (is_string($value) && strlen($value) > 1 && $value[0] === '=') {
            $cell->setValueExplicit($value, \PhpOffice\PhpSpreadsheet\Cell\DataType::TYPE_STRING);
            return true;
        }
        return parent::bindValue($cell, $value);
    }
}

class Phpexcel extends \PhpOffice\PhpSpreadsheet\Spreadsheet {
    public function __construct() {
        parent::__construct();
        $this->setValueBinder(new LabooValueBinder());
    }
}
