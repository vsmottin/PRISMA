# Caminho de Dados Monociclo com Defeito

Cópia do caminho de dados monociclo na qual foi introduzido **um único defeito**, para uso na atividade E4 . Fora esse defeito, o circuito é idêntico ao original: mesmos componentes, mesmas ligações, mesmo conjunto de instruções.

> [!IMPORTANT]
> Este circuito é uma **cópia isolada**, com os seus próprios componentes. Nada do que se altere aqui afeta os demais caminhos de dados do projeto, e alterações feitas nos componentes originais não se refletem aqui.

<br>

## Como usar

### 1. Carregar o programa
Clique com o botão direito na **memória de instruções** &rarr; *Load Image* &rarr; selecione o arquivo `.txt` no formato `v2.0 raw`. Encerre o programa com a palavra `ffffffff`.

### 2. Zerar o estado
Antes de cada execução, use *Simulate*; *Reset Simulation* (`Ctrl+R`). Um estado residual de uma execução anterior produz divergências que não têm relação com o defeito.

### 3. Executar
`Ctrl+T` avança um ciclo de _clock_, ou seja, uma instrução. Confira o efeito de cada uma antes de prosseguir, acompanhando o Contador de Programa, o Banco de Registradores e a Memória de Dados.

### 4. Inspecionar um componente
Clique com o botão direito sobre um componente e escolha a opção de visualizá-lo para descer ao seu interior. Com a simulação em andamento, os valores em fios e pinos ficam visíveis, o que permite comparar o que entra e o que sai de cada unidade.

<br>

## Antes de corrigir

Guarde uma cópia intacta do arquivo. A correção só é avaliável se houver como comparar o circuito corrigido com o circuito recebido.

<br>

## Arquivo

- **`datapath/monocicloComBug/main.circ`** — circuito completo, para abrir no Logisim-Evolution 4.1.0.
