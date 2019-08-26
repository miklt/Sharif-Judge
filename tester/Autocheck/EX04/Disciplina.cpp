#include "Disciplina.h"
#include "ErroDisciplina.h"
#include <stdexcept>
#include <iostream>
#include <string>

using namespace std;

Disciplina::Disciplina() {
  this->numeroDeAlunos = 0;
}

void Disciplina::adicionarAluno (string nome, double notaP1,
                                 double notaP2,
                                 double notaP3, int faltas) {
  if (nome.empty() ) throw new
    invalid_argument ("Nome vazio");
  else if (notaP1 < 0 || notaP1 > 10 || notaP2 < 0
           || notaP2 > 10 ||
           notaP3 < 0 || notaP3 > 10)
    throw new invalid_argument ("Nota invalida");
  else if (faltas < 0) throw new
    invalid_argument ("Falta negativa");

  this->alunos[numeroDeAlunos++] = new Aluno (nome, notaP1,
      notaP2,
      notaP3, faltas);
}

void Disciplina::imprimir() {
  for (int i = 0; i < numeroDeAlunos; i++) {
    alunos[i]->imprimir();
  }
}

Disciplina::~Disciplina() {
  for (int i = 0; i < numeroDeAlunos; i++) {
    delete this->alunos[i];
  }
}

double Disciplina::mediaDoAluno (Aluno* a) {
  return (a->getNotaP1() + a->getNotaP2() + a->getNotaP3() ) /
         3;
}

double Disciplina::media (int numeroDeFaltasMaximo) {
  if (numeroDeFaltasMaximo < 0)
    throw new ErroDisciplina ("Numero de faltas e' < 0");
  else if (numeroDeAlunos == 0)
    throw new ErroDisciplina ("Nao existem alunos matriculados");

  int alunosPresentes = 0;
  double total = 0;

  for (int i = 0; i < numeroDeAlunos; i++) {
    if (alunos[i]->getFaltas() <= numeroDeFaltasMaximo) {
      alunosPresentes++;
      total += mediaDoAluno (alunos[i]);
    }
  }

  if (alunosPresentes == 0) return 0;

  return total / alunosPresentes;
}
