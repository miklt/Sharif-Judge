<?php
defined('BASEPATH') OR exit('No direct script access allowed');

/** ZIP de exercícios do professor. Mantém a API usada por Assignments. */
class Unzip
{
    private ?array $extensions = null;
    private array $errors = [];

    public function allow($extensions = null): void
    {
        $this->extensions = $extensions === null ? null : array_map('strtolower', (array)$extensions);
    }

    public function errors_array(): array { return $this->errors; }
    public function error_string($open = '<p>', $close = '</p>'): string
    {
        return implode('', array_map(static fn($e) => $open.htmlspecialchars($e, ENT_QUOTES|ENT_SUBSTITUTE, 'UTF-8').$close, $this->errors));
    }

    public function extract($source, $target = null, $preserve_filepath = true)
    {
        $this->errors = [];
        $zip = new ZipArchive();
        if ($zip->open($source, ZipArchive::RDONLY) !== true) {
            $this->errors[] = 'Arquivo ZIP inválido.'; return false;
        }
        try {
            $base = realpath($target ?? dirname($source));
            if ($base === false || !is_dir($base) || $zip->numFiles > 4096) {
                throw new RuntimeException('Destino ou quantidade de arquivos inválidos.');
            }
            $entries = []; $total = 0;
            for ($i=0; $i<$zip->numFiles; $i++) {
                $stat = $zip->statIndex($i);
                if ($stat === false) { throw new RuntimeException('Entrada ZIP inválida.'); }
                $name = str_replace('\\', '/', $stat['name']);
                if ($name === '' || str_contains($name, "\0") || str_starts_with($name, '/')
                    || preg_match('/^[A-Za-z]:/', $name) || in_array('..', explode('/', $name), true)) {
                    throw new RuntimeException('Caminho inseguro no ZIP.');
                }
                $zip->getExternalAttributesIndex($i, $opsys, $attributes);
                if ((($attributes >> 16) & 0170000) === 0120000) {
                    throw new RuntimeException('Links não são permitidos no ZIP.');
                }
                if (str_ends_with($name, '/') || in_array('__MACOSX', explode('/', $name), true)
                    || str_starts_with(basename($name), '.')) { continue; }
                $extension = strtolower(pathinfo($name, PATHINFO_EXTENSION));
                if ($this->extensions !== null && !in_array($extension, $this->extensions, true)) { continue; }
                $relative = $preserve_filepath ? $name : basename($name);
                $total += $stat['size'];
                if ($total > 256*1024*1024 || isset($entries[$relative])) {
                    throw new RuntimeException('ZIP excede o limite ou contém nomes duplicados.');
                }
                $entries[$relative] = [$stat['name'], $stat['size']];
            }
            $paths = [];
            foreach ($entries as $relative => [$name, $size]) {
                $path = $base.'/'.$relative;
                $directory = dirname($path);
                if (!is_dir($directory) && !mkdir($directory, 0700, true)) {
                    throw new RuntimeException('Falha criando diretório de destino.');
                }
                $resolved = realpath($directory);
                if ($resolved !== $base && !str_starts_with($resolved.'/', $base.'/')) {
                    throw new RuntimeException('Destino fora do diretório permitido.');
                }
                $input = $zip->getStream($name);
                $output = fopen($path, 'xb');
                if ($input === false || $output === false) { throw new RuntimeException('Falha abrindo arquivo do ZIP.'); }
                $copied = stream_copy_to_stream($input, $output, $size+1);
                fclose($input); fclose($output); chmod($path, 0600);
                if ($copied !== $size) { throw new RuntimeException('Conteúdo ZIP incompleto ou inválido.'); }
                $paths[] = $path;
            }
            return $paths;
        } catch (Throwable $e) {
            $this->errors[] = $e->getMessage(); return false;
        } finally {
            $zip->close();
        }
    }
}
