[Português](README.md) | Español | [English](README-en.md)

# Proyecto PRISMA
![Logisim_Evolution](https://img.shields.io/badge/Logisim_Evolution-006039) ![RISC-V](https://img.shields.io/badge/RISC--V-2C2C2C)

El Proyecto PRISMA (Procesador RISC-V Interactivo para Simulación y Modelado de Arquitectura) fue creado con el propósito de implementar versiones de datapath (camino de datos) para la arquitectura **RISC-V** en **Logisim Evolution**.

El proyecto está construido de forma modular: cada bloque funcional (ALU, banco de registros, unidades de control, etc.) tiene su propio directorio dentro de [`componentes/`](componentes/), que contiene el archivo `.circ`, un esquemático del circuito y un `README-es.md` que documenta su interfaz, funcionamiento e implementación. Construidos sobre estos bloques, los circuitos completos en [`datapaths/`](datapaths/) los importan como bibliotecas.

## Estructura

```
risc-v/
├── datapaths/                        # Procesadores
│   ├── monociclo/                    # Ciclo único
│   └── pipeline/                     # 5 etapas
│
├── componentes/                      # Un directorio por bloque funcional
│   └── <componente>/
│       ├── <componente>.circ         # Circuito del componente
│       └── README-es.md              # Manual: interfaz, funcionamiento e implementación
│
├── codigos/                          # Programas en código máquina para pruebas
├── CONVENCOES.md                     # Reglas de montaje y documentación de los circuitos
├── LICENSE.md                        # Licencia para uso, copia, modificación y distribución
├── logisim-evolution-4.1.0-all.jar   # Versión recomendada de Logisim Evolution
└── RISCV_CARD.pdf                    # Tarjeta de referencia de la ISA RISC-V
```

## Datapaths
Cada datapath tiene su propio manual que detalla sus etapas, los componentes utilizados y el recorrido de las señales.

| Datapath | Descripción |
| :--- | :--- |
| [monociclo](datapaths/monociclo/README-es.md) | Cada instrucción se busca, ejecuta y completa en un **único** ciclo de reloj. Esta es la versión más simple y sirve como base para el pipeline. |
| [pipeline](datapaths/pipeline/README-es.md) | La ejecución se divide en **5 etapas simultáneas**. |

### Componentes
Cada componente también tiene su propio manual que cubre su interfaz, funcionamiento e implementación.

| Componente | Función |
| :--- | :--- |
| [ULA](componentes/ULA/README-es.md) | Unidad Lógica y Aritmética (ALU). |
| [ucULA](componentes/ucULA/README-es.md) | Unidad de control de la ALU (selecciona la operación). |
| [ucPrincipal](componentes/ucPrincipal/README-es.md) | Unidad de control principal (genera las señales de control). |
| [ucDesvio](componentes/ucDesvio/README-es.md) | Unidad de control de saltos. |
| [ucEnderecamento](componentes/ucEnderecamento/README-es.md) | Unidad de control de direccionamiento. |
| [bancoRegistradores](componentes/bancoRegistradores/README-es.md) | Banco de registros / Archivo de registros. |
| [contadorCiclos](componentes/contadorCiclos/README-es.md) | Contador de ciclos del Contador de Programa (PC). |
| [decodificador](componentes/decodificador/README-es.md) | Decodificador de instrucciones. |
| [extensores](componentes/extensores/README-es.md) | Extensores de signo y de cero. |
| [memInstrucoes](componentes/memInstrucoes/README-es.md) | Memoria de instrucciones. |
| [memDados](componentes/memDados/README-es.md) | Memoria de datos. |
| [zero](componentes/zero/README-es.md) | Bandera de cero de la ALU. |
| [estagiosPipeline](componentes/estagiosPipeline/README-es.md) | Los cuatro registros de etapa del pipeline (`IF/ID`, `ID/EX`, `EX/MEM`, `MEM/WB`). |
| [idULA](componentes/pipelineComponentes/idULA/README-es.md) | Mini-ALU dedicada a la resolución de saltos en la etapa de decodificación. |

## Convenciones
Los estándares de construcción y documentación de los circuitos —como **convenciones de nomenclatura**, **ubicación de pines**, **uso y nombrado de túneles** y **estándares de los READMEs**— están reunidos en **[`CONVENCOES.md`](CONVENCOES.md)** (en portugués, *convenciones*).

## Ejecución
El archivo `.jar` de Logisim Evolution está incluido en la raíz del proyecto. Asegúrese de tener **Java (JRE/JDK)** instalado. Abra la terminal en el directorio raíz y ejecute:

```bash
java -jar logisim-evolution-4.1.0-all.jar
```

### Dentro de Logisim

1. Con Logisim abierto, haga clic en **`File` → `Open...`**.
2. Seleccione el circuito del datapath deseado. Los componentes en `componentes/` se cargan automáticamente como bibliotecas.
3. Para probar el procesador, cargue un programa en la memoria:
   - Haga clic derecho sobre el componente **Memória de Instruções** (Memoria de Instrucciones).
   - Seleccione **`Load Image...`**.
   - Elija uno de los archivos de prueba del directorio [`codigos/`](codigos/).
4. Utilice la herramienta **`Poke`** (ícono de la mano) o active el **Clock** para seguir la ejecución de las instrucciones a través del datapath.

> [!NOTE]
> Los archivos de prueba en [`codigos/`](codigos/) con el prefijo `teste_pipeline_` ya incluyen las burbujas (`nop`) requeridas por el pipeline, el cual no cuenta con adelantamiento (*forwarding*) ni detección de riesgos (*hazard detection*). Dado que `nop` es una instrucción válida, estos mismos archivos también pueden ejecutarse en el procesador monociclo, consumiendo únicamente ciclos adicionales.

Este proyecto está bajo la Licencia MIT – consulte el archivo LICENSE para más detalles.