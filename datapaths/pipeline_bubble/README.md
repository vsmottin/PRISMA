Português | [Español](README-es.md) | [English](README-en.md)

# Datapath - Pipeline com bolhas automáticas

![Datapath do pipeline com bolhas automáticas](pipeline_bubble_imagem.png)

Implementação do processador RISC-V com **pipeline de 5 estágios** e **detecção de conflitos de dados em hardware**. Como no [pipeline simples](../pipeline/README.md), várias instruções executam simultaneamente. Quando um operando ainda não está disponível, o circuito pausa a busca e a decodificação e insere bolhas automaticamente.

Esta versão do circuito **não possui _forwarding_**: a instrução dependente aguarda a escrita do resultado no banco de registradores e instruções do caminho incorreto são descartadas após desvios e saltos.

<br>

## Visão geral dos estágios

| Estágio | Nome | Função | Registrador de saída |
| :---: | :--- | :--- | :---: |
| **IF** | _Instruction Fetch_ | Busca a instrução na memória e calcula o próximo `PC`. | `IF/ID` |
| **ID** | _Instruction Decode_ | Decodifica, lê o banco de registradores e resolve os desvios. | `ID/EX` |
| **EX** | _Execute_ | Executa a operação na ULA (aritmética, endereço, alvo do `jalr`). | `EX/MEM` |
| **MEM** | _Memory_ | Acessa a memória de dados (`lw`/`sw` e variantes). | `MEM/WB` |
| **WB** | _Write-Back_ | Escreve o resultado de volta no banco de registradores. | &mdash; |

<br>

## Estágio IF - Busca da instrução

Responsável por buscar a instrução apontada pelo `PC` e determinar o endereço da próxima.

- **`PC` e [memória de instruções](../../componentes/memInstrucoes/)** &mdash; fornecem a instrução atual e o endereço sequencial `PC + 4`.
- **MUXes do próximo `PC`** &mdash; selecionam o endereço sequencial, `PC_ID + imm_ID` pelo sinal `Redirect_ID` ou o alvo de `jalr` calculado em EX. O `jalr` tem prioridade e seu endereço recebe a máscara `0xFFFFFFFE`, zerando o bit menos significativo.
- **[Registrador `IF/ID`](../../componentes/estagiosPipeline/estagioIF_ID/)** &mdash; guarda instrução, `PC` e `PC + 4`. Quando `Flush_IF = 1`, a instrução recebida é substituída por `0x00000013` (`nop`).

O `PC` e o `IF/ID` usam a habilitação `NOT Stall OR Jalr_EX`: ficam congelados durante uma dependência, mas podem avançar para aplicar um `jalr` em EX. O [contador de ciclos](../../componentes/contadorCiclos/) continua contando durante a espera.

<br>

## Estágio ID - Decodificação e controle

O estágio mais denso: decodifica a instrução, lê os operandos e decide os desvios.

- **[Decodificador](../../componentes/decodificador/) e [banco de registradores](../../componentes/bancoRegistradores/)** &mdash; extraem os campos da instrução e leem os operandos.
- **[Unidade de controle](../../componentes/ucPrincipal/control_unit_bubble.circ)** &mdash; gera os controles de execução e `read_rs1`/`read_rs2`, que indicam quais registradores a instrução realmente lê.
- **[Mini-ULA `idULA`](../../componentes/pipelineComponentes/idULA/) e [controle de desvio](../../componentes/ucDesvio/)** &mdash; comparam os operandos para decidir os desvios condicionais. O destino do desvio ou de `jal` é `PC_ID + imm_ID`.
- **[Unidade de detecção de _hazards_](../../componentes/pipelineComponentes/hazard_detection_unit/hazard_detection_unit.circ)** &mdash; compara as fontes de ID com os destinos de EX e MEM e gera os sinais de pausa e descarte.
- **[Registrador `ID/EX` com bolhas](../../componentes/estagiosPipeline/ID_EX_stage_bubble/ID_EX_stage_bubble.circ)** &mdash; recebe `Bubble_ID`, selecionando dados e controles neutros para a próxima borda de descida.

Os sinais `read_rs1` e `read_rs2` são usados para evitar dependências falsas com bits de imediato, sendo ativados de acordo com a tabela abaixo:

| Classe | `read_rs1` | `read_rs2` |
| :--- | :---: | :---: |
| Aritmética/lógica tipo R | 1 | 1 |
| Aritmética/lógica tipo I, _loads_ e `jalr` | 1 | 0 |
| _Stores_ e desvios condicionais | 1 | 1 |
| `lui`, `auipc` e `jal` | 0 | 0 |

<br>

## Estágio EX - Execução

Realiza a operação aritmética/lógica principal.

- **MUXes de operando** &mdash; selecionam as entradas `A` e `B` da ULA:
  - `A`: `rs1`, ou o `PC` (para `auipc`), ou `0` (para `lui`).
  - `B`: `rs2` ou o imediato (`IMM`), conforme o sinal `ALUSrcB`.
- **[ULA](../../componentes/ULA/)** &mdash; executa a operação (soma, subtração, lógicas, deslocamentos, comparações) e calcula endereços de `load`/`store` e o alvo do `jalr` (`rs1 + imm`).
- **[Controle da ULA (`ucULA`)](../../componentes/ucULA/)** &mdash; decodifica `ALUOp`, `opcode`, `funct3` e `funct7` no `ALUControl` de 3 bits (na ordem do `funct3`) e nos dois seletores de desempate da ULA, `subSeletor` (`add`/`sub`) e `sraiSeletor` (`srl`/`sra`).

<br>

## Estágio MEM - Acesso à Memória

Executa as instruções de `load` e `store`.

- **[Memória de Dados](../../componentes/memDados/)** &mdash; usa o resultado da ULA como endereço (`end.`) e `rs2` como dado a gravar (`ED`). Suporta acessos de _byte_, _half_ e _word_, com/sem sinal.
- **[Controle de endereçamento (`ucEnderecamento`)](../../componentes/ucEnderecamento/)** &mdash; a partir de `funct3` e do endereço, gera `byteEnable`, `size`, `offset` e `unsigned`, permitindo `sb`/`sh`/`sw` e `lb`/`lh`/`lw`/`lbu`/`lhu`.
- O _clock_ de escrita da memória também é interrompido pelo `Stop`.

<br>

## Estágio WB - Escrita no Registrador

Decide qual valor volta ao banco de registradores.

- **MUX `MemToReg`** &mdash; escolhe entre o resultado da ULA e o dado lido da memória (`LD`).
- **MUX `Jump`** &mdash; sobrepõe com `PC + 4` (endereço de retorno de `jal`/`jalr`).
- O valor final entra em `wd`, com `rd` como endereço de escrita e `RegWrite`
  como habilitação.

<br>

## Sinal `Stop`

A unidade de controle gera `Stop` ao encontrar um `opcode` não reconhecido, como `0xFFFFFFFF`. O sinal bloqueia o _clock_ do `PC` (`CLK OR Stop`), da memória de dados e do contador (`CLK AND NOT Stop`).

> [!IMPORTANT]
> `Stop` não bloqueia os registradores de estágio nem o banco de registradores. Deixe ciclos para as últimas operações concluírem antes do marcador de fim, especialmente para escritas na memória.

<br>

## Dependências e bolhas automáticas

Há dependência quando uma instrução em EX ou MEM vai escrever um registrador diferente de `x0` que a instrução em ID precisa ler. Nesse caso, **`Stall = 1`**:

1. O `PC` e o `IF/ID` mantêm seus valores.
2. `Bubble_ID` insere uma bolha no `ID/EX`, desativando escritas e saltos.
3. EX, MEM e WB continuam avançando até o resultado estar disponível no banco.

Por exemplo, esta sequência gera duas bolhas entre as instruções:

```asm
addi x1, x0, 5
add  x2, x1, x1
```

A `add` permanece em ID enquanto a `addi` passa por EX e MEM. Quando a `addi` chega a WB, escreve `x1` e permite que a `add` avance com o valor atualizado. O mesmo ocorre com um _load_ seguido imediatamente por uma instrução dependente.

> [!NOTE]
> `Flush_IF` substitui a instrução de IF por um `nop`. `Bubble_ID` seleciona dados e controles neutros no `ID/EX`, com `opcode = 0x13` e sinais de escrita e salto desativados.

<br>

## Desvios e saltos

Os sinais descritos abaixo são utilizados para determinação de conflitos, pausas e descartes no circuito.

```text
Redirect_ID = PCSrc_ID AND NOT Stall AND NOT Jalr_EX
Flush_IF    = Redirect_ID OR Jalr_EX
Bubble_ID   = Stall OR Jalr_EX
```

| Situação | Comportamento |
| :--- | :--- |
| Desvio não tomado | Continua por `PC + 4`, sem descarte. |
| Desvio tomado ou `jal` em ID | Redireciona para `PC_ID + imm_ID` e descarta IF: **1 bolha**. |
| Desvio com operandos pendentes | Aguarda em ID até a dependência ser resolvida. |
| `jalr` em EX | Redireciona para o alvo da ULA e descarta IF e ID: **2 bolhas**, além de eventuais esperas por dados. |

O `jalr` em EX tem prioridade sobre o redirecionamento em ID e sobre `Stall`.

<br>

## Registradores de estágio e _clock_

As barreiras `IF/ID`, `ID/EX`, `EX/MEM` e `MEM/WB` propagam os dados e controles necessários aos estágios seguintes.

O `PC` e os registradores de estágio gravam na **descida**; o banco de registradores e a memória de dados gravam na **subida**. Assim, WB pode escrever um valor antes de ID capturá-lo no mesmo ciclo. Para mais, veja [bordas de _clock_ do pipeline simples](../pipeline/README.md#bordas-de-clock).