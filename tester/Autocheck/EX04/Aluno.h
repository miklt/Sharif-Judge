#ifndef ALUNO_H
#define ALUNO_H

#include <string>

class Aluno {
public:
  Aluno (std::string nome, double notaP1, double notaP2,
         double notaP3, int faltas);
  virtual ~Aluno();
  std::string getNome();
  double getNotaP1();
  double getNotaP2();
  double getNotaP3();
  void imprimir();
  int getFaltas();
private:
  std::string nome;
  double notaP1;
  double notaP2;
  double notaP3;
  int faltas;
};

#endif // ALUNO_H
