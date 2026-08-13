# Estágios do _Pipeline_
Este diretório agrupa os quatro **registradores de estágio**, usados nos _datapaths_ com _pipeline_ de 5 estágios.

Eles são o que torna o _pipeline_ possível: como cinco instruções diferentes ocupam o circuito ao mesmo tempo, cada etapa precisa de um "congelador" na sua saída. A cada borda de subida do _clock_, o registrador captura os dados e sinais de controle produzidos por um estágio e os mantém estáveis durante todo o ciclo seguinte, enquanto o estágio anterior já trabalha na próxima instrução.

<br>

## Interface
| Registrador | Fronteira | O que atravessa |
| :--- | :---: | :--- |
| [estagioIF_ID](estagioIF_ID/README.md) | _Fetch_ &rarr; _Decode_ | Instrução crua, `PC` e `PC + 4`. |
| [estagioID_EX](estagioID_EX/README.md) | _Decode_ &rarr; _Execute_ | Operandos `ld1`/`ld2`, `imm`, `PC`, `PC + 4`, `rd`, `opcode`, `funct3`, `funct7` e todos os sinais de controle. |
| [estagioEX_MEM](estagioEX_MEM/README.md) | _Execute_ &rarr; _Memory_ | Resultado da ULA, `ld2`, `rd`, `PC + 4`, `funct3` e o controle das fases MEM e WB. |
| [estagioMEM_WB](estagioMEM_WB/README.md) | _Memory_ &rarr; _Write-Back_ | Dado lido da memória, resultado da ULA, `rd`, `PC + 4` e o controle da fase WB. |

<br>

## Funcionamento
O comportamento é idêntico nos quatro, mudando apenas **quantos** e **quais** sinais são transportados:

1. Durante o ciclo, as entradas (`*_<estagioAnterior>`) recebem valores combinacionais do estágio anterior, que podem oscilar livremente.
2. Na **borda de subida do `CLK`**, cada registrador interno grava o valor presente na sua entrada.
3.  A partir daí, as saídas (`*_<estagioSeguinte>`) mantêm esse valor **fixo** pelo ciclo inteiro, dando ao próximo estágio uma entrada estável para trabalhar.

<br>

## Implementação
Cada sinal transportado tem seu **próprio registrador**, com a largura em bits do sinal correspondente: 32 bits para dados, 5 bits para `rd`, 3 bits para `funct3`, 1 bit para os sinais de controle, e assim por diante.

Todos os registradores de um mesmo estágio compartilham:
*   O pino **`CLK`**.
*   O pino **`Clear`**.
*   O pino **`Enable`**.
