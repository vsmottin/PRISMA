# Unidade Lógica e Aritmética (ULA)

![Circuito da ULA](ULA_imagem.png)

A Unidade Lógica e Aritmética (`ULA`) é o componente que executa as operações aritméticas e lógicas do processador. A cada ciclo ela recebe dois operandos de 32 bits (`A` e `B`) e um código de controle (`ALUControl`), que seleciona qual operação será realizada, produzindo o resultado em `Result` e a flag `sZero`.

É utilizada para três finalidades principais:
*   **Operações lógico-aritméticas** das instruções Tipo R e Tipo I (`add`, `sub`, `and`, `or`, `xor`, deslocamentos e comparações).
*   **Cálculo de endereço** das instruções de memória (`lw`/`sw`), somando a base ao valor imediato.
*   **Avaliação das condições de desvio** (`beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu`), em conjunto com a flag `sZero` e a unidade de desvio (`ucDesvio`).

<br>

## Interface

| Pino | Direção | Largura | Descrição |
| :--- | :---: | :---: | :--- |
| `A` | Entrada | 32 bits | Primeiro operando (geralmente `rs1`). |
| `B` | Entrada | 32 bits | Segundo operando (`rs2` ou valor imediato). |
| `ALUControl` | Entrada | 4 bits | Código que seleciona a operação executada (ver tabela). |
| `Result` | Saída | 32 bits | Resultado da operação selecionada. |
| `sZero` | Saída | 1 bit | Sinalizador de resultado nulo (`1` quando `Result == 0`). |

O sinal `ALUControl` é gerado pelo controlador `ucULA`, a partir do `ALUOp` (vindo da unidade de controle principal) e dos campos `funct3`/`funct7` da instrução.

<br>

## Tabela de operações (`ALUControl`)

| Hex | Binário | Operação | Instruções |
| :---: | :---: | :--- | :--- |
| `0` | `0000` | AND lógico | `and`, `andi` |
| `1` | `0001` | OR lógico | `or`, `ori` |
| `2` | `0010` | Soma (`A + B`) | `add`, `addi`, e endereço de `lw`/`sw` |
| `3` | `0011` | XOR lógico | `xor`, `xori` |
| `4` | `0100` | Menor-que com sinal | `slt`, `slti`, `blt`, `bge` |
| `5` | `0101` | Deslocamento à direita aritmético | `sra`, `srai` |
| `6` | `0110` | Subtração (`A - B`) | `sub`, e `beq`/`bne` (via `sZero`) |
| `7` | `0111` | Deslocamento à esquerda | `sll`, `slli` |
| `8` | `1000` | Deslocamento à direita lógico | `srl`, `srli` |
| `a` | `1010` | Menor-que sem sinal | `sltu`, `sltiu`, `bltu`, `bgeu` |

<br>

## Funcionamento

A ULA é **puramente combinacional**: ela calcula **todas** as operações em paralelo e, no final, um **multiplexador** escolhe qual resultado sai em `Result`, usando o `ALUControl` como seletor.

### 1. Apoio aos desvios (*branches*)
A ULA não decide o desvio sozinha, mas fornece as comparações que a `ucDesvio` usa:
*   `beq`/`bne` usam a **subtração** (`0110`): se `A - B == 0`, então `A == B`, e a flag `sZero` sinaliza a igualdade.
*   `blt`/`bge` usam o **menor-que com sinal** (`0100`).
*   `bltu`/`bgeu` usam o **menor-que sem sinal** (`1010`).

<br>

## Implementação

Internamente, cada operação possui um bloco dedicado, e a saída de todos eles converge para o multiplexador final:

*   **Somador (`Adder`)** — calcula `A + B` (código `2` / `0010`).
*   **Subtrator (`Subtractor`)** — calcula `A - B` (código `6` / `0110`).
*   **Portas lógicas** — `AND` (`0` / `0000`), `OR` (`1` / `0001`) e `XOR` (`3` / `0011`), bit a bit.
*   **Deslocadores (`Shifter`)** — três unidades: à esquerda (`7` / `0111`), à direita lógica (`8` / `1000`) e à direita aritmética (`5` / `0101`).
*   **Comparadores (`Comparator`)** — geram os resultados de menor-que com sinal (`4` / `0100`) e sem sinal (`a` / `1010`). Cada comparador passa por um **extensor de sinal**, que transforma o resultado de 1 bit em 32 bits antes de entrar no mux.

A flag **`sZero`** é produzida pelo subcomponente **`zero`**, que verifica se todos os 32 bits do `Result` estão em nível baixo. É justamente isso que permite às instruções `beq`/`bne` decidirem a igualdade a partir da subtração.

> [!NOTE]
> O circuito possui **4 comparadores** fisicamente ligados ao mux, nos códigos `0100`, `1001`, `1010` e `1011`. Porém, o controlador `ucULA` **só gera** os códigos `0100` (`slt`) e `1010` (`sltu`) — ele **nunca** emite `1001` nem `1011`. Por isso, os comparadores ligados a esses dois códigos aparecem com o rótulo **"Não usada"**: eles funcionam, mas o controle nunca os seleciona, de modo que não têm efeito prático no `Result`.
