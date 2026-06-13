# Zero

![Circuito do Zero](zero_imagem.png)

O Zero é um componente interno da unidade lógica e aritmética (ULA) responsável por verificar se o resultado da operação atual é igual a zero. Ele atua como uma _flag_ de condição, sendo fundamental para o _datapath_ lidar com instruções de desvio condicional.

## Interface
| Pino | Direção | Largura | Descrição |
| --- | --- | --- | --- |
| `Result` | Entrada | 32 bits | Resultado final da operação calculada pela ULA. |
| `Zero` | Saída | 1 bit | Sinal que indica se o resultado recebido é nulo (`1`) ou não nulo (`0`). |

## Funcionamento
A decisão de ativar ou desativar o sinal de saída baseia-se exclusivamente no teste de igualdade do comparador:

- **Resultado Nulo**
    - Se `Result == 0`, todos os bits que compõem o valor estão em nível lógico baixo. A condição do comparador é perfeitamente satisfeita, fazendo com que a saída seja ativada. Logo, `Zero = 1`.

- **Resultado Não Nulo**
    - Se `Result != 0`, pelo menos um bit no barramento possui valor lógico alto. A condição de igualdade falha, fazendo com que a saída do comparador seja desativada. Logo, `Zero = 0`.



## Implementação
Internamente, o módulo Zero é composto puramente por lógica combinacional, sem necessidade de sinais de controle de estado ou pulso de _clock_, gerando a resposta assim que o resultado da operação realizada na ULA é calculado.

Blocos usados:
- **Comparador**
    - Circuito responsável pela operação. Possui em sua entrada superior a constante `00000000` e na entrada inferior, `Result`. Ele avalia a condição de igualdade (`=`) e emite a resposta booleana diretamente para o pino de saída `Zero`.