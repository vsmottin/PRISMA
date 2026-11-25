[Português](README.md) | [Español](README-es.md) | English

# Components

This directory contains all the functional blocks that make up the processor's _datapaths_. Each block is an independent circuit, built and tested in isolation, which is then imported as a library by the [_datapaths_](../datapaths/README-en.md).

> [!IMPORTANT]
> Before creating or modifying a component, consult **[`CONVENTIONS.md`](../CONVENTIONS.md)**.

<br>

## Directory organization

```
componentes/
└── <component>/                    # blocks used in the datapaths
   ├── <component>.circ             # component circuit
   ├── <component>_imagem.png       # circuit image
   └── README.md                    # circuit manual
```

<br>

## Components

| Component | Function |
| :--- | :--- |
| [ULA](ULA/README.md) | Arithmetic and logic unit (ALU): addition, subtraction, logic operations, shifts and comparisons. |
| [ucULA](ucULA/README.md) | ALU control unit: translates `ALUOp` + `opcode`/`funct3`/`funct7` into `ALUControl` (following the `funct3` encoding) and the `subSeletor`/`sraiSeletor` selectors. |
| [ucPrincipal](ucPrincipal/README.md) | Main control unit: generates control signals from the `opcode`. |
| [ucDesvio](ucDesvio/README.md) | Branch control unit: decides whether a branch is taken. |
| [ucEnderecamento](ucEnderecamento/README.md) | Addressing control unit: defines the size and alignment of memory accesses. |
| [bancoRegistradores](bancoRegistradores/README.md) | Register file with 32 registers of 32 bits each. |
| [contadorCiclos](contadorCiclos/README.md) | Counter of executed clock cycles. |
| [decodificador](decodificador/README.md) | Instruction decoder: separates the fields and assembles the immediate. |
| [extensores](extensores/README.md) | Sign and zero extenders (used inside other components). |
| [memInstrucoes](memInstrucoes/README.md) | Instruction memory (ROM). |
| [memDados](memDados/README.md) | Data memory (RAM). |
| [zero](zero/README.md) | ALU zero-result flag. |

<br>

## Pipeline-specific components

| Directory (manual) | Function |
| :--- | :--- |
| [estagiosPipeline](estagiosPipeline/README.md) | The four **stage registers** (`IF/ID`, `ID/EX`, `EX/MEM`, `MEM/WB`) that separate the pipeline stages. |
| [pipelineComponentes/idULA](pipelineComponentes/idULA/README.md) | Mini-ALU that resolves branches in the **ID** stage, reducing the branch penalty. |
| [pipelineComponentes/ucConflitos](pipelineComponentes/ucConflitos/README.md) | Hazard detection unit: stalls the pipeline only when forwarding cannot help (load followed by use and dependent branch in ID) and controls the flush on branches and jumps. |

<br>

## How to reuse a component

1. Open any circuit from [`datapaths/`](../datapaths/README-en.md) in Logisim-Evolution.
2. Go to `Project` &rarr; `Load Library` &rarr; `Logisim Library...` and select the desired datapath.
3. The component appears in the project tree (left panel) and can be dragged onto the workspace like any built-in component.

> [!NOTE]
> Libraries are referenced by relative paths inside each datapath (for example, `../../componentes/ULA/ULA.circ`). Renaming or moving a component directory prevents the datapaths from loading it. **If you need to move anything, reload the library using the menu above.**
