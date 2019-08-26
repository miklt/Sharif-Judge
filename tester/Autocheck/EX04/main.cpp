#include <iostream>
#include <stdexcept>
#include "Disciplina.h"
#include "Aluno.h"
#include "ErroDisciplina.h"

using namespace std;

int main() {
  try {
    Disciplina *d = new Disciplina();
    d->adicionarAluno ("Ana", 10, 10, 10, 2);
    d->adicionarAluno ("Joao", 5, 5, 5, 3);

    cout << d->media (3);
  } catch (invalid_argument *e) {
    cout << "Erro: " << e->what();
    delete e;
  } catch (ErroDisciplina *e) {
    cout << "Erro: " << e->what();
    delete e;
  }

  return 0;
}
