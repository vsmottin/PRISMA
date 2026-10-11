# PRISMA Project
![Logisim_Evolution](https://img.shields.io/badge/Logisim_Evolution-006039) ![RISC-V](https://img.shields.io/badge/RISC--V-2C2C2C)

The PRISMA Project (Interactive RISC-V Processor for Architecture Simulation and Modeling) was created for the purpose of implementing datapath versions for the **RISC-V** architecture in **Logisim Evolution**.

The project is built modularly: each functional block (ALU, register bank, control units, etc.) has its own directory inside [`componentes/`](componentes/) (Portuguese for *components*), containing the `.circ` file, a circuit schematic, and a `README.md` documenting its interface, operation, and implementation. Built on top of these blocks, the complete circuits in [`datapaths/`](datapaths/) import them as libraries.

## Structure

```

risc-v/
├── datapaths/                        # Processors
│   ├── monociclo/                    # Single-cycle
│   └── pipeline/                     # 5 stages
│
├── componentes/                      # One directory per functional block
│   └── /
│       ├── .circ         # Component circuit
│       └── README.md                 # Manual: interface, operation, and implementation
│
├── codigos/                          # Machine code programs for testing
├── CONVENCOES.md                     # Assembly rules and circuit documentation
├── LICENSE.md                        # License for use, copying, modification, and distribution
├── logisim-evolution-4.1.0-all.jar   # Recommended Logisim Evolution version
└── RISCV_CARD.pdf                    # RISC-V ISA reference card

```

## Datapaths
Each datapath has its own manual detailing its stages, components used, and signal path.

| Datapath | Description |
| :--- | :--- |
| [monociclo](datapaths/monociclo/README.md) | Each instruction is fetched, executed, and completed in a **single** clock cycle. This is the simplest version and serves as the baseline for the pipeline. |
| [pipeline](datapaths/pipeline/README.md) | Execution is divided across **5 simultaneous stages**. |

### Components
Each component also has its own manual covering its interface, operation, and implementation.

| Component | Function |
| :--- | :--- |
| [ULA](componentes/ULA/README.md) | Arithmetic Logic Unit (ALU). |
| [ucULA](componentes/ucULA/README.md) | ALU control unit (selects the operation). |
| [ucPrincipal](componentes/ucPrincipal/README.md) | Main control unit (generates control signals). |
| [ucDesvio](componentes/ucDesvio/README.md) | Branch control unit. |
| [ucEnderecamento](componentes/ucEnderecamento/README.md) | Addressing control unit. |
| [bancoRegistradores](componentes/bancoRegistradores/README.md) | Register bank / Register file. |
| [contadorCiclos](componentes/contadorCiclos/README.md) | Program Counter (PC) cycle counter. |
| [decodificador](componentes/decodificador/README.md) | Instruction decoder. |
| [extensores](componentes/extensores/README.md) | Sign and zero extenders. |
| [memInstrucoes](componentes/memInstrucoes/README.md) | Instruction memory. |
| [memDados](componentes/memDados/README.md) | Data memory. |
| [zero](componentes/zero/README.md) | ALU zero flag. |
| [estagiosPipeline](componentes/estagiosPipeline/README.md) | The four pipeline stage registers (`IF/ID`, `ID/EX`, `EX/MEM`, `MEM/WB`). |
| [idULA](componentes/pipelineComponentes/idULA/README.md) | Dedicated mini-ALU for branch resolution in the decode stage. |

## Conventions
Circuit construction and documentation standards—such as **naming conventions**, **pin placement**, **tunnel usage and naming**, and **README standards**—are gathered in **[`CONVENCOES.md`](CONVENCOES.md)** (Portuguese for *conventions*).

## Execution
The Logisim Evolution `.jar` is included in the project root. Make sure you have **Java (JRE/JDK)** installed. Open the terminal in the root directory and run:

```bash
java -jar logisim-evolution-4.1.0-all.jar

```

### Inside Logisim

1. With Logisim open, click on **`File` → `Open...**`.
2. Select the desired datapath circuit. The components in `componentes/` are automatically loaded as libraries.
3. To test the processor, load a program into memory:
* Right-click on the **Memória de Instruções** component (Instruction Memory).
* Select **`Load Image...`**.
* Choose one of the test files from the [`codigos/`](https://www.google.com/search?q=codigos/) directory.


4. Use the **`Poke`** tool (hand icon) or activate the **Clock** to trace instruction execution across the datapath.

> [!NOTE]
> Test files in [`codigos/`](https://www.google.com/search?q=codigos/) prefixed with `teste_pipeline_` already include the bubbles (`nop`) required by the pipeline, which does not have forwarding or hazard detection. Since `nop` is a valid instruction, these same files can also run on the single-cycle processor, merely consuming extra cycles.

This project is licensed under the MIT License – see the LICENSE file for details.
