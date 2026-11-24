# Registrador de Estágio ID/EX

O **estagioID_EX** atua na fronteira entre a etapa de Decodificação (ID - _Instruction Decode_) e a etapa de Execução (EX - _Execute_).

**Função principal:**
Receber de forma combinacional todos os dados necessários (valores lidos do banco de registradores `rs1` e `rs2`, valores imediatos estendidos, valor do `PC`) e os sinais de controle emitidos pela `ucPrincipal`. Na descida do _clock_, ele armazena e disponibiliza todos esses sinais sincronizadamente para a ULA e componentes do estágio EX.

Também propaga a instrução crua (`Instrucao_ID` &rarr; `Instrucao_EX`), usada apenas para identificar qual instrução está no estágio EX.

Propaga ainda os **números** dos registradores lidos (`rs1_ID` &rarr; `rs1_EX` e `rs2_ID` &rarr; `rs2_EX`), de 5 bits cada. Eles são as entradas `rs1`/`rs2` da [Unidade de Encaminhamento](../../pipelineComponentes/ucEncaminhamento/) no estágio EX, que os compara com o `rd` das instruções no MEM e no WB. No [pipeline simples](../../../datapaths/pipeline/), que não tem encaminhamento, essas entradas ficam desconectadas.
