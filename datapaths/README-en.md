[Português](README.md) | [Español](README-es.md) | English

# Datapaths

This directory contains the complete datapath implementations of the RISC-V processor. Each subdirectory is a **different architecture** that executes the same instruction set using different execution strategies.

<br>

## Implementations

| Datapath | Description |
| :--- | :--- |
| [monociclo](monociclo/README.md) | Single-cycle implementation: each instruction is fetched, decoded, executed and completed within **one** clock cycle. |
| [pipeline](pipeline/README.md) | **5-stage** implementation: execution is divided into stages that operate simultaneously on different instructions, increasing throughput. |
| [pipeline_bubble](pipeline_bubble/README-en.md) | **5-stage** implementation with dependency detection and automatic bubble insertion, without forwarding. |
| [pipelineEncaminhamentoBolhas](pipelineEncaminhamentoBolhas/README-en.md) | **5-stage** pipeline with **forwarding** and **automatic bubbles**: bubbles are inserted only when forwarding cannot resolve the hazard (load followed by use and dependent branch in ID). |

<br>

## Structure of each implementation

```
<datapath>/
├── main.circ                 # complete circuit to open in Logisim
├── <datapath>_imagem.png     # image of the assembled datapath
└── README.md                 # manual: stages, components and signals
```
