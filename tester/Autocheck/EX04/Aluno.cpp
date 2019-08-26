#include "Aluno.h"
#include <string>
#include <iostream>
#include <stdexcept>

using namespace std;

Aluno::Aluno (string nome, double notaP1, double notaP2,
              double notaP3, int faltas) {
  if (nome.empty() ) throw new
    invalid_argument ("Nome vazio");
  else if (notaP1 < 0 || notaP1 > 10 || notaP2 < 0
           || notaP2 > 10 ||
           notaP3 < 0 || notaP3 > 10)
    throw new invalid_argument ("Nota invalida");
  else if (faltas < 0) throw new
    invalid_argument ("Falta negativa");

  this->nome = nome;
  this->notaP1 = notaP1;
  this->notaP2 = notaP2;
  this->notaP3 = notaP3;
  this->faltas = faltas;
}

Aluno::~Aluno() {
  //dtor
}

double Aluno::getNotaP3() {
  return notaP3;
}

double Aluno::getNotaP2() {
  return notaP2;
}

double Aluno::getNotaP1() {
  return notaP1;
}

string Aluno::getNome() {
  return nome;
}

int Aluno::getFaltas() {
  return faltas;
}

void Aluno::imprimir() {
  cout << nome << " P1: " << notaP1 << " P2: " << notaP2 <<
       " P3: " << notaP3 << " faltas: " << faltas << endl;
}


