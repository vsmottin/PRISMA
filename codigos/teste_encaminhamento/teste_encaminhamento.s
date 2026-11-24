# Teste da Unidade de Encaminhamento (pipelineEncaminhamento)
# Sem bolhas de dados, exceto as que o encaminhamento nao resolve:
#   load -> uso: 1 nop | escrita -> desvio: 1 nop | load -> desvio: 2 nops
# Cada verificacao grava 1/0 em diag[256 + 4*n] e acumula em x31.

# ===== INIT =====
        addi x31, x0, 1       # flag global = 1 (assume tudo ok)

# ===== 1. EX/MEM em rs2 e MEM/WB em rs1 =====
        addi x1, x0, 12
        addi x2, x0, 5
        add  x5, x1, x2       # x1: ForwardA = 01 | x2: ForwardB = 10 -> 17
        xori x7, x5, 17       # 0 sse igual
        sltiu x7, x7, 1       # 1 sse igual
        sw   x7, 256(x0)      # diag[256]
        and  x31, x31, x7

# ===== 2. EX/MEM em rs1 e MEM/WB em rs2 =====
        addi x2, x0, 7
        addi x1, x0, 20
        sub  x5, x1, x2       # x1: ForwardA = 10 | x2: ForwardB = 01 -> 13
        xori x7, x5, 13
        sltiu x7, x7, 1
        sw   x7, 260(x0)      # diag[260]
        and  x31, x31, x7

# ===== 3. Prioridade: o mesmo registrador no MEM e no WB =====
        addi x3, x0, 1
        addi x3, x0, 2
        add  x5, x3, x3       # vale o mais recente (EX/MEM) -> 4
        xori x7, x5, 4
        sltiu x7, x7, 1
        sw   x7, 264(x0)      # diag[264]
        and  x31, x31, x7

# ===== 4. Cadeia: cada instrucao usa a anterior =====
        addi x4, x0, 1
        add  x4, x4, x4       # 2
        add  x4, x4, x4       # 4
        add  x4, x4, x4       # 8
        xori x7, x4, 8
        sltiu x7, x7, 1
        sw   x7, 268(x0)      # diag[268]
        and  x31, x31, x7

# ===== 5. x0 nunca e encaminhado =====
        addi x0, x0, 99       # RegWrite = 1 com rd = 0
        add  x5, x0, x0       # deve ler 0, e nao 99 + 99
        sltiu x7, x5, 1
        sw   x7, 272(x0)      # diag[272]
        and  x31, x31, x7

# ===== 6. Sem RegWrite nao ha encaminhamento =====
        addi x6, x0, 33
        sw   x0, 134(x0)      # campo rd do sw = 6, mas RegWrite = 0
        addi x5, x6, 0        # deve vir do MEM/WB (33), nao do EX/MEM
        xori x7, x5, 33
        sltiu x7, x7, 1
        sw   x7, 276(x0)      # diag[276]
        and  x31, x31, x7

# ===== 7. Store: base e dado encaminhados; load -> uso com 1 nop =====
        addi x8, x0, 200      # base
        addi x9, x0, 0x5A     # dado
        sw   x9, 0(x8)        # base: ForwardA = 01 | dado: ForwardB = 10
        lw   x5, 0(x8)
        nop                   # bolha: load -> uso
        xori x7, x5, 0x5A     # dado lido chega pelo MEM/WB
        sltiu x7, x7, 1
        sw   x7, 280(x0)      # diag[280]
        and  x31, x31, x7

# ===== 8. Load: base encaminhada; dado lido encaminhado para um store =====
        addi x10, x0, 200
        lw   x11, 0(x10)      # base: ForwardA = 10
        nop                   # bolha: load -> uso
        sw   x11, 4(x10)      # dado: ForwardB = 01 (valor lido)
        lw   x5, 4(x10)
        nop                   # bolha: load -> uso
        xori x7, x5, 0x5A
        sltiu x7, x7, 1
        sw   x7, 284(x0)      # diag[284]
        and  x31, x31, x7

# ===== 9. Desvio no ID: escritor a distancia 2 (EX/MEM -> ID) =====
        addi x13, x0, 3       # esperado
        addi x7, x0, 0
        addi x12, x0, 3       # escritor
        nop                   # bolha: escrita -> desvio
        beq  x12, x13, ok9    # x12: ForwardA_ID = 10
        nop                   # sombra do desvio
        jal  x0, fim9         # nao desviou: x7 fica 0
        nop                   # sombra do jal
ok9:    addi x7, x0, 1
fim9:   sw   x7, 288(x0)      # diag[288]
        and  x31, x31, x7

# ===== 10. Desvio no ID: operandos no MEM e no WB =====
        addi x7, x0, 0
        addi x14, x0, -1
        addi x15, x0, 1
        nop                   # bolha: escrita -> desvio
        blt  x14, x15, ok10   # x14: ForwardA_ID = 01 | x15: ForwardB_ID = 10
        nop                   # sombra do desvio
        jal  x0, fim10
        nop                   # sombra do jal
ok10:   addi x7, x0, 1
fim10:  sw   x7, 292(x0)      # diag[292]
        and  x31, x31, x7

# ===== 11. Load -> desvio com 2 nops =====
        addi x7, x0, 0
        lw   x16, 0(x8)       # 0x5A
        nop                   # bolhas: load -> desvio
        nop
        beq  x16, x9, ok11    # x16: ForwardA_ID = 01 (valor lido)
        nop                   # sombra do desvio
        jal  x0, fim11
        nop                   # sombra do jal
ok11:   addi x7, x0, 1
fim11:  sw   x7, 296(x0)      # diag[296]
        and  x31, x31, x7

# ===== 12. jal: endereco de retorno encaminhado (independe do PC) =====
t12:    auipc x17, 0          # x17 = t12
        jal  x18, alvo12      # x18 = t12 + 8
        sub  x5, x18, x17     # sombra: x18 vem do EX/MEM (PC + 4) -> 8
        addi x31, x0, 0       # pulada
alvo12: sub  x6, x18, x17     # x18 vem do MEM/WB -> 8
        xori x5, x5, 8
        xori x6, x6, 8
        or   x7, x5, x6
        sltiu x7, x7, 1
        sw   x7, 300(x0)      # diag[300]
        and  x31, x31, x7

# ===== 13. jalr: base e endereco de retorno encaminhados =====
t13:    auipc x19, 0          # x19 = t13
        addi x21, x19, alvo13-t13
        jalr x22, 0(x21)      # base: ForwardA = 10 | x22 = t13 + 12
        sub  x5, x22, x19     # sombra 1: x22 vem do EX/MEM -> 12
        sub  x6, x22, x19     # sombra 2: x22 vem do MEM/WB -> 12
        addi x31, x0, 0       # pulada
alvo13: xori x5, x5, 12
        xori x6, x6, 12
        or   x7, x5, x6
        sltiu x7, x7, 1
        sw   x7, 304(x0)      # diag[304]
        and  x31, x31, x7

# ===== 14. lui/auipc ignoram o campo rs1 encaminhado =====
        addi x1, x0, 77
t14:    auipc x5, 8           # campo rs1 = x1, escrito logo antes
        auipc x6, 0           # x6 = t14 + 4
        sub  x5, x5, x6       # 0x8000 - 4
        addi x5, x5, 4
        addi x1, x0, 77
        lui  x6, 8            # campo rs1 = x1 de novo -> 0x8000
        xor  x7, x5, x6
        sltiu x7, x7, 1
        sw   x7, 308(x0)      # diag[308]
        and  x31, x31, x7

# ===== 15. Tipo I ignora o campo rs2 encaminhado =====
        addi x3, x0, 50
        addi x5, x0, 3        # campo rs2 = x3, mas ALUSrcB escolhe o imediato
        xori x7, x5, 3
        sltiu x7, x7, 1
        sw   x7, 312(x0)      # diag[312]
        and  x31, x31, x7

# ===== FIM: x31 = 1 sse TUDO passou =====
        sw   x31, 316(x0)     # diag[316] = flag global
        nop
        nop
        nop
        nop
        halt
