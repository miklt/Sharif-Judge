#include "ErroDisciplina.h"


ErroDisciplina::ErroDisciplina ( const std::string &mensagem) :
    std::runtime_error (mensagem) {}
