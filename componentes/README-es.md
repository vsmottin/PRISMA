[Português](README.md) | Español | [English](README-en.md)

# Componentes

Este directorio reúne todos los bloques funcionales que componen los _datapaths_ del procesador. Cada bloque es un circuito independiente, construido y probado de forma aislada, que después se importa como biblioteca desde los [_datapaths_](../datapaths/README-es.md).

> [!IMPORTANT]
> Antes de crear o modificar un componente, consulte **[`CONVENTIONS.md`](../CONVENTIONS.md)**.

<br>

## Organización del directorio

```
componentes/
└── <componente>/                    # bloques utilizados en los datapaths
   ├── <componente>.circ             # circuito del componente
   ├── <componente>_imagem.png       # imagen del circuito
   └── README.md                     # manual del circuito
```

<br>

## Componentes

| Componente | Función |
| :--- | :--- |
| [ULA](ULA/README.md) | Unidad aritmética y lógica (ALU): suma, resta, operaciones lógicas, desplazamientos y comparaciones. |
| [ucULA](ucULA/README.md) | Unidad de control de la ALU: traduce `ALUOp` + `opcode`/`funct3`/`funct7` a `ALUControl` (según la codificación de `funct3`) y a los selectores `subSeletor`/`sraiSeletor`. |
| [ucPrincipal](ucPrincipal/README.md) | Unidad de control principal: genera las señales de control a partir del `opcode`. |
| [ucDesvio](ucDesvio/README.md) | Unidad de control de bifurcaciones: decide si se toma una bifurcación. |
| [ucEnderecamento](ucEnderecamento/README.md) | Unidad de control de direccionamiento: define el tamaño y la alineación de los accesos a memoria. |
| [bancoRegistradores](bancoRegistradores/README.md) | Banco con 32 registros de 32 bits. |
| [contadorCiclos](contadorCiclos/README.md) | Contador de los ciclos de reloj ejecutados. |
| [decodificador](decodificador/README.md) | Decodificador de instrucciones: separa los campos y construye el inmediato. |
| [extensores](extensores/README.md) | Extensores de signo y de cero (utilizados dentro de otros componentes). |
| [memInstrucoes](memInstrucoes/README.md) | Memoria de instrucciones (ROM). |
| [memDados](memDados/README.md) | Memoria de datos (RAM). |
| [zero](zero/README.md) | Indicador de resultado cero de la ALU. |

<br>

## Componentes exclusivos del pipeline

| Directorio (manual) | Función |
| :--- | :--- |
| [estagiosPipeline](estagiosPipeline/README.md) | Los cuatro **registros de etapa** (`IF/ID`, `ID/EX`, `EX/MEM`, `MEM/WB`) que separan las etapas del pipeline. |
| [pipelineComponentes/idULA](pipelineComponentes/idULA/README.md) | Mini-ALU que resuelve las bifurcaciones en la etapa **ID**, reduciendo la penalización de bifurcación. |

<br>

## Cómo reutilizar un componente

1. Abra cualquier circuito de [`datapaths/`](../datapaths/README-es.md) en Logisim-Evolution.
2. Vaya a `Project` &rarr; `Load Library` &rarr; `Logisim Library...` y seleccione el datapath deseado.
3. El componente aparece en el árbol del proyecto (panel izquierdo) y puede arrastrarse al área de trabajo como cualquier componente integrado.

> [!NOTE]
> Las bibliotecas se referencian mediante rutas relativas dentro de cada datapath (por ejemplo, `../../componentes/ULA/ULA.circ`). Renombrar o mover un directorio de componente impide que los datapaths lo carguen. **Si necesita mover algo, vuelva a cargar la biblioteca mediante el menú anterior.**
