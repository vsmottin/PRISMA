# Estágios do _Pipeline_
Este diretório agrupa os quatro **registradores de estágio**, usados nos _datapaths_ com _pipeline_ de 5 estágios.

Eles são o que torna o _pipeline_ possível: como cinco instruções diferentes ocupam o circuito ao mesmo tempo, cada etapa precisa de um "congelador" na sua saída. A cada borda de **descida** do _clock_, o registrador captura os dados e sinais de controle produzidos por um estágio e os mantém estáveis durante todo o ciclo seguinte, enquanto o estágio anterior já trabalha na próxima instrução.

<br>

## Interface
| Registrador | Fronteira | O que atravessa |
| :--- | :---: | :--- |
| [estagioIF_ID](estagioIF_ID/README.md) | _Fetch_ &rarr; _Decode_ | Instrução crua, `PC` e `PC + 4`. |
| [estagioID_EX](estagioID_EX/README.md) | _Decode_ &rarr; _Execute_ | Instrução, operandos `ld1`/`ld2`, `imm`, `PC`, `PC + 4`, `rd`, `rs1`, `rs2`, `opcode`, `funct3`, `funct7` e todos os sinais de controle. |
| [estagioEX_MEM](estagioEX_MEM/README.md) | _Execute_ &rarr; _Memory_ | Instrução, resultado da ULA, `ld2`, `rd`, `PC + 4`, `funct3` e o controle das fases MEM e WB. |
| [estagioMEM_WB](estagioMEM_WB/README.md) | _Memory_ &rarr; _Write-Back_ | Instrução, dado lido da memória, resultado da ULA, `rd`, `PC + 4` e o controle da fase WB. |

<br>

## Funcionamento
O comportamento é idêntico nos quatro, mudando apenas **quantos** e **quais** sinais são transportados:

1. Durante o ciclo, as entradas (`*_<estagioAnterior>`) recebem valores combinacionais do estágio anterior, que podem oscilar livremente.
2. Na **borda de descida do `CLK`**, cada registrador interno grava o valor presente na sua entrada.
3.  A partir daí, as saídas (`*_<estagioSeguinte>`) mantêm esse valor **fixo** pelo ciclo inteiro, dando ao próximo estágio uma entrada estável para trabalhar.

> [!IMPORTANT]
> A borda de descida é **inversa** à do [banco de registradores](../bancoRegistradores/) e da [memória de dados](../memDados/), que gravam na subida. Assim, a escrita no banco acontece no **meio** do ciclo definido pelos registradores de estágio: como no livro de Patterson e Hennessy, o registrador é escrito na primeira metade do ciclo e lido na segunda. Uma instrução no WB e outra no ID, no mesmo ciclo, já enxergam o valor novo. Veja [Bordas de _clock_](../../datapaths/pipeline/README.md#bordas-de-clock).

Além dos sinais consumidos pelo _datapath_, os quatro registradores carregam a **instrução** de 32 bits (`Instrucao_<estagioAnterior>` &rarr; `Instrucao_<estagioSeguinte>`). Nenhum componente a consome depois do ID: ela existe para que se saiba, a cada ciclo, qual instrução ocupa cada estágio do _pipeline_.

<br>

## Implementação
Cada sinal transportado tem seu **próprio registrador**, com a largura em bits do sinal correspondente: 32 bits para dados, 5 bits para `rd`, `rs1` e `rs2`, 3 bits para `funct3`, 1 bit para os sinais de controle, e assim por diante.

Todos os registradores de um mesmo estágio compartilham:
*   O pino **`CLK`**.
*   O pino **`Clear`**.
*   O pino **`Enable`**.
