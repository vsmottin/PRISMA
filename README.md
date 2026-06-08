# risc-v

![Logisim_Evolution](https://img.shields.io/badge/Logisim_Evolution-006039) ![RISC-V](https://img.shields.io/badge/RISC--V-2C2C2C)

Repositório criado com o propósito de implementar versões de um _datapath_ (caminho de dados) para a arquitetura **RISC-V** usando o **Logisim Evolution**.

O processador é montado de forma modular: cada bloco funcional (ULA, banco de registradores, memórias, unidades de controle, etc.) tem seu próprio arquivo `.circ` dentro de `componentes/`, e o circuito principal `main.circ` os importa como bibliotecas para compor o _datapath_ completo.

Projeto orientado pelo Prof. Dr. João Fabrício Filho, 2026/1.

## Estrutura

```
risc-v/
├── main.circ                         # circuito principal: integra todos os componentes
├── componentes/                      # blocos funcionais reutilizáveis
├── codigos/                          # programas em linguagem de máquina para teste
├── logisim-evolution-4.1.0-all.jar   # .jar do Logisim Evolution usado
└── RISCV_CARD.pdf                    # cartão de referência da ISA RISC-V
```

### Componentes

| Arquivo (`componentes/`)   | Circuito             | Função                                                        |
| -------------------------- | -------------------- | ------------------------------------------------------------ |
| `ULA.circ`                 | `ULA`                | Unidade Lógica e Aritmética.                                 |
| `ucULA.circ`               | `ucULA`              | Unidade de controle da ULA (define a operação).              |
| `ucPrincipal.circ`         | `ucPrincipal`        | Unidade de controle principal (gera os sinais de controle).  |
| `ucDesvio.circ`            | `ucDesvio`           | Unidade de controle de desvios (_branches_).                 |
| `ucEnderecamento.circ`     | `ucEnderecamento`    | Unidade de controle de endereçamento.                        |
| `bancoRegistradores.circ`  | `bancoRegistradores` | Banco de registradores.                                      |
| `contador.circ`            | `contador`           | Contador de ciclos de _PC_.                                  |
| `decodificador.circ`       | `decodificador`      | Decodificador da instrução (separa os campos).               |
| `immGen.circ`              | `immGen`             | Gerador de imediatos.                                        |
| `extensorSinal.circ`       | `extensorSinal_*` / `extensorZero_*` | Extensores de sinal e de zero (ver convenção abaixo). |
| `memInstr.circ`            | `memInstr`           | Memória de instruções.                                       |
| `memDados.circ`            | `memDados`           | Memória de dados.                                            |
| `zero.circ`                | `zero`               | Flag de resultado zero da ULA.                               |


#### Convenção de nomenclatura

- **camelCase**, em português e sem acentuação.
- Unidades de controle usam o prefixo **`uc`**: `ucPrincipal`, `ucULA`, `ucDesvio`, `ucEnderecamento`.
- **Extensores** seguem o padrão `extensor<tipo>_<largura>`, onde `<tipo>` é `Sinal` (extensão de sinal) ou `Zero` (extensão de zero) e `<largura>` é a quantidade de bits da entrada. Quando aplicável, um sufixo identifica o formato da instrução:
  - `extensorSinal_12`, `extensorSinal_21` — extensão de sinal de 12 e 21 bits.
  - `extensorZero_8`, `extensorZero_16` — extensão de zero de 8 e 16 bits.
  - `extensorZero_20_typeU` — extensão de zero de 20 bits, específica para instruções _type-U_.

## Execução

O `.jar` do Logisim Evolution já está incluso na raiz do repositório. É necessário ter o **Java (JRE/JDK)** instalado. Abra o terminal na raiz do projeto e execute:

```bash
java -jar logisim-evolution-4.1.0-all.jar
```

### Dentro do Logisim

1. Com o Logisim aberto, clique em **`File` → `Open...`**.
2. Selecione o arquivo **`main.circ`** na raiz do projeto. Os componentes em `componentes/` são carregados automaticamente como bibliotecas.
3. Para testar o processador, carregue um programa na memória:
   - Clique com o botão direito sobre o componente da **Memória de Instruções**.
   - Selecione **`Load Image...`**.
   - Escolha um dos arquivos de teste da pasta `codigos/`.
4. Use a ferramenta **`Poke`** (ícone da mãozinha) ou ative o **Clock** para acompanhar a execução das instruções pelo _datapath_.

> O arquivo `RISCV_CARD.pdf` na raiz serve como referência rápida das instruções e formatos da ISA RISC-V durante os testes.
