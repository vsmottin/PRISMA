# Teste de Encaminhamento (auto-verificável) — `teste_encaminhamento.txt`

Teste do [pipeline com encaminhamento](../../datapaths/pipelineEncaminhamento/). Ao contrário do [teste geral](../teste_geral_pipeline/), ele **não** usa bolhas entre dependências de dados: cada instrução lê registradores escritos uma ou duas posições antes, obrigando a [Unidade de Encaminhamento](../../componentes/pipelineComponentes/ucEncaminhamento/) a entregar o valor novo. Os únicos `nop` são os que o encaminhamento não resolve e os que os desvios já exigiam.

## Resultado: só olhe o `x31`

> **`x31 = 1` → passou em TUDO.**
> **`x31 = 0` → algo está errado.**

Cada verificação compara o resultado com o esperado sem desvio (`xori` + `sltiu`), grava `1`/`0` em `diag[256 + 4*n]` e acumula em `x31` com `and`. As próprias verificações são dependências de distância 1, então também são encaminhadas.

## Como rodar
1. Abra o [`pipelineEncaminhamento`](../../datapaths/pipelineEncaminhamento/main.circ).
2. Carregue `teste_encaminhamento.txt` na memória de instruções (*Load Image*).
3. Reset e rode até o `Stop` (**≈ 135 ciclos**).
4. **Olhe `x31`:** `1` = tudo certo.

> [!NOTE]
> No [pipeline simples](../../datapaths/pipeline/), que não tem encaminhamento, o mesmo programa termina com `x31 = 0`.

## Cobertura

| # | `diag` | O que é verificado |
| :---: | :---: | :--- |
| 1 | `256` | `rs2` vindo do `EX/MEM` (`ForwardB = 10`) e `rs1` do `MEM/WB` (`ForwardA = 01`). |
| 2 | `260` | `rs1` vindo do `EX/MEM` e `rs2` do `MEM/WB`. |
| 3 | `264` | Prioridade: o mesmo registrador escrito no MEM e no WB, vale o mais recente. |
| 4 | `268` | Cadeia de `add` em que cada instrução usa a anterior. |
| 5 | `272` | `x0` nunca é encaminhado (`addi x0, x0, 99` seguido de leitura de `x0`). |
| 6 | `276` | Sem `RegWrite` não há encaminhamento (`sw` cujo campo `rd` coincide com o registrador lido). |
| 7 | `280` | _Store_ com base e dado encaminhados; _load_ &rarr; uso com 1 `nop`. |
| 8 | `284` | _Load_ com base encaminhada; dado lido encaminhado para um _store_. |
| 9 | `288` | Desvio no ID com o operando vindo do `EX/MEM` (`ForwardA_ID = 10`). |
| 10 | `292` | Desvio no ID com um operando do `MEM/WB` e outro do `EX/MEM`. |
| 11 | `296` | _Load_ &rarr; desvio com 2 `nop`. |
| 12 | `300` | `jal`: endereço de retorno vindo do `EX/MEM` (`wd_MEM = PC + 4`) e do `MEM/WB`. |
| 13 | `304` | `jalr`: base encaminhada e endereço de retorno vindo do `EX/MEM` e do `MEM/WB`. |
| 14 | `308` | `lui`/`auipc` ignoram o valor encaminhado para o campo `rs1`. |
| 15 | `312` | Tipo I ignora o valor encaminhado para o campo `rs2`. |
| — | `316` | Cópia do `x31` final. |

Os endereços de `jal`/`jalr` são conferidos de forma independente do `PC`, subtraindo um `auipc` feito antes do salto.

## Bolhas que continuam no programa

| Situação | `nop` | Motivo |
| :--- | :---: | :--- |
| _Load_ &rarr; uso | 1 | O dado só existe no fim do MEM. |
| Escrita &rarr; desvio | 1 | O desvio é decidido no ID enquanto a instrução anterior ainda está na ULA. |
| _Load_ &rarr; desvio | 2 | Junta os dois atrasos. |
| Depois de desvio ou `jal` (blocos 9 a 11) | 1 | A instrução seguinte ao desvio é executada mesmo quando ele é tomado, como no pipeline simples. |

Retirar uma dessas bolhas de dados zera o `diag` do bloco correspondente (conferido no circuito nos blocos 7, 9 e 11).

## Registradores usados

| Reg | Uso |
| :---: | :--- |
| `x1`–`x6`, `x10`–`x19`, `x21`, `x22` | operandos e resultados de cada bloco |
| `x7` | resultado de cada verificação (`1` = ok) |
| `x8`, `x9` | base (`200`) e dado (`0x5A`) dos acessos à memória |
| **`x31`** | **flag global: `1` sse tudo passou** |

## Arquivos
- `teste_encaminhamento.txt` — imagem Logisim `v2.0 raw`.
- `teste_encaminhamento.s` — fonte comentado.
