[Português](README.md) | Español | [English](README-en.md)

# Banco de Registros

El banco de registros almacena los 32 registros de propósito general (`x0` a `x31`) de la arquitectura RISC-V, cada uno de 32 bits. Dispone de **dos puertos de lectura** independientes y asíncronos (para proporcionar los operandos de la ALU) y **un puerto de escritura** síncrono (controlado por el reloj), lo que permite al procesador leer dos registros y escribir en un tercero dentro del mismo ciclo.

![Circuito del banco de registros](bancoRegistradores_imagem.png)

<br>

## Interfaz

| Pin | Dirección | Ancho | Descripción |
| :--- | :---: | :---: | :--- |
| `LR1` | Entrada | 5 bits | Dirección del primer registro que se desea leer (*read register 1*). |
| `LR2` | Entrada | 5 bits | Dirección del segundo registro que se desea leer (*read register 2*). |
| `WR` | Entrada | 5 bits | Dirección del registro de destino de la escritura (*write register*). |
| `WD` | Entrada | 32 bits | Dato que se escribe en el registro de destino (*write data*). |
| `RegWrite` | Entrada | 1 bit | Habilita la escritura (`1` para escribir, `0` para solo leer). |
| `clk` | Entrada | 1 bit | Señal de reloj del sistema; sincroniza el puerto de escritura. |
| `LD1` | Salida | 32 bits | Contenido del registro indicado por `LR1` (*read data 1*). |
| `LD2` | Salida | 32 bits | Contenido del registro indicado por `LR2` (*read data 2*). |

<br>

## Funcionamiento

El banco utiliza lecturas combinacionales y escritura sincronizada por el reloj, de la siguiente manera:

### 1. Lectura (asíncrona)

Los dos puertos de lectura son puramente combinacionales: el contenido de los 32 registros está siempre disponible en las entradas de dos **multiplexores de 32 bits**. Cada multiplexor utiliza una dirección de lectura como selector:

- `LR1` selecciona el registro que se envía a la salida `LD1`.
- `LR2` selecciona el registro que se envía a la salida `LD2`.

Como la lectura no depende del reloj, los operandos están disponibles en cuanto se estabilizan las direcciones.

<br>

### 2. Escritura (síncrona)

La escritura ocurre únicamente en el flanco de subida de `clk` y solo cuando `RegWrite = 1`. Para garantizar que **solo se modifique el registro indicado**, el circuito utiliza la dirección `WR` como selector de **dos demultiplexores** simultáneamente:

- Un demultiplexor de **32 bits** dirige el dato `WD` a la entrada `D` del registro de destino.
- Un demultiplexor de **1 bit** dirige la señal `RegWrite` a la entrada de habilitación de escritura (`WE`) de ese mismo registro.

Así, en el flanco de reloj, solo el registro cuya entrada `WE` está habilitada captura el valor de `WD`; todos los demás conservan su valor anterior.

> [!IMPORTANT]
> En el [datapath con pipeline](../../datapaths/pipeline/), los [registros de etapa](../estagiosPipeline/) escriben en el flanco de **bajada**, opuesto al del banco. La escritura de WB ocurre, por tanto, a mitad del ciclo, y la instrucción que está en ID durante ese mismo ciclo ya puede leer el valor actualizado.

> [!NOTE]
> El registro `x0` está fijado en cero, según la especificación RISC-V. Cualquier lectura de esta dirección devuelve `0` y los intentos de escritura no tienen efecto, ya que su valor se mantiene constante.

<br>

## Implementación

El circuito se construye con los siguientes bloques de Logisim:

- **Registros:** 32 unidades de 32 bits, cada una con entrada de datos `D`, salida `Q`, habilitación de escritura `WE` y reinicio `R`, todas sincronizadas por `clk`.
- **Demultiplexores:** dos bloques con selector de 5 bits (`WR`): uno de 32 bits, que dirige `WD` al registro correcto, y otro de 1 bit, que dirige `RegWrite` al `WE` correspondiente.
- **Multiplexores:** dos bloques de 32 bits con selectores de 5 bits (`LR1` y `LR2`), que envían el contenido de los registros seleccionados a las salidas `LD1` y `LD2`.
- **Constante (`x0`):** una constante de 32 bits con valor `0` se conecta a la entrada `D` del registro 0, fijando su contenido en cero. Como la salida `Q` de este registro alimenta la entrada `0` de los dos multiplexores de lectura, cualquier lectura de la dirección `0` devuelve `0`.
- **Distribución del reloj:** la señal `clk` se distribuye a los 32 registros, garantizando la escritura síncrona en todo el banco.
