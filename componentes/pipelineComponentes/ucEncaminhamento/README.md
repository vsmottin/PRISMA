# Unidade de Encaminhamento (ucEncaminhamento)

![Circuito da ucEncaminhamento](ucEncaminhamento_imagem.png)

A Unidade de Encaminhamento (`ucEncaminhamento`) é a _forwarding unit_ descrita por Patterson e Hennessy. Ela detecta quando uma instrução vai ler um registrador que ainda está sendo calculado por uma instrução mais adiante no _pipeline_ e escolhe de onde o valor correto deve vir: do banco de registradores, do registrador `EX/MEM` ou do registrador `MEM/WB`.

Sem ela, uma instrução que lê um registrador escrito logo antes enxerga o valor **antigo**, e o programa precisa de bolhas (`nop`) entre as duas. Com ela, o valor novo é **encaminhado** direto do estágio em que já existe, e essas bolhas deixam de ser necessárias.

A unidade é puramente combinacional e atende, **ao mesmo tempo**, os dois estágios que leem registradores no [`pipelineEncaminhamento`](../../../datapaths/pipelineEncaminhamento/): o EX (ULA, endereços e dado do _store_) e o ID (comparação dos desvios). Para cada um dos quatro registradores lidos (`rs1` e `rs2` de cada estágio) ela gera um seletor próprio, e a verificação de escrita válida no MEM e no WB é feita uma única vez e compartilhada pelos quatro.

<br>

## Interface

| Pino | Direção | Largura | Descrição |
| :--- | :---: | :---: | :--- |
| `rs1_ID` | Entrada | 5 bits | Primeiro registrador lido pela instrução no ID (desvio). |
| `rs2_ID` | Entrada | 5 bits | Segundo registrador lido pela instrução no ID (desvio). |
| `rs1_EX` | Entrada | 5 bits | Primeiro registrador lido pela instrução no EX (saída do `ID/EX`). |
| `rs2_EX` | Entrada | 5 bits | Segundo registrador lido pela instrução no EX (saída do `ID/EX`). |
| `RegWrite_MEM` | Entrada | 1 bit | Indica se a instrução no MEM escreve no banco. |
| `rd_MEM` | Entrada | 5 bits | Registrador de destino da instrução no estágio MEM (saída do `EX/MEM`). |
| `RegWrite_WB` | Entrada | 1 bit | Indica se a instrução no WB escreve no banco. |
| `rd_WB` | Entrada | 5 bits | Registrador de destino da instrução no estágio WB (saída do `MEM/WB`). |
| `ForwardA_ID` | Saída | 2 bits | Seletor do MUX de encaminhamento de `rs1_ID` (operando A da `idULA`). |
| `ForwardB_ID` | Saída | 2 bits | Seletor do MUX de encaminhamento de `rs2_ID` (operando B da `idULA`). |
| `ForwardA_EX` | Saída | 2 bits | Seletor do MUX de encaminhamento de `rs1_EX` (operando A da ULA). |
| `ForwardB_EX` | Saída | 2 bits | Seletor do MUX de encaminhamento de `rs2_EX` (operando B da ULA e dado do _store_). |

O bloco é um retângulo com o nome de cada porta escrito ao lado dela: as oito entradas ficam na borda esquerda, de cima para baixo na ordem da tabela, e as quatro saídas na borda direita, também na ordem da tabela. As portas seguem a ordem do _pipeline_: primeiro o ID, depois o EX, o MEM e o WB.

<br>

## Funcionamento

### Codificação das saídas
Os seletores seguem a mesma codificação do livro:

| `Forward*` | Origem do valor | Quando |
| :---: | :--- | :--- |
| `00` | Banco de registradores | Nenhuma instrução adiante escreve no registrador lido. |
| `10` | `EX/MEM` | A instrução **imediatamente anterior** escreve no registrador lido. |
| `01` | `MEM/WB` | A instrução de **duas posições antes** escreve no registrador lido. |

A combinação `11` nunca é gerada, então a entrada `3` dos MUXes de encaminhamento nunca é selecionada.

### Condições
A mesma regra é aplicada a cada um dos quatro registradores lidos. Para `rs1_EX`:

```
Conflito no EX:   RegWrite_MEM  e  rd_MEM ≠ 0  e  rd_MEM = rs1_EX                          ->  ForwardA_EX = 10
Conflito no MEM:  RegWrite_WB   e  rd_WB  ≠ 0  e  rd_WB  = rs1_EX  e  não (Conflito no EX)  ->  ForwardA_EX = 01
```

As outras três saídas trocam só o registrador comparado:

| Saída | Registrador comparado |
| :--- | :--- |
| `ForwardA_ID` | `rs1_ID` |
| `ForwardB_ID` | `rs2_ID` |
| `ForwardA_EX` | `rs1_EX` |
| `ForwardB_EX` | `rs2_EX` |

"Conflito no EX" e "Conflito no MEM" são os nomes do livro (_EX hazard_ e _MEM hazard_) e indicam **onde está a instrução que escreve** (no MEM, recém-saída do EX, ou no WB, recém-saída do MEM), e não o estágio da instrução que lê.

Cada termo existe por um motivo:

| Termo | Por quê |
| :--- | :--- |
| `RegWrite` | _Stores_ e desvios têm um campo na posição do `rd`, mas ali estão bits do imediato. Sem `RegWrite`, um `sw` cujo imediato coincidisse com o registrador lido desviaria o endereço da memória para a ULA. |
| `rd ≠ 0` | O `x0` vale sempre `0`. Uma instrução como `addi x0, x0, 99` tem `RegWrite = 1`, mas o valor calculado **nunca** pode ser encaminhado. |
| `não (Conflito no EX)` | Se as instruções no MEM e no WB escrevem no mesmo registrador, vale a **mais recente** (a do MEM), como em `addi x3, x0, 1` seguido de `addi x3, x0, 2` e `add x5, x3, x3`. |

> [!NOTE]
> Uma instrução no WB e outra no ID, no mesmo ciclo, não precisam de encaminhamento no banco: ele grava na primeira metade do ciclo e o `ID/EX` captura a leitura na segunda (ver [Bordas de _clock_](../../../datapaths/pipeline/README.md#bordas-de-clock)). Por isso a unidade só olha os estágios MEM e WB.

### O que ela não resolve
A unidade escolhe a **origem** do valor, mas não consegue criar um valor que ainda não existe:

- Um _load_ no MEM ainda não leu a memória: o `EX/MEM` guarda só o endereço. A instrução seguinte precisa de uma bolha.
- Um desvio resolvido no ID compara os operandos no mesmo ciclo em que a instrução anterior ainda está na ULA. Por isso as saídas do ID só resolvem o conflito se houver uma bolha entre a escrita e o desvio (duas, se a escrita for um _load_).

Inserir essas bolhas em hardware é o papel da unidade de detecção de bolhas; sem ela, o programa precisa trazer o `nop`.

<br>

## Implementação

A `ucEncaminhamento` é construída pelos seguintes blocos, organizados em colunas no circuito:

- **Entradas** — oito pinos, cada um ligado a um túnel de mesmo nome.
- **Escrita válida** — dois **Comparadores** de 5 bits comparam `rd_MEM` e `rd_WB` com a constante `0`; duas portas **AND** com a saída `=` negada formam `escreveMEM` (`RegWrite_MEM` e `rd_MEM ≠ 0`) e `escreveWB`. Esse bloco é único e alimenta as quatro linhas seguintes.
- **Conflito no EX** — quatro **Comparadores** de 5 bits (`rd_MEM` contra `rs1_ID`, `rs2_ID`, `rs1_EX` e `rs2_EX`) e quatro portas **AND** com `escreveMEM` geram `exA_ID`, `exB_ID`, `exA_EX` e `exB_EX`.
- **Conflito no MEM** — quatro **Comparadores** de 5 bits (`rd_WB` contra os mesmos quatro registradores) e quatro portas **AND** de 3 entradas com `escreveWB` e a condição do EX negada geram `memA_ID`, `memB_ID`, `memA_EX` e `memB_EX`.
- **Saídas** — quatro **Splitters** de 2 bits juntam os sinais em `ForwardA_ID = {exA_ID, memA_ID}`, e assim por diante (bit 1 = `EX/MEM`, bit 0 = `MEM/WB`).

Cada linha do circuito (de cima para baixo: `A_ID`, `B_ID`, `A_EX`, `B_EX`) é uma cópia da mesma lógica, mudando só o registrador comparado.

A aparência do bloco é um retângulo de cantos arredondados com o título e o nome de cada porta, com as entradas espaçadas de 30 em 30 e as saídas de 60 em 60.
