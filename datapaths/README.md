# Datapaths

Este diretório contém as implementações completas do caminho de dados (_datapath_) do processador RISC-V. Cada subdiretório é uma **arquitetura diferente** que executa o mesmo conjunto de instruções com tratamentos diferentes.

<br>

## Implementações

| _Datapath_ | Descrição |
| :--- | :--- |
| [monociclo](monociclo/README.md) | Implementação ciclo único: cada instrução é buscada, decodificada, executada e finalizada dentro de **um** ciclo de _clock_. |
| [pipeline](pipeline/README.md) | Implementação em **5 estágios**: a execução é dividida em etapas que operam simultaneamente sobre instruções diferentes, aumentando a vazão. |

<br>

## Estrutura de cada implementação

```
<datapath>/
├── main.circ                 # circuito completo, a ser aberto no Logisim
├── <datapath>_imagem.png     # imagem do datapath montado
└── README.md                 # manual: estágios/etapas, componentes e sinais
```
