# risc-v

![Logisim](https://img.shields.io/badge/Logisim-006039) ![RISC-V](https://img.shields.io/badge/RISC--V-2C2C2C)

Repositório criado com o propósito de implementar versões de um _datapath_ (caminho de dados) para a arquitetura RISC-V usando Logisim. 
Projeto orientado por João Fabrício, 2026/1.

## Estrutura

- **`logisim/`**: Contém os circuitos do processador construídos no Logisim.
- **`codigos/`**: Códigos com instruções em linguagem de máquina usados para testes.

## Execução

Os executáveis do Logisim já estão inclusos na raiz do repositório.

### No Windows
Basta dar um duplo clique no arquivo executável:
```
logisim-win-2.7.1.exe
```

### No Linux ou macOS
É necessário ter o **Java (JRE/JDK)** instalado em seu sistema. Abra o terminal na raiz do projeto e execute o comando abaixo:
```bash
java -jar logisim-generic-2.7.1.jar
```

#### Dentro do Logisim

1. Com o Logisim aberto, clique em **`File` -> `Open...`**.
2. Navegue até a pasta `logisim/` e selecione o arquivo **`simuladorFinal.circ`**.
3. Para testar o processador, carregue as instruções na memória:
   - Clique com o botão direito sobre o componente da Memória de Instruções.
   - Selecione **`Load Image...`**.
   - Escolha um dos arquivos de teste localizados na pasta `codigos/`.
4. Utilize a ferramenta de `Poke` (ícone da mãozinha) ou ative o Clock para observar a execução das instruções pelo _datapath_.
