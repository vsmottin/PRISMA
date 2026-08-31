# Registrador de Estágio MEM/WB

O **estagioMEM_WB** é o registrador posicionado entre a etapa de Acesso à Memória (MEM - _Memory_) e a etapa de Escrita no Registrador (WB - _Write-Back_).

**Função principal:**
Na subida do _clock_, captura o dado lido da memória de dados, o resultado da ULA, o endereço do registrador destino (`rd`) e o `PC+4` (valor de _link_ do `jal`/`jalr`). Propaga também os sinais de controle consumidos exclusivamente no _Write-Back_ (`RegWrite`, `MemToReg`, `Jump`), que decidem se — e qual valor — será escrito de volta no banco de registradores.
