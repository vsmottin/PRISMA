[Português](README.md) | [Español](README-es.md) | English

# Datapath - Pipeline with automatic bubbles

![Pipeline datapath with automatic bubbles](pipeline_bubble_imagem.png)

RISC-V processor implementation with a **5-stage pipeline** and **hardware data hazard detection**. As in the [simple pipeline](../pipeline/README.md), multiple instructions execute simultaneously. When an operand is not yet available, the circuit stalls instruction fetch and decode and inserts bubbles automatically.

This circuit **does not implement _forwarding_**: a dependent instruction waits for the result to be written to the register file, and instructions on the wrong path are discarded after branches and jumps.

<br>

## Stage overview

| Stage | Name | Function | Output register |
| :---: | :--- | :--- | :---: |
| **IF** | _Instruction Fetch_ | Fetches the instruction from memory and calculates the next `PC`. | `IF/ID` |
| **ID** | _Instruction Decode_ | Decodes, reads the register file and resolves branches. | `ID/EX` |
| **EX** | _Execute_ | Performs the ALU operation (arithmetic, address calculation, `jalr` target). | `EX/MEM` |
| **MEM** | _Memory_ | Accesses data memory (`lw`/`sw` and variants). | `MEM/WB` |
| **WB** | _Write-Back_ | Writes the result back to the register file. | &mdash; |

<br>

## IF stage - Instruction fetch

Fetches the instruction addressed by the `PC` and determines the address of the next instruction.

- **`PC` and [instruction memory](../../componentes/memInstrucoes/)** &mdash; provide the current instruction and the sequential address `PC + 4`.
- **Next-`PC` multiplexers** &mdash; select the sequential address, `PC_ID + imm_ID` through `Redirect_ID`, or the `jalr` target calculated in EX. `jalr` takes priority, and its address is masked with `0xFFFFFFFE` to clear the least significant bit.
- **[IF/ID register](../../componentes/estagiosPipeline/estagioIF_ID/)** &mdash; stores the instruction, `PC` and `PC + 4`. When `Flush_IF = 1`, the incoming instruction is replaced with `0x00000013` (`nop`).

The `PC` and `IF/ID` use the enable condition `NOT Stall OR Jalr_EX`: they remain frozen during a dependency but can advance to apply a `jalr` in EX. The [cycle counter](../../componentes/contadorCiclos/) keeps counting during the wait.

<br>

## ID stage - Decode and control

The stage with the most components: it decodes the instruction, reads operands and decides branches.

- **[Decoder](../../componentes/decodificador/) and [register file](../../componentes/bancoRegistradores/)** &mdash; extract instruction fields and read operands.
- **[Control unit](../../componentes/ucPrincipal/control_unit_bubble.circ)** &mdash; generates execution controls and `read_rs1`/`read_rs2`, which indicate which registers the instruction actually reads.
- **[Branch mini-ALU `idULA`](../../componentes/pipelineComponentes/idULA/) and [branch control](../../componentes/ucDesvio/)** &mdash; compare operands to decide conditional branches. The branch or `jal` target is `PC_ID + imm_ID`.
- **[Hazard detection unit](../../componentes/pipelineComponentes/hazard_detection_unit/hazard_detection_unit.circ)** &mdash; compares ID source registers with EX and MEM destination registers and generates stall and flush signals.
- **[ID/EX register with bubbles](../../componentes/estagiosPipeline/ID_EX_stage_bubble/ID_EX_stage_bubble.circ)** &mdash; receives `Bubble_ID`, selecting neutral data and controls for the next falling edge.

The `read_rs1` and `read_rs2` signals prevent false dependencies on immediate bits and are enabled according to the table below:

| Class | `read_rs1` | `read_rs2` |
| :--- | :---: | :---: |
| R-type arithmetic/logic | 1 | 1 |
| I-type arithmetic/logic, _loads_ and `jalr` | 1 | 0 |
| _Stores_ and conditional branches | 1 | 1 |
| `lui`, `auipc` and `jal` | 0 | 0 |

<br>

## EX stage - Execution

Performs the main arithmetic/logic operation.

- **Operand multiplexers** &mdash; select ALU inputs `A` and `B`:
  - `A`: `rs1`, the `PC` (for `auipc`), or `0` (for `lui`).
  - `B`: `rs2` or the immediate (`IMM`), according to `ALUSrcB`.
- **[ALU](../../componentes/ULA/)** &mdash; performs the operation (addition, subtraction, logic, shifts, comparisons) and calculates _load_/_store_ addresses and the `jalr` target (`rs1 + imm`).
- **[ALU control (`ucULA`)](../../componentes/ucULA/)** &mdash; decodes `ALUOp`, `opcode`, `funct3` and `funct7` into the 3-bit `ALUControl` (following the `funct3` encoding) and two additional ALU selectors: `subSeletor` (`add`/`sub`) and `sraiSeletor` (`srl`/`sra`).

<br>

## MEM stage - Memory access

Executes _load_ and _store_ instructions.

- **[Data memory](../../componentes/memDados/)** &mdash; uses the ALU result as the address (`end.`) and `rs2` as the data to write (`ED`). Supports _byte_, _halfword_ and _word_ accesses, with signed or unsigned reads.
- **[Addressing control (`ucEnderecamento`)](../../componentes/ucEnderecamento/)** &mdash; generates `byteEnable`, `size`, `offset` and `unsigned` from `funct3` and the address, supporting `sb`/`sh`/`sw` and `lb`/`lh`/`lw`/`lbu`/`lhu`.
- The memory write clock is also blocked by `Stop`.

<br>

## WB stage - Register write-back

Selects the value returned to the register file.

- **`MemToReg` multiplexer** &mdash; chooses between the ALU result and the data read from memory (`LD`).
- **`Jump` multiplexer** &mdash; selects `PC + 4` as the return address for `jal`/`jalr`.
- The final value goes to `wd`, with `rd` as the write address and `RegWrite` as the enable signal.

<br>

## `Stop` signal

The control unit generates `Stop` when it encounters an unrecognized `opcode`, such as `0xFFFFFFFF`. This signal blocks the clock of the `PC` (`CLK OR Stop`), data memory and counter (`CLK AND NOT Stop`).

> [!IMPORTANT]
> `Stop` does not block the pipeline registers or the register file. Allow enough cycles for the last operations to finish before the end marker, especially memory writes.

<br>

## Dependencies and automatic bubbles

A dependency exists when an instruction in EX or MEM will write a register other than `x0` that the instruction in ID needs to read. In this case, **`Stall = 1`**:

1. The `PC` and `IF/ID` retain their values.
2. `Bubble_ID` inserts a bubble into `ID/EX`, disabling writes and jumps.
3. EX, MEM and WB keep advancing until the result is available in the register file.

For example, this sequence produces two bubbles between the instructions:

```asm
addi x1, x0, 5
add  x2, x1, x1
```

The `add` remains in ID while the `addi` passes through EX and MEM. When the `addi` reaches WB, it writes `x1` and allows the `add` to advance with the updated value. The same applies to a _load_ immediately followed by a dependent instruction.

> [!NOTE]
> `Flush_IF` replaces the IF instruction with a `nop`. `Bubble_ID` selects neutral data and controls in `ID/EX`, with `opcode = 0x13` and write and jump signals disabled.

<br>

## Branches and jumps

The signals below control stalls, redirection and instruction flushing in the circuit.

```text
Redirect_ID = PCSrc_ID AND NOT Stall AND NOT Jalr_EX
Flush_IF    = Redirect_ID OR Jalr_EX
Bubble_ID   = Stall OR Jalr_EX
```

| Situation | Behavior |
| :--- | :--- |
| Branch not taken | Continues at `PC + 4`, without flushing. |
| Taken branch or `jal` in ID | Redirects to `PC_ID + imm_ID` and flushes IF: **1 bubble**. |
| Branch with pending operands | Waits in ID until the dependency is resolved. |
| `jalr` in EX | Redirects to the ALU target and flushes IF and ID: **2 bubbles**, plus any data stalls. |

A `jalr` in EX takes priority over redirection in ID and over `Stall`.

<br>

## Pipeline registers and clock

The `IF/ID`, `ID/EX`, `EX/MEM` and `MEM/WB` registers carry the data and controls needed by the following stages.

The `PC` and pipeline registers capture values on the **falling edge**; the register file and data memory write on the **rising edge**. This lets WB write a value before ID captures it in the same cycle. For more information, see [clock edges in the simple pipeline](../pipeline/README.md#bordas-de-clock).
