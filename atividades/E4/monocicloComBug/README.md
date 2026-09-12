# Caminho de Dados Monociclo com Defeito

Cópia do [caminho de dados monociclo](../../../datapaths/monociclo/README.md) na qual foi introduzido **um único defeito**, para uso na atividade **E4**. Fora esse defeito, o circuito é idêntico ao original: mesmos componentes, mesmas ligações, mesmo conjunto de instruções.

> [!IMPORTANT]
> O circuito carrega os componentes do diretório [`componentes/`](../../../componentes/) por caminho relativo. Abra o `main.circ` **sem tirá-lo da estrutura do repositório**: copiado sozinho para outra pasta, o Logisim-Evolution não encontra as bibliotecas e pede a localização de cada uma.

<br>

## Como usar

### 1. Carregar o programa
Clique com o botão direito na **memória de instruções** &rarr; *Load Image* &rarr; selecione o arquivo `.txt` no formato `v2.0 raw`. Encerre o programa com a palavra `ffffffff`.

### 2. Zerar o estado
Antes de cada execução, use *Simulate* &rarr; *Reset Simulation* (`Ctrl+R`). Um estado residual de uma execução anterior produz divergências que não têm relação com o defeito.

### 3. Executar
`Ctrl+T` avança um ciclo de _clock_, ou seja, uma instrução. Confira o efeito de cada uma antes de prosseguir, acompanhando o Contador de Programa, o Banco de Registradores e a Memória de Dados.

### 4. Inspecionar um componente
Clique com o botão direito sobre um componente e escolha a opção de visualizá-lo para descer ao seu interior. Com a simulação em andamento, os valores em fios e pinos ficam visíveis, o que permite comparar o que entra e o que sai de cada unidade.

<br>

## Antes de corrigir

Guarde uma cópia intacta do `main.circ`. A correção só é avaliável se houver como comparar o circuito corrigido com o circuito recebido.

> [!NOTE]
> Os arquivos de `componentes/` são compartilhados com os demais caminhos de dados do projeto. Se a correção exigir alterar um componente, trabalhe sobre uma cópia dele, para não modificar os outros circuitos.

<br>

## Arquivo

- **`main.circ`**: circuito completo, para abrir no Logisim-Evolution 4.1.0.

<br>

## Uso didático

Este circuito é o recurso central da atividade **E4 — Caça ao Defeito: Diagnóstico de Falha no Caminho de Dados**.
