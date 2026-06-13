# Unidade de Controle de Desvio

![Circuito da Unidade de Controle de Desvio](ucDesvio_imagem.png)

A unidade de controle de desvio é responsável por decidir se uma instrução de desvio condicional (_branch_) deve ou não ser tomada, alterando o fluxo usual do programa. Ela recebe o campo `funct3` para identificar as instruções e a flag `Zero` gerada pela ULA, tendo como saída `BranchSrc`.

É usada para analisar as seguintes instruções:

- `beq`: desvia se `rs1` for igual a `rs2`.
- `bne`: desvia se `rs1` for diferente de `rs2`.
- `blt`: desvia se `rs1` for menor que `rs2`.
- `bltu`: desvia se `rs1` for menor que `rs2` (_unsigned_, sem sinal).
- `bge`: desvia se `rs1` for maior ou igual a `rs2`.
- `bgeu`: desvia se `rs1` for maior ou igual a `rs2` (_unsigned_, sem sinal).

A saída `BranchSrc` vale `1` quando a condição do _branch_ é verdadeira. Nesse caso, o próximo PC poderá receber o endereço de desvio calculado. Quando `BranchSrc` vale `0`, a execução segue normalmente para a próxima instrução.

A decisão final de alteração do PC é completada pela unidade de controle principal (`ucPrincipal`), combinando `BranchSrc` com o sinal `Branch`, que indica que a instrução atual é realmente uma instrução de desvio.

## Interface

| Pino | Direção | Largura | Descrição |
|------|---------|---------|-----------|
| `Zero` | Entrada | 1 bit | Vale `1` quando o resultado da operação da ULA é zero. |
| `funct3` | Entrada | 3 bits | Campo da instrução que identifica o tipo de desvio. 
| `BranchSrc` | Saída | 1 bit | Indica se o desvio deve ser tomado. |

## Tabela `funct3` &rarr; condição de desvio
| funct3 | Instrução | Operação na ULA | Condição para desviar |
|:------:|-----------|--------------------------|------------------------|
| `000` | `beq` | Subtração: `A - B` | `Zero == 1` |
| `001` | `bne` | Subtração: `A - B` | `Zero == 0` |
| `100` | `blt` | Menor que com complemento de 2: `A < B` | `Zero == 0` |
| `110` | `bltu` | Menor que sem sinal: `A < B` _unsigned_ | `Zero == 0` |
| `101` | `bge` | Menor que com complemento de 2: `A < B` | `Zero == 1` |
| `111` | `bgeu` | Menor que sem sinal: `A < B` _unsigned_ | `Zero == 1` |

## Funcionamento

A unidade de desvio não calcula diretamente operações aritméticas. Ela apenas combina as operações realizadas pela ULA, definidas para cada instrução dentro da unidade de controle da ULA, e a saída `Zero` da primeira para decidir se o _branch_ será executado.

Para as instruções `beq` e `bne`, a ULA executa uma subtração entre os operandos:

- `beq`
  - Se `A - B == 0` então A e B são iguais, tornando `Zero = 1` e `BranchSrc = 1`.

- `bne`
  - Se `A - B != 0` então A e B não são iguais, com `Zero = 0` e `BranchSrc = 1`.

As instruções `blt` e `bge` a ULA executa comparação menor-que com complemento de 2 (com sinal):

- `blt`
  - Se `A < B` for verdadeiro (1), o resultado ULA é `1`, logo, `Zero = 0` e `BranchSrc = 1`.

- `bge`
  - Se `A < B` for falso (0), o resultado da ULA é `0` e então, `Zero = 1` e `BranchSrc = 1`.

Para `bltu` e `bgeu`, a ULA executa a comparação menor-que **sem sinal**, com a mesma lógica de `blt` e `bge`:

- `bltu`
  - Se `A < B` for verdadeiro (1), o resultado ULA é `1`, logo, `Zero = 0` e `BranchSrc = 1`.
- `bgeu`
  - Se `A < B` for falso (0), o resultado da ULA é `0` e então, `Zero = 1` e `BranchSrc = 1`.

## Implementação

Internamente, a unidade de controle de desvio possui uma lógica combinacional que compara o `funct3` da instrução com os códigos de _branch_ e combina esse resultado com a flag `Zero`.

Blocos usados:

- `beq`
  - Ativa quando `funct3 == 000` e `Zero == 1`.

- `bne`
  - Ativa quando `funct3 == 001` e `Zero == 0`.

- `blt`
  - Ativa quando `funct3 == 100` e `Zero == 0`.

- `bltu`
  - Ativa quando `funct3 == 110` e `Zero == 0`.

- `bge`
  - Ativa quando `funct3 == 101` e `Zero == 1`.

- `bgeu`
  - Ativa quando `funct3 == 111` e `Zero == 1`.

Todas essas saídas são combinadas por uma porta OR. Se qualquer uma delas for verdadeira, a saída final `BranchSrc` será `1`.