[Português](README.md) | Español | [English](README-en.md)

# Unidad de control de salto

![Circuito de la Unidad de Control de Salto](ucDesvio_imagem.png)

La Unidad de Control de Salto (`ucDesvio`) es el componente encargado de evaluar si las condiciones de los saltos condicionales (*branches*) han sido satisfechas. Analiza la bandera de comparación generada por la ALU y el campo `funct3` de la instrucción, determinando si el flujo del programa debe realizar el salto condicional.

<br>

## Interfaz

| Pin | Dirección | Ancho | Descripción |
| :--- | :---: | :---: | :--- |
| `Zero` | Entrada | 1 bit | Indicador de igualdad/comparación proveniente de la ALU. |
| `funct3` | Entrada | 3 bits | Campo de la instrucción que identifica el tipo de comparación del salto. |
| `BranchSrc` | Salida | 1 bit | Indica si la condición del salto fue cumplida (`1`) o no (`0`). |

<br>

## Tabla de mapeo de condiciones

La siguiente tabla describe cómo se decodifica el campo `funct3` para verificar la respectiva condición a través de la señal `Zero` generada por la ALU:

| funct3 | Instrucción | Comparación | Condición del salto |
| :---: | :--- | :---: | :---: |
| `000` | `beq` (Branch Equal) | `A == B` (vía resta) | `Zero == 1` |
| `001` | `bne` (Branch Not Equal) | `A != B` (vía resta) | `Zero == 0` |
| `100` | `blt` (Branch Less Than) | `A < B` (con signo) | `Zero == 0` |
| `101` | `bge` (Branch Greater or Equal) | `A >= B` (con signo) | `Zero == 1` |
| `110` | `bltu` (Branch Less Than *Unsigned*) | `A < B` (sin signo) | `Zero == 0` |
| `111` | `bgeu` (Branch Greater or Equal *Unsigned*) | `A >= B` (sin signo) | `Zero == 1` |

<br>

## Funcionamiento

La unidad de salto no realiza cálculos matemáticos directamente. En su lugar, actúa sobre los resultados de las operaciones preparadas previamente por la unidad de control de la ALU para ejecutarse en la ALU.

### Lógica de comparación por resta (`beq` / `bne`)
Para verificar igualdad o diferencia, la ALU realiza la operación de resta (`A - B`).
-   **`beq`:** Si `A - B == 0`, la bandera `Zero` de la ALU se vuelve `1`. El salto debe ocurrir, por lo tanto `BranchSrc = 1`.
-   **`bne`:** Si `A - B != 0`, la bandera `Zero` de la ALU permanece en `0`. El salto debe ocurrir, por lo tanto `BranchSrc = 1`.

### Lógica de comparación menor que (`blt` / `bge` / `bltu` / `bgeu`)
Para saltos basados en menor que o mayor o igual, la ALU ejecuta la operación de comparación *Set Less Than* (`slt` o `sltu`).
-   Si la condición `A < B` es **verdadera**, la ALU emite el resultado de 32 bits `1` (diferente de cero), haciendo que la bandera `Zero` sea `0`.
-   Si la condición `A < B` es **falsa** (lo que implica `A >= B`), la ALU emite el resultado `0` (igual a cero), activando la bandera `Zero` a `1`.

De esta forma:
-   **`blt` / `bltu`:** Salto si es menor que. Ocurre cuando la comparación es verdadera, es decir, `Zero == 0`.
-   **`bge` / `bgeu`:** Salto si es mayor o igual. Ocurre cuando la comparación es falsa, es decir, `Zero == 1`.

<br>

## Implementación

La unidad está compuesta por lógica estrictamente combinacional y por los siguientes bloques:

- **Decodificadores / compuertas lógicas:** identifican cada uno de los 6 patrones de `funct3`.
- **Compuertas de validación condicional:** combinan la identificación del `funct3` correspondiente con la señal `Zero` (de forma directa o invertida por compuertas NOT).
- **Compuerta OR final:** consolida los 6 caminos de comparación. Si cualquiera de las condiciones decodificadas se satisface, el pin de salida `BranchSrc` se define en `1`.