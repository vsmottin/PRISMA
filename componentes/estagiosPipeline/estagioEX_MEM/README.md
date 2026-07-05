# Registrador de Estágio EX/MEM

O **estagioEX_MEM** é o registrador posicionado entre a etapa de Execução (EX - _Execute_) e a etapa de Acesso à Memória (MEM - _Memory_).

**Função principal:**
Na subida do _clock_, captura o resultado produzido pela ULA, o valor de `rs2` (usado como dado das instruções de _store_), o endereço do registrador destino (`rd`), o `PC+4` (valor de _link_ do `jal`/`jalr`) e o `funct3` (consumido na fase MEM pela lógica de endereçamento para definir o tamanho do acesso — _byte_, _half_ ou _word_). Junto com esses dados, propaga os sinais de controle que ainda serão consumidos: os da própria fase MEM (`MemRead`, `MemWrite`) e os que seguem de carona até o _Write-Back_ (`RegWrite`, `MemToReg`, `Jump`). Os sinais resolvidos no EX (`ALUSrcB`, `ALUOp`, `Auipc`, `Lui`, `Jalr`, `BranchSrc`) **não** atravessam este registrador.
