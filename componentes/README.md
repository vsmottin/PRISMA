# Componentes
Este diretório reúne todos os blocos funcionais que compõem os _datapaths_ do processador. Cada bloco é um circuito independente, montado e testado isoladamente, que depois é importado como biblioteca pelos [_`datapaths`_](../datapaths/).

> [!IMPORTANT]
> Antes de criar ou alterar um componente, consulte **[`CONVENCOES.md`](../CONVENCOES.md)**.

<br>

## Organização do diretório
```
componentes/
└── <componente>/                    # blocos usados nos datapaths
   ├── <componente>.circ             # circuito do componente
   ├── <componente>_imagem.png       # imagem do circuito
   └── README.md                     # manual do circuito 

```

<br>

## Componentes
| Componente | Função |
| :--- | :--- |
| [ULA](ULA/README.md) | Unidade Lógica e Aritmética: soma, subtração, lógicas, deslocamentos e comparações. |
| [ucULA](ucULA/README.md) | Unidade de controle da ULA: traduz `ALUOp` + `opcode`/`funct3`/`funct7` no `ALUControl` (ordem `funct3`) e nos seletores `subSeletor`/`sraiSeletor`. |
| [ucPrincipal](ucPrincipal/README.md) | Unidade de controle principal: gera os sinais de controle a partir do `opcode`. |
| [ucDesvio](ucDesvio/README.md) | Unidade de controle de desvios (_branches_): decide se o desvio é tomado. |
| [ucEnderecamento](ucEnderecamento/README.md) | Unidade de controle de endereçamento: define tamanho e alinhamento dos acessos à memória. |
| [bancoRegistradores](bancoRegistradores/README.md) | Banco com os 32 registradores de 32 bits. |
| [contadorCiclos](contadorCiclos/README.md) | Contador dos ciclos de _clock_ executados. |
| [decodificador](decodificador/README.md) | Decodificador da instrução: separa os campos e monta o imediato. |
| [extensores](extensores/README.md) | Extensores de sinal e de zero (usados dentro de outros componentes). |
| [memInstrucoes](memInstrucoes/README.md) | Memória de instruções (ROM). |
| [memDados](memDados/README.md) | Memória de dados (RAM). |
| [zero](zero/README.md) | Sinalizador de resultado nulo da ULA. |

<br>

## Componentes exclusivos do _pipeline_
| Diretório (manual) | Função |
| :--- | :--- |
| [estagiosPipeline](estagiosPipeline/README.md) | Os quatro **registradores de estágio** (`IF/ID`, `ID/EX`, `EX/MEM`, `MEM/WB`) que separam as etapas do _pipeline_. |
| [pipelineComponentes/idULA](pipelineComponentes/idULA/README.md) | Mini-ULA que resolve os desvios já no estágio **ID**, reduzindo a penalidade de _branch_. |

<br>

## Como reaproveitar um componente
1. Abra qualquer circuito de [`datapaths/`](../datapaths/) no Logisim-Evolution.
2. Vá em `Project` &rarr; `Load Library` &rarr; `Logisim Library...` e escolha o caminho de dados desejado.
3. O componente passa a aparecer na árvore do projeto (painel esquerdo) e pode ser arrastado para a área de trabalho como qualquer peça nativa.

> [!NOTE]
> As bibliotecas são referenciadas por caminho relativo dentro de cada _datapath_ (por exemplo, `../../componentes/ULA/ULA.circ`). Renomear ou mover um diretório de componente quebra o carregamento nos _datapaths_. **Se precisar mover algo, recarregue a biblioteca pelo menu acima.**
