# Fatorial - `fatorial.txt` e `fatorial_pipeline.txt`

Programa de teste que calcula o **fatorial** de um número. Como o processador não possui instruções de multiplicação (RV32I), a multiplicação é feita através de somas repetidas.

## O que o programa faz?

Calcula `n!` para `n = 5`, ou seja:

```
5! = 5 × 4 × 3 × 2 × 1 = 120
```

O algoritmo equivale ao seguinte pseudocódigo:

```c
n = 5;
result = 1;

for (i = 2; i <= n; i++) {     
    acc = 0;

    for (k = 0; k < i; k++){
        acc = acc + result;
    }

    result = acc; //120.
}
```

A cada passo do laço externo, `result` é multiplicado por `i`. A multiplicação `result × i` é realizada somando `result` a si mesmo `i` vezes (laço interno).

<br>

## Código-fonte (Assembly)

```asm
        addi x1, x0, 5      # n = 5
        addi x2, x0, 1      # result = 1
        addi x3, x0, 2      # i = 2

outer:  blt  x1, x3, fim    # se n < i, terminou
        addi x4, x0, 0      # acc = 0
        addi x5, x0, 0      # k = 0

mult:   beq  x5, x3, mfim   # se k == i, fim da 
        add  x4, x4, x2     # acc += result
        addi x5, x5, 1      # k++
        jal  x0, mult       # volta ao laço interno

mfim:   add  x2, x4, x0     # result = acc
        addi x3, x3, 1      # i++
        jal  x0, outer      # volta ao laço externo

fim:    (halt)              # opcode inválido -> sinal Stop
```

<br>

## Mapa de execução

| PC | Máquina | Instrução | Efeito |
| :---: | :---: | :--- | :--- |
| `0x00` | `00500093` | `addi x1, x0, 5` | `x1 = 5` (define `n`) |
| `0x04` | `00100113` | `addi x2, x0, 1` | `x2 = 1` (inicializa `result`) |
| `0x08` | `00200193` | `addi x3, x0, 2` | `x3 = 2` (inicializa `i`) |
| `0x0C` | `0230c463` | `blt x1, x3, fim` | **(outer)** se `n < i`, salta para `0x34` |
| `0x10` | `00000213` | `addi x4, x0, 0` | `x4 = 0` (zera `acc`) |
| `0x14` | `00000293` | `addi x5, x0, 0` | `x5 = 0` (zera `k`) |
| `0x18` | `00328863` | `beq x5, x3, mfim` | **(mult)** se `k == i`, salta para `0x28` |
| `0x1C` | `00220233` | `add x4, x4, x2` | `acc += result` |
| `0x20` | `00128293` | `addi x5, x5, 1` | `k++` |
| `0x24` | `ff5ff06f` | `jal x0, inner` | salto incondicional para `0x18` |
| `0x28` | `00020133` | `add x2, x4, x0` | **(mfim)** `result = acc` |
| `0x2C` | `00118193` | `addi x3, x3, 1` | `i++` |
| `0x30` | `fddff06f` | `jal x0, outer` | salto incondicional para `0x0C` |
| `0x34` | `ffffffff` | *(halt)* | opcode inválido &rarr; ativa **Stop** e congela a execução |

<br>

## Resultado esperado

Ao final (PC parado em `0x34` com `Stop = 1`), os registradores devem conter:

| Registrador | Valor (decimal) | Valor (hex) |
| :---: | :---: | :---: |
| `x1` (`n`) | 5 | `0x00000005` |
| **`x2` (`result`)** | **120** | **`0x00000078`** |
| `x3` (`i`) | 6 | `0x00000006` |
| `x4` (`acc`) | 120 | `0x00000078` |
| `x5` (`k`) | 5 | `0x00000005` |

O **resultado do fatorial fica em `x2` = 120 (`0x78`)**.

<br>

## Como carregar e executar?

1. Abra o `main.circ` no Logisim Evolution.
2. Clique com o botão direito na **Memória de Instruções** &rarr; **`Load Image...`** e selecione `codigos/fatorial/fatorial.txt`.
3. Ative o **Clock** (ou use a ferramenta *Poke*) e acompanhe os registradores `x1`–`x5` no banco de registradores.
4. A execução para sozinha quando o PC alcança `0x34`, onde o opcode inválido `ffffffff` ativa o sinal **Stop**.

---

<br>
<br>

## Versão para pipeline - `fatorial_pipeline.txt`

A versão acima (`fatorial.txt`) é correta no monociclo, mas não no datapath com pipeline simples, porque este não possui *forwarding*, *stall* nem *flush*. Sem esses mecanismos, é necessário inserir **`nop`** (`addi x0, x0, 0` = `0x00000013`) manualmente para cobrir o risco de *hazards*.

### Listagem comentada

```
0x00  00500093  addi x1, x0, 5
0x04  00100113  addi x2, x0, 1
0x08  00200193  addi x3, x0, 2
0x0C  00000013  nop                  # dado: aguarda x1
0x10  00000013  nop                  # dado: aguarda x3
0x14  00000013  nop                  # dado: aguarda x3
0x18  0630c463  outer: blt x1,x3,fim
0x1C  00000013  nop                  # desvio: delay slot
0x20  00000013  nop                  # desvio: delay slot
0x24  00000213  addi x4, x0, 0
0x28  00000293  addi x5, x0, 0
0x2C  00000013  nop                  # dado: aguarda x5
0x30  00000013  nop                  # dado: aguarda x5
0x34  00000013  nop                  # dado: aguarda x5
0x38  02328063  inner: beq x5,x3,mfim
0x3C  00000013  nop                  # desvio: delay slot
0x40  00000013  nop                  # desvio: delay slot
0x44  00220233  add  x4, x4, x2
0x48  00128293  addi x5, x5, 1
0x4C  fedff06f  jal x0, inner
0x50  00000013  nop                  # desvio: delay slot
0x54  00000013  nop                  # desvio: delay slot
0x58  00020133  mfim: add x2, x4, x0
0x5C  00118193  addi x3, x3, 1
0x60  fb9ff06f  jal x0, outer
0x64  00000013  nop                  # desvio: delay slot
0x68  00000013  nop                  # desvio: delay slot
0x6C  00000013  nop                  # dreno
0x70  00000013  nop                  # dreno
0x74  00000013  nop                  # dreno
0x78  00000013  nop                  # dreno
0x7C  00000013  nop                  # dreno
0x80  ffffffff  fim: halt
```
