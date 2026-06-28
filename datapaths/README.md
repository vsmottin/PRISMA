# Datapaths

Este diretório contém as implementações de diferentes arquiteturas de caminho de dados (_datapaths_) para o processador RISC-V.

Estrutura atual:
- **[`monociclo/`](monociclo/)**: Implementação clássica de ciclo único, onde cada instrução executa inteiramente em um ciclo de _clock_.
- **[`pipeline/`](pipeline/)**: Implementação otimizada que divide a execução em múltiplos estágios simultâneos, visando maior vazão de instruções.