# Unidade de Controle da ULA

![Circuito da Unidade de Controle da ULA](ucULA_imagem.png)


A Unidade de Controle da ULA (ucULA) é o componente responsável por utilizar campos específicos da instrução (`funct7` e `funct3`) para identificá-la e assim, definir qual operação a unidade lógica e aritmética (ULA) deve executar através do `ALUControl`.

## Interface

| Pino | Direção | Largura | Descrição |
| --- | --- | --- | --- |
| `funct7` | Entrada | 7 bits | Campo da instrução usado para diferenciar operações que compartilham o mesmo `funct3`, separado no `decodificador`. |
| `funct3` | Entrada | 3 bits | Campo da instrução que atua como o seletor para as operações lógicas e aritméticas, saída do `decodificador`. |
| `ALUOp` | Entrada | 2 bits | Sinal que indica a categoria geral da instrução atual (Memória, desvio ou lógico-aritmética) vindo da `ucPrincipal`. |
| `ALUControl` | Saída | 4 bits | Sinal de controle enviado à ULA para determinar a operação que será executada. |

## Tabela de mapeamento

A tabela abaixo apresenta como a ucULA decodifica suas entradas para gerar o código correto de `ALUControl`. Ela serve como o guia principal para a implementação física ou lógica do componente:

| Categoria da Instrução | ALUOp | funct3 * | funct7 (bit 5 / bit 4) * | ALUControl | Operação na ULA |
| --- | --- | --- | --- | --- | --- |
| **Memória** (`lw`/`sw`) | `00` | `X` | `X` | `2` | Soma (`add`) |
| **Desvio** (`beq`/`bne`) | `01` | `000`/`001` | `X` | `6` | Subtração (`sub`) |
| **Desvio** (`blt`/`bge`) | `01` | `100`/`101` | `X` | `4` | Comparação com sinal (`slt`) |
| **Desvio** (`bltu`/`bgeu`) | `01` | `110`/`111` | `X` | `a` | Comparação sem sinal (`sltu`) |
| **Lógico-aritmética** (`add`) | `10` | `000` | `0`/`X` | `2` | Soma (`add`) |
| **Lógico-aritmética** (`sub`) | `10` | `000` | `1`/`0` | `6` | Subtração (`sub`) |
| **Lógico-aritmética** (`addi`) | `10` | `000` | - | `2` | Soma (`add`) |
| **Lógico-aritmética** (`and`/`andi`) | `10` | `111` | `X` | `0` | AND bit a bit (`and`)|
| **Lógico-aritmética** (`or`/`ori`) | `10` | `110` | `X` | `1` | OR bit a bit (`or`)|
| **Lógico-aritmética** (`xor`/`xori`) | `10` | `100` | `X` | `3` | XOR bit a bit (`xor`) |
| **Lógico-aritmética** (`sll`/`slli`) | `10` | `001` | `X` | `7` | Deslocamento lógico à esquerda (`sll`) |
| **Lógico-aritmética** (`srl`/`srli`) | `10` | `101` | `0`/`X` | `8` | Deslocamento lógico à direita (`srl`) |
| **Lógico-aritmética** (`sra`/`srai`) | `10` | `101` | `1`/`X` | `5` | Deslocamento aritmético à direita (`sra`) |

> X representa que o valor do campo não interfere na saída. * 

## Funcionamento detalhado
O circuito opera utilizando três regras principais baseadas no `ALUOp`, que é gerado dentro da unidade de controle principal:

1. **Operações de memória (`ALUOp = 00`):**
    - Quando o processador executa um carregamento ou armazenamento (`lw` ou `sw`), a ULA precisa calcular o endereço de memória somando a base ao imediato. Portanto, a ucULA ignora os campos `funct` e força a saída `ALUControl` para `2` (operação de soma).


2. **Operações de desvio condicional (`ALUOp = 01`):**
    - Nas instruções de *branch*, a ULA realiza subtrações ou comparações de modo a verificar uma condição a ser utilizada na `ucDesvio`. Assim, a `ucULA` analisa o `funct3` para identificar qual o requisito necessário para realização daquela instrução de desvio específica e assim, mapeia a operação adequada:
        - `beq`/`bne`: requerem uma subtração (`ALUControl = 6`).
        - `blt`/`bge`: requerem comparação em complemento de dois (`ALUControl = 4`).
        - `bltu`/`bgeu`: requerem comparação sem sinal (`ALUControl = a`).

Para descrição mais detalhada, verifique a documentação da unidade de controle de desvio (`ucBranch`).

3. **Operações lógicas e aritméticas (`ALUOp = 10`):**
* Para instruções dos Tipos R e I, o sinal `funct3` seleciona a operação base da ULA através de uma estrutura de multiplexadores. Quando há sobreposição de `funct3` (como em `add`/`sub` ou `srl`/`sra`), bits específicos do campo `funct7` são trazidos para desempatar as operações e então, definir com certeza qual deve ser executada.

<br>

#### Campos funct3 repetidos
Um ponto crítico no desenvolvimento deste componente que exige atenção é a coexistência das instruções `add`, `sub` (Tipo R) e `addi` (Tipo I) sob o mesmo código `ALUOp = 10` e mesmo `funct3 = 000`.

Instruções do Tipo I (como `addi`) **não possuem o campo `funct7`**. No espaço da instrução que pertenceria ao `funct7`, o formato do Tipo I armazena parte do seu imediato. Como os bits 31 a 25 da instrução estão conectados diretamente na entrada `funct7` da `ucULA`, se o programa executar um `addi` com um valor imediato negativo ou específico onde o bit 30 (bit 5 do `funct7`) seja igual a `1`, a ucULA seria enganada. Ela confundiria o imediato do `addi` com o padrão da instrução `sub` (`0100000`), fazendo com que a ULA subtraísse o valor em vez de somá-lo.

##### A solução <p style="color: darkred">(a ser modificada)</p>

Para mitigar esse problema, é possível adicionar uma validação mais estrita da ocorrência da operação `sub` (`0100000`). Em vez de olhar apenas para o bit 5, realiza-se uma operação AND entre o **bit 5** e a **negação do bit 4** do `funct7`.

- Como no `sub` o bit 5 é `1` e o bit 4 é `0`, a saída da porta AND se torna ativa (`1`), selecionando corretamente a subtração.
- Se for um `addi` com um imediato desconhecido que por acaso ative ambos os bits ou mude o padrão, a negação do bit 4 ajuda a filtrar e evitar falsos positivos.

<br>

## Implementação

Para fazer este circuito são utilizados os seguintes blocos combinacionais:

* **Multiplexadores (MUX):** conectados em uma estrutura hierárquica (árvore). Os MUXes iniciais utilizam o `funct3` para agrupar as operações, e o MUX final utiliza o `ALUOp` para decidir se a saída virá do agrupamento lógico-aritmético, de desvios ou se será forçada para soma.
* **Portas lógicas (AND com inversor):** implementam a análise dos bits de diferenciação do `funct7`, liberando o sinal de seleção de subtração e do deslocamento aritmético.
* **Constantes estáticas:** valores fixos em formato hexadecimal colocados diretamente nas entradas dos multiplexadores (como `6`, `7`, `8` e `a`), representando cada operação disponível na ULA do processador.