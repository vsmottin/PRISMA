# Unidade de Controle da ULA

![Circuito da Unidade de Controle da ULA](ucULA_imagem.png)

A Unidade de Controle da ULA (`ucULA`) é o componente encarregado de determinar a operação exata que a Unidade Lógica e Aritmética (ULA) deve executar. Para isso, ela decodifica e combina o sinal de controle geral `ALUOp` (fornecido pela unidade de controle principal) com os campos `opcode`, `funct3` e `funct7` da instrução.

Depois da reorganização da ULA em **ordem de `funct3`**, o trabalho da `ucULA` ficou mais simples: para as instruções lógico-aritméticas ela apenas **repassa o `funct3`** como `ALUControl`. Em compensação, ela passou a produzir **três saídas** em vez de uma — além do `ALUControl` de 3 bits, gera os dois bits de desempate que a ULA usa nos grupos ambíguos: `subSeletor` (`add`/`sub`) e `sraiSeletor` (`srl`/`sra`).

<br>

## Interface

| Pino | Direção | Largura | Descrição |
| :--- | :---: | :---: | :--- |
| `opcode` | Entrada | 7 bits | Código de operação da instrução, usado para distinguir o formato Tipo R do Tipo I. |
| `funct7` | Entrada | 7 bits | Campo da instrução usado para diferenciar variações de operações com o mesmo `funct3`. |
| `funct3` | Entrada | 3 bits | Campo da instrução que atua como seletor primário da operação. |
| `ALUOp` | Entrada | 2 bits | Categoria geral da instrução (`00` para memória, `01` para desvios, `10` para lógico-aritméticas). |
| `ALUControl` | Saída | 3 bits | Código de seleção enviado à ULA, na mesma codificação do `funct3`. |
| `subSeletor` | Saída | 1 bit | Escolhe subtração em vez de soma dentro do grupo `ALUControl = 000`. |
| `sraiSeletor` | Saída | 1 bit | Escolhe deslocamento aritmético em vez de lógico dentro do grupo `ALUControl = 101`. |

<br>

## Tabela de mapeamento de operações

A tabela a seguir orienta como a `ucULA` decodifica suas entradas para gerar os sinais de saída:

| Categoria da Instrução | ALUOp | funct3 | opcode (bit 5) | funct7 (bit 5) | ALUControl | subSeletor | sraiSeletor | Operação da ULA |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| **Memória** (`lw`/`sw`) | `00` | `X` | `X` | `X` | `000` | `0` | `X` | Soma (`add`) |
| **Desvio** (`beq`/`bne`) | `01` | `000` / `001` | `X` | `X` | `000` | `1` | `X` | Subtração (`sub`) |
| **Desvio** (`blt`/`bge`) | `01` | `100` / `101` | `X` | `X` | `010` | `X` | `X` | Comparação com sinal (`slt`) |
| **Desvio** (`bltu`/`bgeu`) | `01` | `110` / `111` | `X` | `X` | `011` | `X` | `X` | Comparação sem sinal (`sltu`) |
| **Lógico-aritmética** (`add`/`addi`) | `10` | `000` | `X` | `0` | `000` | `0` | `X` | Soma (`add`) |
| **Lógico-aritmética** (`sub`) | `10` | `000` | `1` (Tipo R) | `1` | `000` | `1` | `X` | Subtração (`sub`) |
| **Lógico-aritmética** (`sll`/`slli`) | `10` | `001` | `X` | `X` | `001` | `X` | `X` | Deslocamento à esquerda (`sll`) |
| **Lógico-aritmética** (`slt`/`slti`) | `10` | `010` | `X` | `X` | `010` | `X` | `X` | Menor-que com sinal (`slt`) |
| **Lógico-aritmética** (`sltu`/`sltiu`) | `10` | `011` | `X` | `X` | `011` | `X` | `X` | Menor-que sem sinal (`sltu`) |
| **Lógico-aritmética** (`xor`/`xori`) | `10` | `100` | `X` | `X` | `100` | `X` | `X` | XOR bit a bit (`xor`) |
| **Lógico-aritmética** (`srl`/`srli`) | `10` | `101` | `X` | `0` | `101` | `X` | `0` | Deslocamento lógico à direita (`srl`) |
| **Lógico-aritmética** (`sra`/`srai`) | `10` | `101` | `X` | `1` | `101` | `X` | `1` | Deslocamento aritmético à direita (`sra`) |
| **Lógico-aritmética** (`or`/`ori`) | `10` | `110` | `X` | `X` | `110` | `X` | `X` | OR bit a bit (`or`) |
| **Lógico-aritmética** (`and`/`andi`) | `10` | `111` | `X` | `X` | `111` | `X` | `X` | AND bit a bit (`and`) |

> `X` indica que o valor do bit correspondente não interfere no resultado daquela instrução. O **bit 5 do `opcode`** vale `1` em instruções Tipo R e `0` em instruções Tipo I, sendo a chave para separar `sub` de `addi`.

<br>

## Funcionamento

### 1. A saída `ALUControl`

Um multiplexador final de 4 entradas, tendo o `ALUOp` como seletor, escolhe entre três fontes:

| `ALUOp` | Categoria | Fonte do `ALUControl` |
| :---: | :--- | :--- |
| `00` | `lw` / `sw` (e demais instruções sem uso aritmético do `funct3`) | Constante `000` — a ULA soma base + imediato. |
| `01` | Desvios condicionais (Tipo B) | Árvore de decodificação dos desvios (abaixo). |
| `10` | Tipo R / Tipo I | O **`funct3` da instrução**, repassado diretamente. |
| `11` | — | Entrada não utilizada; a `ucPrincipal` nunca emite este valor. |

Para `ALUOp = 10` não há decodificação nenhuma: como o multiplexador da ULA está em ordem de `funct3`, o campo vai direto para a saída. Toda a diferenciação fina (`add`/`sub`, `srl`/`sra`) migrou para os dois seletores auxiliares.

<br>

### 2. A árvore de desvios (`ALUOp = 01`)

Os desvios ainda precisam ser traduzidos, porque o `funct3` de um `beq` (`000`) não coincide com a operação que a ULA deve fazer. Dois multiplexadores em cascata, controlados por bits isolados do `funct3`, resolvem os três casos:

*   **`funct3[2] = 0`** → `beq` / `bne` → `ALUControl = 000` (soma/subtração, com `subSeletor` forçado em `1`).
*   **`funct3[2] = 1` e `funct3[1] = 0`** → `blt` / `bge` → `ALUControl = 010` (menor-que com sinal).
*   **`funct3[2] = 1` e `funct3[1] = 1`** → `bltu` / `bgeu` → `ALUControl = 011` (menor-que sem sinal).

O bit `funct3[0]`, que distingue a forma "igual/diferente" de cada par (`beq` × `bne`, `blt` × `bge`, …), não é usado aqui: essa decisão pertence à [`ucDesvio`](../ucDesvio/README.md), que interpreta a flag `sZero` produzida pela ULA.

<br>

### 3. A saída `sraiSeletor`

É o **bit 5 do `funct7`** (bit 30 da instrução), ligado diretamente à saída. Ele só tem efeito quando `ALUControl = 101`, e nesse caso vale `0` para `srl`/`srli` (`funct7 = 0000000`) e `1` para `sra`/`srai` (`funct7 = 0100000`). Como `srli` e `srai` são Tipo I, o campo corresponde a `imm[11:5]` — mas o RISC-V reserva justamente esse bit para diferenciar os dois deslocamentos, então a leitura direta é segura.

<br>

### 4. A saída `subSeletor` e a diferenciação entre `addi` e `sub`

A saída é formada por uma porta OR entre dois termos:

```
subSeletor = (ALUOp[1] AND opcode[5] AND funct7[5])  OR  (ALUOp == 01)
```

*   O **segundo termo** força a subtração em todos os desvios, para que `beq`/`bne` obtenham `A - B` e possam usar a flag `sZero`. Para `blt`/`bltu` ele é inócuo, porque nesses casos o `ALUControl` seleciona um comparador e não o grupo `000`.
*   O **primeiro termo** é o que identifica um `sub` verdadeiro. Um ponto crítico do circuito é a coexistência de `addi` (Tipo I) e `sub` (Tipo R): ambas compartilham `ALUOp = 10` e `funct3 = 000`.
    - **As instruções do Tipo I não possuem o campo `funct7`**. O espaço da instrução correspondente ao `funct7` é preenchido pelo valor imediato.
    - Se o processador executa um `addi` com um imediato que possui o bit 30 (bit 5 do `funct7`) em nível alto (`1`), o circuito poderia interpretar erroneamente a operação como uma subtração (`sub`).

Para distinguir as duas instruções com segurança, o circuito recorre ao `opcode`, que é o único campo capaz de identificar o tipo da instrução de forma confiável:

- O bit 5 do `opcode` vale `1` para instruções Tipo R (`opcode = 0110011`, como o `sub`) e `0` para instruções Tipo I (`opcode = 0010011`, como o `addi`).
- O bit 5 do `funct7` (bit 30 da instrução) vale `1` no `sub` e `0` no `add`.

**Por que usar ambos?** Mesmo que um `addi` carregue um imediato cujo bit 30 esteja em `1` (o que ativaria `funct7[5]`), o `addi` é Tipo I e portanto tem `opcode[5] = 0`. Com um dos operandos do AND zerado, a condição de subtração nunca é satisfeita por engano, e a ULA permanece em soma. A condição só é verdadeira para uma instrução `sub` confirmada, que é simultaneamente Tipo R (`opcode[5] = 1`) e possui `funct7[5] = 1`.

**E por que o `ALUOp[1]`?** O par `opcode[5]` + `funct7[5]` sozinho não basta. Existem instruções que também têm `opcode[5] = 1`, mas que usam a ULA com `ALUOp = 00`, e nelas o campo `funct7` não é um código de operação — é apenas um pedaço do imediato:

| Instrução | `opcode` | Bit 30 valeria `1` quando… | O que aconteceria sem o `ALUOp[1]` |
| :--- | :---: | :--- | :--- |
| `sw`/`sh`/`sb` | `0100011` | o deslocamento é negativo ou tem `imm[10] = 1` | endereço calculado como `rs1 - imm` |
| `jalr` | `1100111` | o deslocamento é negativo ou tem `imm[10] = 1` | alvo calculado como `rs1 - imm` |
| `lui` | `0110111` | o imediato tem o bit 30 em `1` | resultado sairia negado |

Como o `ALUOp[1]` só vale `1` nas instruções lógico-aritméticas (`ALUOp = 10`), ele restringe o termo exatamente ao contexto em que `funct7` de fato carrega um código de operação. As instruções de *load* nunca dependeram dessa proteção (`opcode = 0000011`, `opcode[5] = 0`).

<br>

## Implementação

A `ucULA` é construída de forma puramente combinacional por meio dos seguintes blocos:

- **Distribuidores (*splitters*):** fatiam o `funct3` (para a árvore de desvios), o `opcode` e o `funct7` (para extrair o bit 5 de cada um) e o `ALUOp` (para o detector de desvio).
- **Multiplexadores:** dois em cascata para decodificar os desvios e um final de 4 entradas, selecionado pelo `ALUOp`, que define o `ALUControl`.
- **Portas Lógicas:** um `AND` de três entradas que combina o **bit 1 do `ALUOp`**, o **bit 5 do `opcode`** e o **bit 5 do `funct7`** (detecção do `sub` real), um `AND` de duas entradas com a primeira negada que detecta `ALUOp = 01`, e um `OR` que reúne os dois termos no `subSeletor`.
- **Constantes:** os valores `000` (memória e `beq`/`bne`), `010` (`blt`/`bge`) e `011` (`bltu`/`bgeu`), de 3 bits, alimentando as entradas dos multiplexadores.
