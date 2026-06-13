# Contador de Ciclos

![Circuito do Contador de Ciclos](contadorCiclos_imagem.png)

O contador de ciclos é responsável por registrar a quantidade total de ciclos de _clock_ decorridos durante a execução de um programa no _datapath_. Ele incrementa o seu valor continuamente a cada ciclo, desde que o fluxo do programa esteja operando de maneira normal.

O controle de execução é feito recebendo o sinal de `Clock` do sistema e o sinal `Stop`, sendo este último gerado pela unidade de controle ao identificar um _opcode_ inválido.

## Interface
| Pino | Direção | Largura | Descrição |
| --- | --- | --- | --- |
| `Clock` | Entrada | 1 bit | Sinal de _clock_ do sistema. |
| `Contador` | Saída | 32 bits | Valor atual do número de ciclos totais executados. |


## Funcionamento
O módulo de contagem atua como um acumulador simples em malha fechada. Em seu funcionamento normal, o somador recebe o valor do próprio contador armazenado no registrador e soma com a constante de valor lógico `1`.

A decisão de registrar esse novo incremento ou congelar a contagem depende exclusivamente da entrada de `Clock` do registrador. Existe uma operação lógica AND entre o sinal de `Clock` externo e o sinal negado de `Stop`, controlando a atualização do componente:

- **Operação contínua**
    - Se `Stop == 0` (falso), a negação se torna `1`, permitindo que o `Clock` atravesse a porta AND. Na próxima borda de subida, o registrador salva o novo valor incrementado. Logo, `Contador = Contador + 1`.


- **Condição de parada**
    - Se `Stop == 1` (verdadeiro), um _opcode_ inválido foi identificado. A negação se torna `0`, o que força a saída da porta AND para `0`. Sem receber o pulso do _clock_, o registrador para de atualizar, mantendo o valor do `Contador` intacto no estado em que parou.



## Implementação
Internamente, o contador possui lógica sequencial e combinacional básica, fechando um laço de repetição constante.

Blocos usados:
- **Somador**
    - Circuito combinacional que tem como entrada superior a constante `00000001` e como entrada inferior o valor de `Q` do registrador. Retorna continuamente o valor atual somado em 1.


- **Registrador**
    - Módulo sequencial que armazena o valor atualizado da contagem. Sua entrada `D` recebe o resultado do somador, e sua saída `Q` alimenta simultaneamente o próprio somador e o bloco de saída.