# Registrador de Estágio IF/ID

O **estagioIF_ID** é o registrador posicionado entre o estágio de Busca da Instrução (IF - _Instruction Fetch_) e a Decodificação (ID - _Instruction Decode_).

**Função principal:**
Durante um ciclo, ele recebe a instrução crua da `memInstrucoes` e o respectivo endereço (`PC`). A cada pulso de _clock_, ele salva esses dados e os fornece ao estágio ID, garantindo que o decodificador avalie de forma estável a instrução buscada enquanto o `PC` já é incrementado para a próxima.
