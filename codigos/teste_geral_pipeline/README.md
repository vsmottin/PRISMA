# Teste Geral do Pipeline (auto-verificável) — `teste_geral_pipeline.txt`

Teste abrangente com **bolhas manuais** (3 NOPs entre dependências, sem
*forwarding*). Exercita **todas as classes** da ISA e **confere sozinho** cada
resultado contra o valor esperado.

## Resultado: só olhe o `x31`

> **`x31 = 1` → passou em TUDO.**
> **`x31 = 0` → algo está errado.**

O programa compara cada resultado com o esperado de forma **sem branch**
(`xor` + `sltiu`) e acumula tudo em `x31` com `and`. Assim o próprio teste diz se
o processador está correto, sem você conferir tabela.

Os **12 branches** também ficam visíveis individualmente em `x18`–`x29` (cada um
`1` se decidiu certo) — úteis pra localizar falha. Os resultados da ALU vão
também pra memória de dados (`mem[0..72]`) para inspeção.

## Como rodar
1. Carregue `teste_geral_pipeline.txt` na memória de instruções (*Load Image*).
2. Reset e rode até o `Stop` (**≈ 800 ciclos**).
3. **Olhe `x31`:** `1` = tudo certo.

> Loads/stores sub-palavra assumem **little-endian** (padrão RISC-V).

## Cobertura

| Classe | Instruções auto-verificadas |
| :--- | :--- |
| ALU R | add, sub, and, or, xor, sll, srl, sra, slt, sltu |
| ALU I | addi, andi, ori, xori, slti, sltiu, slli, srli, srai |
| U-type | lui, auipc (checado de forma PC-independente) |
| Stores | sw, sh, sb (gravadas e lidas de volta) |
| Loads | lw, lh, lb, lhu, lbu |
| Branches | beq, bne, blt, bge, bltu, bgeu (tomado **e** não-tomado) |

> `jal`/`jalr` **não** entram aqui (o `jalr` expõe um *hazard* de leitura do
> registrador-base no pipeline). Use o `teste_pipeline_jump` para saltos.

## Registradores usados

| Reg | Uso |
| :---: | :--- |
| `x1`–`x4` | operandos fixos (`12, 5, -1, 1`) |
| `x5`–`x8` | temporários (valor / esperado / comparação) |
| `x18`–`x29` | resultado de cada branch (`1` = ok) — para debug |
| **`x31`** | **flag global: `1` sse tudo passou** |

## Se `x31 = 0` (achar a falha)

1. Olhe `x18`–`x29`: se algum for `0`, é aquele branch. Mapa:
   `beq/bne` → caminho `EQ`; `blt/bge` → `LT`; `bltu/bgeu` → `LTU`.
2. Se `x18`–`x29` estão todos `1`, a falha é na ALU/load/store/U-type —
   compare `mem[0..72]` (resultados da ALU) com o esperado (add=`0x11`, sub=`0x07`,
   …) para achar qual operação errou.

## Arquivos
- `teste_geral_pipeline.txt` — imagem Logisim `v2.0 raw`.
- `teste_geral.s` — fonte comentado (gerado com bolhas manuais).
