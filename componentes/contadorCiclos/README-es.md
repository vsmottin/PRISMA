[Português](README.md) | Español | [English](README-en.md)

# Contador de ciclos

![Circuito del Contador de Ciclos](contadorCiclos_imagem.png)

El Contador de Ciclos es el componente responsable de registrar la cantidad total de ciclos de reloj transcurridos durante la ejecución de un programa en el procesador. Incrementa su valor de forma combinacional y almacena el acumulado en un registro secuencial.

<br>

## Interfaz

| Pin | Dirección | Ancho | Descripción |
| :--- | :---: | :---: | :--- |
| `Clock` | Entrada | 1 bit | Señal de reloj del sistema (*gated* por la señal de parada). |
| `Contador` | Salida | 32 bits | Valor acumulado de ciclos totales ejecutados. |

<br>

## Funcionamiento

El módulo actúa como un acumulador simple en lazo cerrado. En su estado activo, en cada flanco de subida de la señal `Clock` recibida, el valor actual del contador se incrementa en `1` (`Contador = Contador + 1`).

### Mecanismo de parada
Aunque el circuito interno del contador es puramente un acumulador básico, el control de congelamiento del conteo se realiza de forma externa en la unidad superior (`main.circ`). 

Para pausar el conteo cuando el programa finaliza o alcanza una condición de parada:
1. La unidad de control principal (`ucPrincipal`) activa la señal **`Stop`** al identificar una instrucción de parada o un opcode inválido.
2. Una compuerta lógica AND externa realiza la operación `CLK & !Stop`.
3. Cuando `Stop` es `1`, la salida de la compuerta AND se fuerza a `0`, congelando la señal de reloj que alimenta el registro del contador. Esto impide nuevas actualizaciones y mantiene el valor del conteo congelado en su último estado.

<br>

## Implementación

Para el montaje de este circuito en Logisim, se utilizan bloques orientados a la lógica secuencial y combinacional básica:

- **Sumador:** circuito que suma continuamente la constante `1` al valor actual del contador proveniente del registro.
-   **Registro:** componente que almacena el conteo actualizado. Su entrada `D` recibe el resultado del sumador, y su salida `Q` alimenta simultáneamente al propio sumador y al pin de salida `Contador`.