[Português](README.md) | Español | [English](README-en.md)

# Datapaths

Este directorio contiene las implementaciones completas del camino de datos (_datapath_) del procesador RISC-V. Cada subdirectorio es una **arquitectura diferente** que ejecuta el mismo conjunto de instrucciones mediante distintas estrategias de ejecución.

<br>

## Implementaciones

| Datapath | Descripción |
| :--- | :--- |
| [monociclo](monociclo/README.md) | Implementación de ciclo único: cada instrucción se busca, decodifica, ejecuta y completa dentro de **un** ciclo de reloj. |
| [pipeline](pipeline/README.md) | Implementación de **5 etapas**: la ejecución se divide en etapas que operan simultáneamente sobre instrucciones diferentes, aumentando el rendimiento. |
| [pipeline_bubble](pipeline_bubble/README-es.md) | Implementación de **5 etapas** con detección de dependencias e inserción automática de burbujas, sin forwarding. |

<br>

## Estructura de cada implementación

```
<datapath>/
├── main.circ                 # circuito completo que se abre en Logisim
├── <datapath>_imagem.png     # imagen del datapath montado
└── README.md                 # manual: etapas, componentes y señales
```
