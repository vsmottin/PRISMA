# Projeto PRISMA
![Logisim_Evolution](https://img.shields.io/badge/Logisim_Evolution-006039) ![RISC-V](https://img.shields.io/badge/RISC--V-2C2C2C)

O Projeto PRISMA (Processador RISC-V Interativo para Simulação e Modelagem de Arquitetura) foi criado com o propósito de implementar versões de um _datapath_ (caminho de dados) para a arquitetura **RISC-V** usando a ferramenta **Logisim Evolution**.

O projeto é montado de forma modular: cada bloco funcional (ULA, banco de registradores, unidades de controle, etc.) tem seu próprio diretório dentro de [`componentes/`](componentes/), com o arquivo `.circ`, a imagem do circuito e um `README.md` documentando interface, funcionamento e implementação. Sobre esses blocos são construídos os circuitos completos em [`datapaths/`](datapaths/), que os importam como bibliotecas.

## Estrutura
```
risc-v/
├── datapaths/                        # processadores
│   ├── monociclo/                    # ciclo único
│   └── pipeline/                     # 5 estágios
│
├── componentes/                      # um diretório por bloco funcional
│   └── <componente>/
│       ├── <componente>.circ         # circuito do componente
│       └── README.md                 # manual: interface, funcionamento e implementação
│
├── codigos/                          # programas em linguagem de máquina para teste
├── CONVENCOES.md                     # regras de montagem e documentação dos circuitos
├── LICENSE.md                        # licença para uso, cópia, modificação e distribuição
├── logisim-evolution-4.1.0-all.jar   # versão do Logisim Evolution recomendada
└── RISCV_CARD.pdf                    # cartão de referência da ISA RISC-V
```

## Datapaths
Cada _datapath_ tem seu próprio manual, com os estágios, os componentes usados e o caminho percorrido pelos sinais.

| _Datapath_ | Descrição |
| :--- | :--- |
| [monociclo](datapaths/monociclo/README.md) | Cada instrução é buscada, executada e finalizada em **um** ciclo de _clock_. É a versão mais simples e a base do _pipeline_. |
| [pipeline](datapaths/pipeline/README.md) | Execução dividida em **5 estágios** simultâneos. |


### Componentes
Cada componente também tem seu próprio manual, com interface, funcionamento e implementação.

| Componente                                          | Função                                                       |
| ----------------------------------------------------------- | ------------------------------------------------------------ |
| [ULA](componentes/ULA/README.md)                            | Unidade Lógica e Aritmética.                                 |
| [ucULA](componentes/ucULA/README.md)                        | Unidade de controle da ULA (define a operação).              |
| [ucPrincipal](componentes/ucPrincipal/README.md)            | Unidade de controle principal (gera os sinais de controle).  |
| [ucDesvio](componentes/ucDesvio/README.md)                  | Unidade de controle de desvios (_branches_).                 |
| [ucEnderecamento](componentes/ucEnderecamento/README.md)    | Unidade de controle de endereçamento.                        |
| [bancoRegistradores](componentes/bancoRegistradores/README.md) | Banco de registradores.                                   |
| [contadorCiclos](componentes/contadorCiclos/README.md)      | Contador de ciclos de _PC_.                                  |
| [decodificador](componentes/decodificador/README.md)        | Decodificador da instrução.                                  |
| [extensores](componentes/extensores/README.md)              | Extensores de sinal e de zero.                               |
| [memInstrucoes](componentes/memInstrucoes/README.md)        | Memória de instruções.                                       |
| [memDados](componentes/memDados/README.md)                  | Memória de dados.                                            |
| [zero](componentes/zero/README.md)                          | Flag de resultado zero da ULA.                               |
| [estagiosPipeline](componentes/estagiosPipeline/README.md)  | Os quatro registradores de estágio (`IF/ID`, `ID/EX`, `EX/MEM`, `MEM/WB`). |
| [idULA](componentes/pipelineComponentes/idULA/README.md)    | Mini-ULA que resolve os desvios no estágio de decodificação. |

## Convenções
As regras de montagem e documentação dos circuitos: **nomenclatura**, **posição dos pinos**, **uso e nomeação de túneis** e **padrão dos READMEs** estão reunidas em **[`CONVENCOES.md`](CONVENCOES.md)**.

## Execução
O `.jar` do Logisim Evolution já está incluso na raiz do repositório. É necessário ter o **Java (JRE/JDK)** instalado. Abra o terminal na raiz do projeto e execute:

```bash
java -jar logisim-evolution-4.1.0-all.jar
```

### Dentro do Logisim
1. Com o Logisim aberto, clique em **`File` → `Open...`**.
2. Selecione o circuito do _datapath_ desejado. Os componentes em `componentes/` são carregados automaticamente como bibliotecas.
3. Para testar o processador, carregue um programa na memória:
   - Clique com o botão direito sobre o componente da **Memória de Instruções**.
   - Selecione **`Load Image...`**.
   - Escolha um dos arquivos de teste da pasta [`codigos/`](codigos/).
4. Use a ferramenta **`Poke`** (ícone da mãozinha) ou ative o **Clock** para acompanhar a execução das instruções pelo _datapath_.

> [!NOTE]
> Os programas de [`codigos/`](codigos/) com prefixo `teste_pipeline_` já contêm as bolhas (`nop`) exigidas pelo _pipeline_, que não possui _forwarding_ nem detecção de _hazard_. Como o `nop` é uma instrução válida, esses mesmos arquivos também rodam no monociclo, apenas gastando ciclos a mais.

Este projeto está licenciado sob os termos da Licença MIT – consulte o arquivo LICENSE para obter detalhes.
