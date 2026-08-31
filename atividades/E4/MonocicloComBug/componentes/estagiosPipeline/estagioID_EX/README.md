# Registrador de Estágio ID/EX

O **estagioID_EX** atua na fronteira entre a etapa de Decodificação (ID - _Instruction Decode_) e a etapa de Execução (EX - _Execute_).

**Função principal:**
Receber de forma combinacional todos os dados necessários (valores lidos do banco de registradores `rs1` e `rs2`, valores imediatos estendidos, valor do `PC`) e os sinais de controle emitidos pela `ucPrincipal`. Na subida do _clock_, ele armazena e disponibiliza todos esses sinais sincronizadamente para a ULA e componentes do estágio EX.
