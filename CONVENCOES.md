# Convenções do projeto

Este arquivo relata as regras de montagem e documentação dos circuitos.

O objetivo dessas regras é padronizar nomes e circuitos o suficiente de modo que qualquer pessoa consiga abrir um componente desconhecido e entendê-lo sem precisar rastrear fio por fio.

<br>

## 1. Nomenclatura de arquivos e diretórios

- **lowerCamelCase**, em português e sem acentuação, com exceção de siglas (como `ULA`).
- O `.circ` tem o **mesmo nome** do diretório que o contém: `componentes/ULA/ULA.circ`.
- A imagem do circuito segue o padrão `<nomeDoDiretorio>_imagem.png`. Quando um diretório tem várias imagens, elas ficam em uma subpasta `imagens/`.
- Cada diretório tem um `README.md`, mesmo que mais básico.

Prefixos em uso:

| Prefixo | Aplica-se a | Exemplos |
| :--- | :--- | :--- |
| `uc` | Unidades de controle | `ucPrincipal`, `ucULA`, `ucDesvio`, `ucEnderecamento` |
| `mem` | Memórias | `memInstr`, `memDados` |
| `estagio` | Registradores de estágio, seguidos da fronteira | `estagioIF_ID`, `estagioEX_MEM` |
| `extensor` | Extensores, no padrão `extensor<tipo>_<largura>` | `extensorSinal_12`, `extensorZero_8` |

O `<tipo>` do extensor é `Sinal` (extensão de sinal) ou `Zero` (extensão de zero), e `<largura>` é a quantidade de bits da **entrada**. Um sufixo identifica o formato da instrução quando necessário: `extensorZero_20_typeU`.

<br>

## 2. Posição dos pinos

### Regra

- **Pinos de entrada ficam à esquerda.**
- **Pinos de saída ficam à direita.**

O fluxo do dado deve ser sempre da esquerda para a direita, igual aos diagramas de _datapath_ da literatura. Isso vale nos **dois** lugares em que os pinos aparecem:

| Onde | Como garantir |
| :--- | :--- |
| Dentro do circuito | Entradas com `facing = east` (padrão do Logisim), saídas com `facing = west`. É o comportamento automático ao arrastar um _Input Pin_ ou um _Output Pin_. |
| No design do componente | Em `Project` &rarr; `Edit Circuit Appearance`, arraste as portas de entrada para a borda esquerda e as de saída para a borda direita da forma. |

### Exceção: constantes e _clock_

Entradas de **_clock_** ou constantes podem ficar na borda **superior** ou **inferior**, como nos quatro registradores de estágio (borda superior).

<br>

## 3. Túneis (_tunnels_)

Um túnel liga todos os túneis de mesmo rótulo dentro do mesmo circuito.

### Quando usar fio direto

Use **fio**, e não túnel, sempre que a ligação for **curta e visível**:

- Entre dois componentes vizinhos.
- Dentro de um mesmo bloco lógico, onde o traçado não cruza/sobrepõe nada.
- Onde a ligação dificilmente causará um deslocamento grande dos componentes para que fiquem retos, centralizados.
- Quando o uso ajuda quem está visualizando a compreender melhor as conexões entre partes diferentes.


### Quando usar túnel

Use **túnel** quando o fio prejudicaria a leitura:

| Situação | Exemplo no repositório |
| :--- | :--- |
| Distribuição para muitos pontos (3+ destinos distantes) | `CLK`, `Clear` e `Enable` nos [registradores de estágio](componentes/estagiosPipeline/) |
| Distância longa, em que o fio cruzaria vários outros | `Stop` e `PC` no [monociclo](datapaths/monociclo/) |
| Travessia entre regiões lógicas | `RegWrite`, `MemToReg`, `ALUSrcB`, indo da [ucPrincipal](componentes/ucPrincipal/) para outras partes |
| Reaproveitamento de um valor intermediário em pontos afastados | `imm_12`, `imm_20` no [decodificador](componentes/decodificador/) |

### Regras obrigatórias

1.  **Todo túnel tem rótulo.** Túnel sem `label` liga-se a todos os outros sem rótulo do circuito.
2.  **Mínimo de dois túneis por rótulo.** Um rótulo usado uma única vez é um fio morto: ou falta o par, ou é resto de uma edição anterior.
3.  **Uma única fonte por rótulo.** Vários túneis de mesmo nome recebendo sinal de saídas diferentes provocam conflito (fio vermelho).
4.  **Largura consistente.** Todos os túneis de um mesmo rótulo devem ter a mesma largura em bits.
5.  **Uso único.** Nunca reaproveite um nome para outro sinal no mesmo circuito.

### Nomeação

O túnel usa **exatamente** o nome do sinal que ele transporta, sem acento e sem espaço:

| Categoria | Estilo | Exemplos |
| :--- | :--- | :--- |
| Sinais de controle | `PascalCase`, como na literatura de RISC-V | `RegWrite`, `MemToReg`, `MemRead`, `MemWrite`, `ALUSrcB`, `ALUOp`, `PCSrc`, `Branch`, `Jump`, `Jalr`, `Auipc`, `Lui`, `Stop` |
| Campos da instrução e dados | `lowerCamelCase`, como na ISA | `opcode`, `funct3`, `funct7`, `imm`, `rd`, `rs1`, `rs2`, `offset`, `size` |
| Sinais de relógio e controle de registrador | Maiúsculas ou `PascalCase` | `CLK`, `Clear`, `Enable` |
| Sinais do _pipeline_ | Nome do sinal + `_<estagio>` | `PC_IF`, `RegWrite_ID`, `ALUResult_MEM` |

<br>

## 4. Documentação

Todo diretório tem um `README.md`. Os de **componente** seguem esta ordem:

1.  `# Título`: nome por extenso, com a sigla entre parênteses quando houver.
2.  Imagem do circuito, logo abaixo do título.
3.  Parágrafo de abertura: o que o bloco faz e por que ele existe.
4.  `## Interface`: tabela de pinos: **Pino | Direção | Largura | Descrição**.
5.  `## Funcionamento`: o comportamento, sinal a sinal.
6.  `## Implementação`: quais peças do Logisim foram usadas.

Os de diretório mais geralizados (como [`componentes/`](componentes/) e [`datapaths/`](datapaths/)) trazem uma tabela do que há dentro e links para os manuais individuais.

### Formatação

- Palavras em inglês em _itálico_: `_datapath_`, `_clock_`, `_branch_`, `_pipeline_`.
- Ênfase em **negrito**: `**RISC-V**`, `**nunca**`.
- Nomes de sinais, pinos, arquivos e valores em `código`.
- Seções separadas por uma linha `<br>`.
- Observações em `> [!NOTE]` e avisos em `> [!IMPORTANT]`.
