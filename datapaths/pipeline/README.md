# Datapath — Pipeline

![Datapath do Pipeline](pipeline_simples.png)

Implementação do processador RISC-V com **pipeline de 5 estágios**. Em vez de
executar uma instrução por completo antes de buscar a próxima (como no
[monociclo](../monociclo/)), a execução é dividida em cinco etapas que operam
**simultaneamente**, cada uma trabalhando em uma instrução diferente. Isso
aumenta a vazão (instruções concluídas por unidade de tempo).

Os cinco estágios são separados por **registradores de estágio** (as barreiras
verdes no circuito), que capturam, na **descida** do _clock_, os dados e sinais de
controle de um estágio e os entregam de forma estável ao estágio seguinte. O banco
de registradores e a memória de dados gravam na borda **inversa** (subida) — ver
[Bordas de _clock_](#bordas-de-clock).

Os desvios condicionais (`beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu`) são resolvidos já no 
estágio **ID**, operando diretamente sobre as saídas do banco de
registradores. Isso reduz a penalidade de desvio para **1 bolha**.

<br>

## Visão geral dos estágios

| Estágio | Nome | Função | Registrador de saída |
| :---: | :--- | :--- | :---: |
| **IF** | _Instruction Fetch_ | Busca a instrução na memória e calcula o próximo `PC` | `IF/ID` |
| **ID** | _Instruction Decode_ | Decodifica, lê o banco de registradores e **resolve os desvios** | `ID/EX` |
| **EX** | _Execute_ | Executa a operação na ULA (aritmética, endereço, alvo do `jalr`) | `EX/MEM` |
| **MEM** | _Memory_ | Acessa a memória de dados (`lw`/`sw` e variantes) | `MEM/WB` |
| **WB** | _Write-Back_ | Escreve o resultado de volta no banco de registradores | — |

<br>

## Estágio IF — Busca da Instrução

Responsável por buscar a instrução apontada pelo `PC` e determinar o endereço da
próxima.

- **Registrador `PC`** — guarda o endereço da instrução atual. Sua atualização é
  condicionada pelo sinal `Stop`: quando `Stop = 1` (opcode inválido), o `PC`
  **congela** e a execução para. Grava na borda de descida, junto com os
  registradores de estágio.
- **Somador `PC + 4`** — soma a constante `4` ao `PC` para obter o endereço
  sequencial da próxima instrução ([`Adder`](../../componentes/)).
- **[Memória de instruções](../../componentes/memInstrucoes/)** — ROM que devolve
  a instrução de 32 bits armazenada no endereço `PC`.
- **MUX `PCSrc`** — escolhe a origem do próximo `PC`: `PC + 4` (sequencial) ou
  `PC + Imm` (alvo do desvio/`jal`). O seletor `PCSrc` vem da `ucPrincipal`.
- **MUX `Jalr`** — sobrepõe o resultado anterior com o alvo do `jalr`
  (`ALU_EX` = `rs1 + imm`, calculado pela ULA no estágio EX).
- **[Contador de ciclos](../../componentes/contadorCiclos/)** — conta os ciclos
  executados; seu _clock_ também é interrompido pelo `Stop`.

<br>

## Estágio ID — Decodificação e resolução de desvios

O estágio mais denso: decodifica a instrução, lê os operandos e decide os
desvios.

- **[Decodificador de instruções](../../componentes/decodificador/)** — fatia a
  instrução em `op`, `rs1`, `rs2`, `rd`, `funct3`, `funct7` e gera o imediato
  (`imm`) já estendido.
- **[Unidade de Controle (`ucPrincipal`)](../../componentes/ucPrincipal/)** — a
  partir do `opcode` (e do `BranchSrc`), gera todos os sinais de controle:
  `Jump`, `ALUOp`, `RegWrite`, `ALUSrcB`, `MemToReg`, `MemRead`, `MemWrite`,
  `Auipc`, `Lui`, `Jalr`, **`PCSrc`** e `Stop`.
- **[Banco de Registradores](../../componentes/bancoRegistradores/)** — lê `rs1`
  e `rs2` (saídas `ld1`/`ld2`) e escreve `rd` na fase WB, na borda de subida (meio do ciclo).
- **[Mini-ULA de desvio (`idULA`)](../../componentes/pipelineComponentes/idULA/)**
  — recebe `A = rs1`, `B = rs2` e `funct3`; faz as comparações necessárias e
  entrega o sinal **`Zero`**. Substitui, para os desvios, o par `ucULA + ULA` do
  estágio EX.
- **[Controle de Desvio (`ucDesvio`)](../../componentes/ucDesvio/)** — recebe
  `Zero` (da `idULA`) e `funct3` e produz **`BranchSrc`**, que sobe até a
  `ucPrincipal` para formar o `PCSrc`.
- **Somador do alvo (`PC + Imm`)** — calcula o endereço de destino do desvio,
  roteado ao MUX `PCSrc` do estágio IF.

<br>

## Estágio EX — Execução

Realiza a operação aritmética/lógica principal.

- **MUXes de operando** — selecionam as entradas `A` e `B` da ULA:
  - `A`: `rs1`, ou o `PC` (para `auipc`), ou `0` (para `lui`).
  - `B`: `rs2` ou o imediato (`IMM`), conforme o sinal `ALUSrcB`.
- **[ULA](../../componentes/ULA/)** — executa a operação (soma, subtração,
  lógicas, deslocamentos, comparações) e calcula endereços de `load`/`store` e o
  alvo do `jalr` (`rs1 + imm`).
- **[Controle da ULA (`ucULA`)](../../componentes/ucULA/)** — decodifica `ALUOp`,
  `opcode`, `funct3` e `funct7` no `ALUControl` de 3 bits (na ordem do `funct3`) e
  nos dois seletores de desempate da ULA, `subSeletor` (`add`/`sub`) e
  `sraiSeletor` (`srl`/`sra`).

<br>

## Estágio MEM — Acesso à Memória

Executa as instruções de `load` e `store`.

- **[Memória de Dados](../../componentes/memDados/)** — usa o resultado da ULA
  como endereço (`end.`) e `rs2` como dado a gravar (`ED`). Suporta acessos de
  _byte_, _half_ e _word_, com/sem sinal.
- **[Controle de endereçamento (`ucEnderecamento`)](../../componentes/ucEnderecamento/)**
  — a partir de `funct3` e do endereço, gera `byteEnable`, `size`, `offset` e
  `unsigned`, permitindo `sb`/`sh`/`sw` e `lb`/`lh`/`lw`/`lbu`/`lhu`.
- O _clock_ de escrita da memória também é interrompido pelo `Stop`.

<br>

## Estágio WB — Escrita no Registrador

Decide qual valor volta ao banco de registradores.

- **MUX `MemToReg`** — escolhe entre o resultado da ULA e o dado lido da memória
  (`LD`).
- **MUX `Jump`** — sobrepõe com `PC + 4` (endereço de retorno de `jal`/`jalr`).
- O valor final entra em `wd`, com `rd` como endereço de escrita e `RegWrite`
  como habilitação.

<br>

## Resolução de desvios no estágio ID

Este é o ponto central da arquitetura (issue #82). O caminho do desvio é:

```
rs1, rs2 ─► idULA (+ funct3) ─► Zero ─► ucDesvio (+ funct3) ─► BranchSrc ─► ucPrincipal ─► PCSrc ─► MUX (IF)
                                                                    PC + Imm ─────────────────────► MUX (IF)
```

- A **`idULA`** compara `rs1` e `rs2` (igualdade, menor-que com e sem sinal) e
  entrega um único `Zero`, no significado que o `funct3` seleciona.
- O **`ucDesvio`** aplica a polaridade correta e emite `BranchSrc`.
- A **`ucPrincipal`** combina `BranchSrc` com o tipo da instrução para gerar
  `PCSrc`, que no IF seleciona `PC + Imm` como próximo `PC`.

Como tudo isso acontece no **ID**, o desvio é decidido um estágio antes do que
seria no EX — reduzindo a penalidade para **1 bolha**. Essa bolha fica a cargo
do programa: nenhuma instrução é descartada. A instrução buscada logo atrás do
desvio já está no IF quando ele é decidido e é **executada** mesmo quando o
desvio é tomado; por isso os programas colocam um `nop` logo depois de cada
desvio (e de cada `jal`, que também é decidido no ID).

> O **`jalr`** é a exceção: seu alvo (`rs1 + imm`) depende da ULA, então é
> resolvido no **EX** e realimentado ao `PC` pelo MUX `Jalr` (`ALU_EX`). Quando o
> salto acontece, as **duas** instruções seguintes ao `jalr` também são
> executadas, então ele precisa de 2 `nop`.

<br>

## Sinal `Stop`

Gerado pela `ucPrincipal` quando o `opcode` é inválido (por exemplo, ao buscar a
palavra `0xFFFFFFFF` que marca o fim do programa). O `Stop` **congela o `PC`** e
interrompe o _clock_ da memória de dados e do contador de ciclos, encerrando a
execução de forma limpa.

Como cada componente dispara em uma borda, o bloqueio também muda:

| Destino | Borda | _Clock_ bloqueado | Por quê |
| :--- | :---: | :--- | :--- |
| `PC` | descida | `CLK OR Stop` | Com `Stop = 1` o _clock_ fica preso em `1` e nunca desce. |
| Memória de dados e contador de ciclos | subida | `CLK AND NOT Stop` | Com `Stop = 1` o _clock_ fica preso em `0` e nunca sobe. |

> [!NOTE]
> O `Stop` também vale `1` no início da simulação, quando o `IF/ID` ainda guarda
> `00000000`. Com o `OR`, assim que a primeira instrução chega ao ID o `Stop` cai
> e o _clock_ do `PC` desce na mesma hora, avançando o `PC` sem executar a
> instrução 0 duas vezes. O `Enable` do `PC` fica desligado (sempre habilitado),
> pois é o _clock_ bloqueado que controla a gravação.

<br>

## Registradores de estágio

Cada barreira propaga apenas o que os estágios seguintes ainda vão consumir:

| Registrador | Dados propagados | Controle propagado |
| :--- | :--- | :--- |
| **[IF/ID](../../componentes/estagiosPipeline/estagioIF_ID/)** | instrução, `PC`, `PC+4` | — |
| **[ID/EX](../../componentes/estagiosPipeline/estagioID_EX/)** | instrução, `rs1`, `rs2`, `imm`, `PC`, `PC+4`, `rd`, `funct3`, `funct7` | `ALUOp`, `ALUSrcB`, `Auipc`, `Lui`, `Jump`, `RegWrite`, `MemToReg`, `MemRead`, `MemWrite` |
| **[EX/MEM](../../componentes/estagiosPipeline/estagioEX_MEM/)** | instrução, resultado da ULA, `rs2`, `rd`, `PC+4`, `funct3` | `MemRead`, `MemWrite`, `RegWrite`, `MemToReg`, `Jump` |
| **[MEM/WB](../../componentes/estagiosPipeline/estagioMEM_WB/)** | instrução, dado da memória (`LD`), resultado da ULA, `rd`, `PC+4` | `RegWrite`, `MemToReg`, `Jump` |

Os sinais resolvidos no EX (`ALUSrcB`, `ALUOp`, `Auipc`, `Lui`, `Jalr`,
`BranchSrc`) **não** atravessam o `EX/MEM` — são consumidos antes.

> [!NOTE]
> O `ID/EX` também tem entradas para os números `rs1` e `rs2`, usados pela unidade de
> encaminhamento do [pipeline com encaminhamento](../pipelineEncaminhamento/). Neste
> _datapath_ elas ficam desconectadas.

<br>

## Instrução em cada estágio

Os quatro registradores de estágio carregam também a **instrução** de 32 bits,
que avança uma barreira por ciclo junto com os seus dados e sinais de controle.
Ela não é consumida por nenhum componente depois do ID: serve para identificar
qual instrução ocupa cada estágio em um dado ciclo.

| Túnel | Origem |
| :--- | :--- |
| `Instrucao_IF` | saída da memória de instruções |
| `Instrucao_ID` | saída do `IF/ID` |
| `Instrucao_EX` | saída do `ID/EX` |
| `Instrucao_MEM` | saída do `EX/MEM` |
| `Instrucao_WB` | saída do `MEM/WB` |

No topo do circuito, acima de cada estágio, uma sonda (_probe_) em hexadecimal
ligada ao túnel `Instrucao_<estagio>` mostra a instrução presente nele. Ao avançar o _clock_, cada instrução aparece uma sonda à direita. Exemplo
com o início de [`teste_pipeline_reto`](../../codigos/teste_pipeline_reto)
(`00000013` é o `nop`):

| Ciclo | IF | ID | EX | MEM | WB |
| :---: | :---: | :---: | :---: | :---: | :---: |
| 0 | `00500093` | `00000000` | `00000000` | `00000000` | `00000000` |
| 1 | `00300113` | `00500093` | `00000000` | `00000000` | `00000000` |
| 2 | `00000013` | `00300113` | `00500093` | `00000000` | `00000000` |
| 3 | `00000013` | `00000013` | `00300113` | `00500093` | `00000000` |
| 4 | `00000013` | `00000013` | `00000013` | `00300113` | `00500093` |
| 5 | `002081b3` | `00000013` | `00000013` | `00000013` | `00300113` |

> [!NOTE]
> Enquanto a primeira instrução não chega a um estágio, sua sonda mostra
> `00000000`, o valor inicial dos registradores de estágio.

<br>

## Bordas de _clock_

Os registradores de estágio e o `PC` gravam na borda de **descida**; o banco de
registradores e a memória de dados, na de **subida**. Essa inversão existe para
resolver um conflito de tempo entre o WB e o ID.

### O problema: banco e estágios na mesma borda
Considere uma instrução que escreve `x1` e outra, três posições atrás (com duas
instruções entre elas), que lê `x1`. Quando a primeira está no **WB**, a segunda
está no **ID**. O valor de `x1` só é gravado no banco na próxima borda, mas o
`ID/EX` também captura o que foi lido do banco **nessa mesma borda**, ainda com o
valor antigo. A escrita e a leitura empatam, e a leitura perde: a instrução
leitora precisa ficar mais uma posição para trás (3 NOPs em vez de 2).

### A solução: bordas inversas
Com o banco disparando na borda oposta, a escrita cai no **meio** do ciclo:

```
             ciclo N (WB escreve x1, ID lê x1)
        |<---------------------------------------->|
CLK  ‾‾‾|__________________|‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾|____
        ▲                  ▲                       ▲
     descida             subida                 descida
  estágios avançam:    banco grava x1         ID/EX captura
  WB põe x1 na         (1ª metade)            ld1/ld2 já com
  entrada do banco                            o x1 novo (2ª metade)
```

| Instante | Evento |
| :--- | :--- |
| descida | registradores de estágio e `PC` avançam; a instrução do WB coloca `rd`/`wd` na entrada do banco |
| subida | o banco grava `rd` (e a memória de dados grava, se `MemWrite = 1`) |
| próxima descida | o `ID/EX` captura `ld1`/`ld2`, que já refletem a escrita |

É o comportamento descrito por Patterson e Hennessy: o banco de registradores é
**escrito na primeira metade do ciclo e lido na segunda**. Uma instrução no WB e
outra no ID, no mesmo ciclo, deixam de ser um conflito, o que economiza uma
bolha em cada dependência (de 3 para **2 NOPs**).

> [!NOTE]
> A inversão foi feita nos registradores de estágio e no `PC`, e não no banco,
> porque o [banco](../../componentes/bancoRegistradores/) é o mesmo arquivo usado
> pelo [monociclo](../monociclo/). Lá, com o banco na descida, a instrução 0
> perderia sua escrita: a simulação começa com uma borda de subida, que já avança
> o `PC` antes de qualquer descida.
>
> A [memória de dados](../../componentes/memDados/), também compartilhada com o
> monociclo, **mudou** da descida para a subida. Antes ela
> já era oposta aos estágios, que gravavam na subida; quando eles passaram para a
> descida, ela precisou ir para a subida para continuar oposta a eles, junto com o
> banco. Com isso, o monociclo fica todo na mesma borda.

<br>

## Conflitos e bolhas

Este _datapath_ **não** possui _forwarding_ nem detecção de _hazard_ em hardware.
A resolução de conflitos de dados é feita por **bolhas manuais** (`nop`)
inseridas no código: são necessários **2 NOPs** entre uma instrução que escreve
um registrador e outra que o lê (distância mínima de 3 instruções), graças às
[bordas inversas](#bordas-de-clock). Os programas de teste em
[`codigos/`](../../codigos/) foram escritos com 3 NOPs, regra de quando todos os
registradores gravavam na mesma borda, e continuam funcionando: um NOP a mais só
custa um ciclo.

O [pipeline com encaminhamento](../pipelineEncaminhamento/) resolve essas dependências em
hardware e dispensa a maior parte desses NOPs.

<br>

## Arquivo

- **`main.circ`** — circuito completo do _datapath_ pipeline (abrir no
  Logisim-Evolution).
