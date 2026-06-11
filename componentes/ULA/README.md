# ULA — Unidade Lógica e Aritmética

A ULA é o componente que executa as operações aritméticas e lógicas do
processador. A cada ciclo ela recebe dois operandos de 32 bits (`A` e `B`) e um
código de controle (`ALUControl`) que seleciona qual operação será feita,
produzindo o resultado em `Result` e a flag `sZero`.

É usada para:
- Operações aritméticas/lógicas das instruções tipo R e tipo I (`add`, `sub`,
  `and`, `or`, `xor`, shifts, comparações...).
- Cálculo de endereço de `lw`/`sw` (`base + imediato`, via soma).
- Avaliação das condições de desvio (`beq`, `bne`, `blt`, `bge`, `bltu`,
  `bgeu`), em conjunto com a `sZero` e a unidade de desvio (`ucDesvio`).

## Interface

| Pino | Direção | Largura | Descrição |
|------|---------|---------|-----------|
| `A` | entrada | 32 bits | Primeiro operando (geralmente `rs1`). |
| `B` | entrada | 32 bits | Segundo operando (`rs2` ou imediato). |
| `ALUControl` | entrada | 4 bits | Código que seleciona a operação (ver tabela). |
| `Result` | saída | 32 bits | Resultado da operação selecionada. |
| `sZero` | saída | 1 bit | Vale `1` quando `Result == 0` (usado em `beq`/`bne`). |

O sinal `ALUControl` é gerado pelo controlador `ucULA`, a partir do `ALUOp`
(da UC principal) e dos campos `funct3`/`funct7` da instrução.

## Tabela `ALUControl` → operação

| ALUControl | Operação | Instruções |
|:---------:|----------|------------|
| `0000` | AND lógico | `and`, `andi` |
| `0001` | OR lógico | `or`, `ori` |
| `0010` | Soma (`A + B`) | `add`, `addi`, e endereço de `lw`/`sw` |
| `0011` | XOR lógico | `xor`, `xori` |
| `0100` | Menor que (com sinal) | `slt`, `slti`, `blt`, `bge` |
| `0101` | Deslocamento à direita aritmético | `sra`, `srai` |
| `0110` | Subtração (`A - B`) | `sub`, e `beq`/`bne` (via `sZero`) |
| `0111` | Deslocamento à esquerda | `sll`, `slli` |
| `1000` | Deslocamento à direita lógico | `srl`, `srli` |
| `1010` | Menor que (sem sinal) | `sltu`, `sltiu`, `bltu`, `bgeu` |

> Observações sobre desvios:
> - `beq`/`bne` usam a subtração (`0110`): se `A - B == 0`, então `A == B`, e a
>   flag `sZero` indica isso.
> - `blt`/`bge` usam o menor-que com sinal (`0100`).
> - `bltu`/`bgeu` usam o menor-que sem sinal (`1010`).

## Implementação

Internamente a ULA não é uma única unidade configurável: ela calcula todas as
operações em paralelo, com blocos dedicados, e no final um multiplexador escolhe
qual resultado sai em `Result`, usando o `ALUControl` como seletor.

Blocos usados:
- Somador (`Adder`) — soma `A + B` (índice `0010` do mux).
- Subtrator (`Subtractor`) — subtração `A - B` (índice `0110`).
- Portas lógicas — `AND` (`0000`), `OR` (`0001`) e `XOR` (`0011`), bit a bit.
- Deslocadores (`Shifter`) — três unidades: esquerda (`0111`), direita lógica
  (`1000`) e direita aritmética (`0101`).
- Comparadores (`Comparator`) — são 4, cada um com seu extensor de sinal, e
  todos ligados ao mux. A saída de comparação (1 bit) é estendida para 32 bits
  antes de entrar no mux, nos seguintes índices:
  - `0100` → menor-que com sinal (`slt`).
  - `1010` → menor-que sem sinal (`sltu`).
  - `1001` e `1011` → comparações extras (ex.: maior-que).

> Atenção: os 4 comparadores estão fisicamente conectados ao mux, mas o
> controlador `ucULA` só gera os códigos `0100` (slt) e `1010` (sltu) — ele
> nunca emite `1001` nem `1011`. Por isso esses dois comparadores aparecem
> com o rótulo "Não usada": funcionam, mas o controle nunca os seleciona, então
> não têm efeito prático no `Result`.

A flag `sZero` é produzida pelo subcomponente `zero`, que verifica se todos os
32 bits do `Result` são `0`.
