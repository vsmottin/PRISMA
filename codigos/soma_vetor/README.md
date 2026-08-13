# Soma de Vetor - `soma_vetor.txt` e `soma_vetor_pipeline.txt`

Programa de teste que soma os elementos de um vetor armazenado na memória de dados.

## O que o programa faz?

O programa tem duas fases:

1. **Inicialização:** grava o vetor `[5, 10, 15, 20]` na memória de dados, nos endereços `0`, `4`, `8` e `12`, usando `sw`.
2. **Soma:** percorre o vetor com um laço, lendo cada elemento com `lw` e acumulando em `x3`.

Equivale ao pseudocódigo:

```c
int v[4] = {5, 10, 15, 20};   
int sum = 0;

for (int i = 0; i < 16; i += 4){
    sum += v[i/4];
} //sum == 50.
```

<br>

## Código-fonte (Assembly)

```asm
        addi x1, x0, 0      # base = 0
        addi x2, x0, 5
        sw   x2, 0(x1)      # v[0] = 5
        addi x2, x0, 10
        sw   x2, 4(x1)      # v[1] = 10
        addi x2, x0, 15
        sw   x2, 8(x1)      # v[2] = 15
        addi x2, x0, 20
        sw   x2, 12(x1)     # v[3] = 20
        addi x3, x0, 0      # sum = 0
        addi x4, x0, 0      # i = 0
        addi x5, x0, 16     # limite = 16 bytes

loop:   bge  x4, x5, fim    # se i >= limite, terminou
        add  x6, x1, x4     # endereco = base + i
        lw   x7, 0(x6)      # carrega v[i/4]
        add  x3, x3, x7     # sum += elemento
        addi x4, x4, 4      # i += 4 (proxima palavra)
        jal  x0, loop       # volta ao laço

fim:    (halt)              # opcode invalido -> sinal Stop
```

<br>

## Mapa de execução

| PC | Máquina | Instrução | Efeito |
| :---: | :---: | :--- | :--- |
| `0x00` | `00000093` | `addi x1, x0, 0` | `x1 = 0` (endereço-base) |
| `0x04` | `00500113` | `addi x2, x0, 5` | `x2 = 5` |
| `0x08` | `0020a023` | `sw x2, 0(x1)` | mem[0] = 5 |
| `0x0C` | `00a00113` | `addi x2, x0, 10` | `x2 = 10` |
| `0x10` | `0020a223` | `sw x2, 4(x1)` | mem[4] = 10 |
| `0x14` | `00f00113` | `addi x2, x0, 15` | `x2 = 15` |
| `0x18` | `0020a423` | `sw x2, 8(x1)` | mem[8] = 15 |
| `0x1C` | `01400113` | `addi x2, x0, 20` | `x2 = 20` |
| `0x20` | `0020a623` | `sw x2, 12(x1)` | mem[12] = 20 |
| `0x24` | `00000193` | `addi x3, x0, 0` | `x3 = 0` (zera `sum`) |
| `0x28` | `00000213` | `addi x4, x0, 0` | `x4 = 0` (zera `i`) |
| `0x2C` | `01000293` | `addi x5, x0, 16` | `x5 = 16` (limite) |
| `0x30` | `00525c63` | `bge x4, x5, fim` | **(loop)** se `i >= 16`, salta para `0x48` |
| `0x34` | `00408333` | `add x6, x1, x4` | `x6 = base + i` |
| `0x38` | `00032383` | `lw x7, 0(x6)` | carrega o elemento atual em `x7` |
| `0x3C` | `007181b3` | `add x3, x3, x7` | `sum += elemento` |
| `0x40` | `00420213` | `addi x4, x4, 4` | `i += 4` |
| `0x44` | `fedff06f` | `jal x0, loop` | salto incondicional para `0x30` |
| `0x48` | `ffffffff` | *(halt)* | opcode inválido &rarr; ativa **Stop** e congela a execução |

<br>

## Estado esperado da memória de dados

Após a fase de inicialização (e até o fim do programa):

| Endereço | Valor |
| :---: | :---: |
| `0x00` | 5 |
| `0x04` | 10 |
| `0x08` | 15 |
| `0x0C` | 20 |

<br>

## Resultado esperado

Ao final (PC parado em `0x48` com `Stop = 1`):

| Registrador | Valor (decimal) | Valor (hex) |
| :---: | :---: | :---: |
| **`x3` (`sum`)** | **50** | **`0x00000032`** |
| `x4` (`i`) | 16 | `0x00000010` |
| `x5` (limite) | 16 | `0x00000010` |
| `x6` (último endereço) | 12 | `0x0000000C` |
| `x7` (último elemento) | 20 | `0x00000014` |

A **soma fica em `x3` = 50 (`0x32`)**.

<br>

## Como carregar e executar?

1. Abra o `main.circ` no Logisim Evolution.
2. Clique com o botão direito na **Memória de Instruções** &rarr; **`Load Image...`** e selecione `codigos/soma_vetor/soma_vetor.txt`.
3. Ative o **Clock** e acompanhe o registrador `x3` (acumulador) e o conteúdo da **Memória de Dados**.
4. A execução para sozinha quando o PC alcança `0x48`, onde o opcode inválido `ffffffff` ativa o sinal **Stop**.

---

<br>
<br>

## Versão para pipeline - `soma_vetor_pipeline.txt`

A versão `soma_vetor.txt` é correta no **monociclo**, mas **não** no datapath com **pipeline**, que não tem *forwarding*, *stall* nem *flush*. É preciso inserir **`nop`** (`addi x0, x0, 0` = `0x00000013`) para cobrir riscos de *hazard*.

### Listagem comentada

```
0x00  00000093  addi x1, x0, 0
0x04  00500113  addi x2, x0, 5
0x08  00000013  nop                  # dado: aguarda x2
0x0C  00000013  nop                  # dado: aguarda x2
0x10  00000013  nop                  # dado: aguarda x2
0x14  0020a023  sw   x2, 0(x1)
0x18  00a00113  addi x2, x0, 10
0x1C  00000013  nop                  # dado: aguarda x2  (x3)
0x20  00000013  nop
0x24  00000013  nop
0x28  0020a223  sw   x2, 4(x1)
0x2C  00f00113  addi x2, x0, 15
0x30  00000013  nop                  # dado: aguarda x2
0x34  00000013  nop
0x38  00000013  nop
0x3C  0020a423  sw   x2, 8(x1)
0x40  01400113  addi x2, x0, 20
0x44  00000013  nop                  # dado: aguarda x2
0x48  00000013  nop
0x4C  00000013  nop
0x50  0020a623  sw   x2, 12(x1)
0x54  00000193  addi x3, x0, 0
0x58  00000213  addi x4, x0, 0
0x5C  01000293  addi x5, x0, 16
0x60  00000013  nop                  # dado: aguarda x4
0x64  00000013  nop
0x68  00000013  nop                  # dado: aguarda x5
0x6C  04525a63  loop: bge x4,x5,fim
0x70  00000013  nop                  # desvio: delay slot
0x74  00000013  nop                  # desvio: delay slot
0x78  00408333  add  x6, x1, x4
0x7C  00000013  nop                  # dado: aguarda x6
0x80  00000013  nop
0x84  00000013  nop
0x88  00032383  lw   x7, 0(x6)
0x8C  00000013  nop                  # dado: aguarda x7 (load-use)
0x90  00000013  nop
0x94  00000013  nop
0x98  007181b3  add  x3, x3, x7
0x9C  00420213  addi x4, x4, 4
0xA0  fcdff06f  jal  x0, loop
0xA4  00000013  nop                  # desvio: delay slot
0xA8  00000013  nop                  # desvio: delay slot
0xAC  00000013  nop                  # dreno
0xB0  00000013  nop                  # dreno
0xB4  00000013  nop                  # dreno
0xB8  00000013  nop                  # dreno
0xBC  00000013  nop                  # dreno
0xC0  ffffffff  fim: halt
```
