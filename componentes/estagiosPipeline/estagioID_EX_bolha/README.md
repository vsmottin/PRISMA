# Registrador de Estágio ID/EX com Bolha

O **estagioID_EX_bolha** é o registrador da fronteira entre a Decodificação (ID) e a Execução (EX) usado no [`pipelineEncaminhamentoBolhas`](../../../datapaths/pipelineEncaminhamentoBolhas/). Ele junta os dois registradores ID/EX que já existiam:

- do [`ID_EX_stage_bubble`](../ID_EX_stage_bubble/ID_EX_stage_bubble.circ) (usado no [`pipeline_bubble`](../../../datapaths/pipeline_bubble/)), a entrada **`Clear`**, que insere uma bolha;
- do [`estagioID_EX`](../estagioID_EX/) (usado no [`pipelineEncaminhamento`](../../../datapaths/pipelineEncaminhamento/)), as saídas **`rs1_EX`** e **`rs2_EX`**, de que a [Unidade de Encaminhamento](../../pipelineComponentes/ucEncaminhamento/) precisa no EX, e a instrução crua (`Instrucao_ID` &rarr; `Instrucao_EX`).

Os pinos que já existiam continuam na mesma posição do `ID_EX_stage_bubble`; os novos ficam na parte de baixo, na mesma posição do `estagioID_EX`.

<br>

## Interface
Além das entradas `*_ID` e saídas `*_EX` comuns aos registradores ID/EX (`PC`, `PC + 4`, controles, `ld1`, `ld2`, `opcode`, `rd`, `funct3`, `funct7` e `imm`):

| Pino | Direção | Largura | Descrição |
| :--- | :---: | :---: | :--- |
| `CLK` | Entrada | 1 bit | _Clock_; grava na borda de **descida**. |
| `Enable` | Entrada | 1 bit | Habilita a gravação (ligado à constante `1` no _datapath_). |
| `Clear` | Entrada | 1 bit | Bolha: com `1`, grava valores neutros no lugar dos recebidos (ligado a `Bubble_ID`). |
| `rs1_ID` / `rs1_EX` | Entrada / Saída | 5 bits | Número do primeiro registrador lido. |
| `rs2_ID` / `rs2_EX` | Entrada / Saída | 5 bits | Número do segundo registrador lido. |
| `Instrucao_ID` / `Instrucao_EX` | Entrada / Saída | 32 bits | Instrução crua, só para identificar o que está no EX. |

<br>

## Funcionamento
Com `Clear = 0`, ele se comporta como qualquer registrador de estágio. Com `Clear = 1`, grava uma **bolha**: todos os controles vão a `0` (nenhuma escrita no banco ou na memória, nenhum `jalr`), `opcode` vai a `0x13` (`addi`), a instrução vai a `0x00000013` (`nop`) e os demais campos (`PC`, `ld1`, `ld2`, `imm`, `rd`, `rs1`, `rs2`, `funct3`, `funct7`) vão a `0`. É o mesmo efeito do livro, que zera os sinais de controle do `ID/EX` com um multiplexador (seção 4.7).

Zerar `rs1` e `rs2` na bolha faz a unidade de encaminhamento nunca selecionar nada para ela.

<br>

## Implementação
É uma cópia do `ID_EX_stage_bubble` com três registradores a mais (`rs1`, `rs2` e `Instrucao`), montados como os outros: um **Multiplexador** de 2 entradas escolhe entre o valor recebido e uma **Constante** (`0` ou `0x13`), comandado por `Clear`, e um **Registrador** com borda de descida guarda o resultado. Todos compartilham os túneis `CLK`, `Enable` e `Clear`.
