#ifndef DISCIPLINA_H
#define DISCIPLINA_H

#include "Aluno.h"
#include <string>

#define NUMERO_MAXIMO 5
class Disciplina {
public:
  Disciplina();
  void adicionarAluno (std::string nome, double notaP1,
                       double notaP2, double notaP3,
                       int faltas);
  void imprimir();
  virtual ~Disciplina();
  double media (int numeroDeFaltasMaximo);
protected:
  double mediaDoAluno (Aluno *a);
private:
  int numeroDeAlunos;
  Aluno* alunos[NUMERO_MAXIMO];
};

#endif // DISCIPLINA_H
