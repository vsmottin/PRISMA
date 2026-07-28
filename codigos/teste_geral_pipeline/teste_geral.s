
# ===== INIT =====
        addi x31, x0, 1       # flag global = 1 (assume tudo ok)
        addi x1, x0, 12
        addi x2, x0, 5
        addi x3, x0, -1
        addi x4, x0, 1
        nop
        nop
        nop

# ===== ALU R-type e I-type (grava em memoria e auto-verifica) =====
        add  x5, x1, x2   
        nop
        nop
        nop
        sw   x5, 0(x0)      # mem[0] p/ inspecao
        nop
        nop
        nop
        addi x6, x0, 17
        nop
        nop
        nop
        xor  x7, x5, x6   # 0 sse igual
        nop
        nop
        nop
        sltiu x7, x7, 1        # 1 sse igual
        nop
        nop
        nop
        sw   x7, 256(x0)   # diag[256] = add
        nop
        nop
        nop
        and  x31, x31, x7      # acumula
        nop
        nop
        nop
        sub  x5, x1, x2   
        nop
        nop
        nop
        sw   x5, 4(x0)      # mem[4] p/ inspecao
        nop
        nop
        nop
        addi x6, x0, 7
        nop
        nop
        nop
        xor  x7, x5, x6   # 0 sse igual
        nop
        nop
        nop
        sltiu x7, x7, 1        # 1 sse igual
        nop
        nop
        nop
        sw   x7, 260(x0)   # diag[260] = sub
        nop
        nop
        nop
        and  x31, x31, x7      # acumula
        nop
        nop
        nop
        and  x5, x1, x2   
        nop
        nop
        nop
        sw   x5, 8(x0)      # mem[8] p/ inspecao
        nop
        nop
        nop
        addi x6, x0, 4
        nop
        nop
        nop
        xor  x7, x5, x6   # 0 sse igual
        nop
        nop
        nop
        sltiu x7, x7, 1        # 1 sse igual
        nop
        nop
        nop
        sw   x7, 264(x0)   # diag[264] = and
        nop
        nop
        nop
        and  x31, x31, x7      # acumula
        nop
        nop
        nop
        or   x5, x1, x2   
        nop
        nop
        nop
        sw   x5, 12(x0)      # mem[12] p/ inspecao
        nop
        nop
        nop
        addi x6, x0, 13
        nop
        nop
        nop
        xor  x7, x5, x6   # 0 sse igual
        nop
        nop
        nop
        sltiu x7, x7, 1        # 1 sse igual
        nop
        nop
        nop
        sw   x7, 268(x0)   # diag[268] = or
        nop
        nop
        nop
        and  x31, x31, x7      # acumula
        nop
        nop
        nop
        xor  x5, x1, x2   
        nop
        nop
        nop
        sw   x5, 16(x0)      # mem[16] p/ inspecao
        nop
        nop
        nop
        addi x6, x0, 9
        nop
        nop
        nop
        xor  x7, x5, x6   # 0 sse igual
        nop
        nop
        nop
        sltiu x7, x7, 1        # 1 sse igual
        nop
        nop
        nop
        sw   x7, 272(x0)   # diag[272] = xor
        nop
        nop
        nop
        and  x31, x31, x7      # acumula
        nop
        nop
        nop
        sll  x5, x4, x2   
        nop
        nop
        nop
        sw   x5, 20(x0)      # mem[20] p/ inspecao
        nop
        nop
        nop
        addi x6, x0, 32
        nop
        nop
        nop
        xor  x7, x5, x6   # 0 sse igual
        nop
        nop
        nop
        sltiu x7, x7, 1        # 1 sse igual
        nop
        nop
        nop
        sw   x7, 276(x0)   # diag[276] = sll
        nop
        nop
        nop
        and  x31, x31, x7      # acumula
        nop
        nop
        nop
        srl  x5, x1, x4   
        nop
        nop
        nop
        sw   x5, 24(x0)      # mem[24] p/ inspecao
        nop
        nop
        nop
        addi x6, x0, 6
        nop
        nop
        nop
        xor  x7, x5, x6   # 0 sse igual
        nop
        nop
        nop
        sltiu x7, x7, 1        # 1 sse igual
        nop
        nop
        nop
        sw   x7, 280(x0)   # diag[280] = srl
        nop
        nop
        nop
        and  x31, x31, x7      # acumula
        nop
        nop
        nop
        sra  x5, x3, x4   
        nop
        nop
        nop
        sw   x5, 28(x0)      # mem[28] p/ inspecao
        nop
        nop
        nop
        addi x6, x0, -1
        nop
        nop
        nop
        xor  x7, x5, x6   # 0 sse igual
        nop
        nop
        nop
        sltiu x7, x7, 1        # 1 sse igual
        nop
        nop
        nop
        sw   x7, 284(x0)   # diag[284] = sra
        nop
        nop
        nop
        and  x31, x31, x7      # acumula
        nop
        nop
        nop
        slt  x5, x3, x4   
        nop
        nop
        nop
        sw   x5, 32(x0)      # mem[32] p/ inspecao
        nop
        nop
        nop
        addi x6, x0, 1
        nop
        nop
        nop
        xor  x7, x5, x6   # 0 sse igual
        nop
        nop
        nop
        sltiu x7, x7, 1        # 1 sse igual
        nop
        nop
        nop
        sw   x7, 288(x0)   # diag[288] = slt
        nop
        nop
        nop
        and  x31, x31, x7      # acumula
        nop
        nop
        nop
        sltu x5, x3, x4   
        nop
        nop
        nop
        sw   x5, 36(x0)      # mem[36] p/ inspecao
        nop
        nop
        nop
        addi x6, x0, 0
        nop
        nop
        nop
        xor  x7, x5, x6   # 0 sse igual
        nop
        nop
        nop
        sltiu x7, x7, 1        # 1 sse igual
        nop
        nop
        nop
        sw   x7, 292(x0)   # diag[292] = sltu
        nop
        nop
        nop
        and  x31, x31, x7      # acumula
        nop
        nop
        nop
        addi x5, x1, 100  
        nop
        nop
        nop
        sw   x5, 40(x0)      # mem[40] p/ inspecao
        nop
        nop
        nop
        addi x6, x0, 112
        nop
        nop
        nop
        xor  x7, x5, x6   # 0 sse igual
        nop
        nop
        nop
        sltiu x7, x7, 1        # 1 sse igual
        nop
        nop
        nop
        sw   x7, 296(x0)   # diag[296] = addi
        nop
        nop
        nop
        and  x31, x31, x7      # acumula
        nop
        nop
        nop
        andi x5, x1, 6    
        nop
        nop
        nop
        sw   x5, 44(x0)      # mem[44] p/ inspecao
        nop
        nop
        nop
        addi x6, x0, 4
        nop
        nop
        nop
        xor  x7, x5, x6   # 0 sse igual
        nop
        nop
        nop
        sltiu x7, x7, 1        # 1 sse igual
        nop
        nop
        nop
        sw   x7, 300(x0)   # diag[300] = andi
        nop
        nop
        nop
        and  x31, x31, x7      # acumula
        nop
        nop
        nop
        ori  x5, x1, 1    
        nop
        nop
        nop
        sw   x5, 48(x0)      # mem[48] p/ inspecao
        nop
        nop
        nop
        addi x6, x0, 13
        nop
        nop
        nop
        xor  x7, x5, x6   # 0 sse igual
        nop
        nop
        nop
        sltiu x7, x7, 1        # 1 sse igual
        nop
        nop
        nop
        sw   x7, 304(x0)   # diag[304] = ori
        nop
        nop
        nop
        and  x31, x31, x7      # acumula
        nop
        nop
        nop
        xori x5, x1, -1   
        nop
        nop
        nop
        sw   x5, 52(x0)      # mem[52] p/ inspecao
        nop
        nop
        nop
        addi x6, x0, -13
        nop
        nop
        nop
        xor  x7, x5, x6   # 0 sse igual
        nop
        nop
        nop
        sltiu x7, x7, 1        # 1 sse igual
        nop
        nop
        nop
        sw   x7, 308(x0)   # diag[308] = xori
        nop
        nop
        nop
        and  x31, x31, x7      # acumula
        nop
        nop
        nop
        slti x5, x3, 0    
        nop
        nop
        nop
        sw   x5, 56(x0)      # mem[56] p/ inspecao
        nop
        nop
        nop
        addi x6, x0, 1
        nop
        nop
        nop
        xor  x7, x5, x6   # 0 sse igual
        nop
        nop
        nop
        sltiu x7, x7, 1        # 1 sse igual
        nop
        nop
        nop
        sw   x7, 312(x0)   # diag[312] = slti
        nop
        nop
        nop
        and  x31, x31, x7      # acumula
        nop
        nop
        nop
        sltiu x5, x3, 1   
        nop
        nop
        nop
        sw   x5, 60(x0)      # mem[60] p/ inspecao
        nop
        nop
        nop
        addi x6, x0, 0
        nop
        nop
        nop
        xor  x7, x5, x6   # 0 sse igual
        nop
        nop
        nop
        sltiu x7, x7, 1        # 1 sse igual
        nop
        nop
        nop
        sw   x7, 316(x0)   # diag[316] = sltiu
        nop
        nop
        nop
        and  x31, x31, x7      # acumula
        nop
        nop
        nop
        slli x5, x4, 4    
        nop
        nop
        nop
        sw   x5, 64(x0)      # mem[64] p/ inspecao
        nop
        nop
        nop
        addi x6, x0, 16
        nop
        nop
        nop
        xor  x7, x5, x6   # 0 sse igual
        nop
        nop
        nop
        sltiu x7, x7, 1        # 1 sse igual
        nop
        nop
        nop
        sw   x7, 320(x0)   # diag[320] = slli
        nop
        nop
        nop
        and  x31, x31, x7      # acumula
        nop
        nop
        nop
        srli x5, x1, 2    
        nop
        nop
        nop
        sw   x5, 68(x0)      # mem[68] p/ inspecao
        nop
        nop
        nop
        addi x6, x0, 3
        nop
        nop
        nop
        xor  x7, x5, x6   # 0 sse igual
        nop
        nop
        nop
        sltiu x7, x7, 1        # 1 sse igual
        nop
        nop
        nop
        sw   x7, 324(x0)   # diag[324] = srli
        nop
        nop
        nop
        and  x31, x31, x7      # acumula
        nop
        nop
        nop
        srai x5, x3, 4    
        nop
        nop
        nop
        sw   x5, 72(x0)      # mem[72] p/ inspecao
        nop
        nop
        nop
        addi x6, x0, -1
        nop
        nop
        nop
        xor  x7, x5, x6   # 0 sse igual
        nop
        nop
        nop
        sltiu x7, x7, 1        # 1 sse igual
        nop
        nop
        nop
        sw   x7, 328(x0)   # diag[328] = srai
        nop
        nop
        nop
        and  x31, x31, x7      # acumula
        nop
        nop
        nop

# ===== LOADS (sw setup, depois lw/lh/lb/lhu/lbu, auto-verifica) =====
        lui  x6, 0x807f0
        nop
        nop
        nop
        addi x6, x6, 383
        nop
        nop
        nop
        sw   x6, 200(x0)      # mem[200] = 0x807F017F
        nop
        nop
        nop
        lw   x5, 200(x0)
        lui  x6, 0x807f0
        nop
        nop
        nop
        addi x6, x6, 383
        nop
        nop
        nop
        xor  x7, x5, x6   # 0 sse igual
        nop
        nop
        nop
        sltiu x7, x7, 1        # 1 sse igual
        nop
        nop
        nop
        sw   x7, 332(x0)   # diag[332] = lw
        nop
        nop
        nop
        and  x31, x31, x7      # acumula
        nop
        nop
        nop
        lb   x5, 200(x0)
        addi x6, x0, 127
        nop
        nop
        nop
        xor  x7, x5, x6   # 0 sse igual
        nop
        nop
        nop
        sltiu x7, x7, 1        # 1 sse igual
        nop
        nop
        nop
        sw   x7, 336(x0)   # diag[336] = lb
        nop
        nop
        nop
        and  x31, x31, x7      # acumula
        nop
        nop
        nop
        lbu  x5, 201(x0)
        addi x6, x0, 1
        nop
        nop
        nop
        xor  x7, x5, x6   # 0 sse igual
        nop
        nop
        nop
        sltiu x7, x7, 1        # 1 sse igual
        nop
        nop
        nop
        sw   x7, 340(x0)   # diag[340] = lbu
        nop
        nop
        nop
        and  x31, x31, x7      # acumula
        nop
        nop
        nop
        lh   x5, 202(x0)
        lui  x6, 0xffff8
        nop
        nop
        nop
        addi x6, x6, 127
        nop
        nop
        nop
        xor  x7, x5, x6   # 0 sse igual
        nop
        nop
        nop
        sltiu x7, x7, 1        # 1 sse igual
        nop
        nop
        nop
        sw   x7, 344(x0)   # diag[344] = lh
        nop
        nop
        nop
        and  x31, x31, x7      # acumula
        nop
        nop
        nop
        lhu  x5, 202(x0)
        lui  x6, 0x8
        nop
        nop
        nop
        addi x6, x6, 127
        nop
        nop
        nop
        xor  x7, x5, x6   # 0 sse igual
        nop
        nop
        nop
        sltiu x7, x7, 1        # 1 sse igual
        nop
        nop
        nop
        sw   x7, 348(x0)   # diag[348] = lhu
        nop
        nop
        nop
        and  x31, x31, x7      # acumula
        nop
        nop
        nop

# ===== STORES parciais (sb, sh) via load-back =====
        lui  x6, 0xabcde
        nop
        nop
        nop
        addi x6, x6, 1656
        nop
        nop
        nop
        sw   x6, 204(x0)
        nop
        nop
        nop
        addi x6, x0, 42
        nop
        nop
        nop
        sb   x6, 204(x0)      # mem[204] byte0 = 0x2A
        nop
        nop
        nop
        lw   x5, 204(x0)
        lui  x6, 0xabcde
        nop
        nop
        nop
        addi x6, x6, 1578
        nop
        nop
        nop
        xor  x7, x5, x6   # 0 sse igual
        nop
        nop
        nop
        sltiu x7, x7, 1        # 1 sse igual
        nop
        nop
        nop
        sw   x7, 352(x0)   # diag[352] = sb
        nop
        nop
        nop
        and  x31, x31, x7      # acumula
        nop
        nop
        nop
        addi x6, x0, -1
        nop
        nop
        nop
        sw   x6, 208(x0)
        nop
        nop
        nop
        addi x6, x0, 240
        nop
        nop
        nop
        sh   x6, 208(x0)      # mem[208] metade baixa = 0x00F0
        nop
        nop
        nop
        lw   x5, 208(x0)
        lui  x6, 0xffff0
        nop
        nop
        nop
        addi x6, x6, 240
        nop
        nop
        nop
        xor  x7, x5, x6   # 0 sse igual
        nop
        nop
        nop
        sltiu x7, x7, 1        # 1 sse igual
        nop
        nop
        nop
        sw   x7, 356(x0)   # diag[356] = sh
        nop
        nop
        nop
        and  x31, x31, x7      # acumula
        nop
        nop
        nop

# ===== U-type (lui, e auipc de forma PC-independente) =====
        lui  x5, 0x12345
        lui  x6, 0x12345
        nop
        nop
        nop
        xor  x7, x5, x6   # 0 sse igual
        nop
        nop
        nop
        sltiu x7, x7, 1        # 1 sse igual
        nop
        nop
        nop
        sw   x7, 360(x0)   # diag[360] = lui
        nop
        nop
        nop
        and  x31, x31, x7      # acumula
        nop
        nop
        nop
        # auipc: dois auipc consecutivos (4 bytes apart); diferenca = 4 + (imm<<12) = 0x1004
        auipc x5, 0           # x5 = PC_a
        auipc x8, 1           # x8 = (PC_a+4) + 0x1000
        nop
        nop
        nop
        sub  x5, x8, x5       # x5 = 0x1004
        lui  x6, 0x1
        nop
        nop
        nop
        addi x6, x6, 4
        nop
        nop
        nop
        xor  x7, x5, x6   # 0 sse igual
        nop
        nop
        nop
        sltiu x7, x7, 1        # 1 sse igual
        nop
        nop
        nop
        sw   x7, 364(x0)   # diag[364] = auipc
        nop
        nop
        nop
        and  x31, x31, x7      # acumula
        nop
        nop
        nop

# ===== BRANCHES (6 tipos, tomado e nao-tomado) -> x18..x29 =====

        # x18: beq x2,x2 (toma) 5==5
        addi x18, x0, 1
        beq  x2, x2, B0
        nop
        nop
        nop
        addi x18, x0, 0
        nop
        nop
        nop
B0:

        # x19: beq x1,x2 (nao toma) 12!=5
        addi x19, x0, 0
        beq  x1, x2, B1
        nop
        nop
        nop
        addi x19, x0, 1
        nop
        nop
        nop
B1:

        # x20: bne x1,x2 (toma) 12!=5
        addi x20, x0, 1
        bne  x1, x2, B2
        nop
        nop
        nop
        addi x20, x0, 0
        nop
        nop
        nop
B2:

        # x21: bne x2,x2 (nao toma) 5==5
        addi x21, x0, 0
        bne  x2, x2, B3
        nop
        nop
        nop
        addi x21, x0, 1
        nop
        nop
        nop
B3:

        # x22: blt x3,x4 (toma) -1<1 sinal
        addi x22, x0, 1
        blt  x3, x4, B4
        nop
        nop
        nop
        addi x22, x0, 0
        nop
        nop
        nop
B4:

        # x23: blt x4,x3 (nao toma) 1<-1 falso
        addi x23, x0, 0
        blt  x4, x3, B5
        nop
        nop
        nop
        addi x23, x0, 1
        nop
        nop
        nop
B5:

        # x24: bge x4,x3 (toma) 1>=-1 sinal
        addi x24, x0, 1
        bge  x4, x3, B6
        nop
        nop
        nop
        addi x24, x0, 0
        nop
        nop
        nop
B6:

        # x25: bge x3,x4 (nao toma) -1>=1 falso
        addi x25, x0, 0
        bge  x3, x4, B7
        nop
        nop
        nop
        addi x25, x0, 1
        nop
        nop
        nop
B7:

        # x26: bltu x4,x1 (toma) 1<12 unsigned
        addi x26, x0, 1
        bltu  x4, x1, B8
        nop
        nop
        nop
        addi x26, x0, 0
        nop
        nop
        nop
B8:

        # x27: bltu x3,x4 (nao toma) 0xFFFFFFFF<1 falso
        addi x27, x0, 0
        bltu  x3, x4, B9
        nop
        nop
        nop
        addi x27, x0, 1
        nop
        nop
        nop
B9:

        # x28: bgeu x3,x4 (toma) 0xFFFFFFFF>=1 unsigned
        addi x28, x0, 1
        bgeu  x3, x4, B10
        nop
        nop
        nop
        addi x28, x0, 0
        nop
        nop
        nop
B10:

        # x29: bgeu x4,x1 (nao toma) 1>=12 falso
        addi x29, x0, 0
        bgeu  x4, x1, B11
        nop
        nop
        nop
        addi x29, x0, 1
        nop
        nop
        nop
B11:

# ===== Acumula os 12 branches em x31 =====
        nop
        nop
        nop
        and  x31, x31, x18
        nop
        nop
        nop
        and  x31, x31, x19
        nop
        nop
        nop
        and  x31, x31, x20
        nop
        nop
        nop
        and  x31, x31, x21
        nop
        nop
        nop
        and  x31, x31, x22
        nop
        nop
        nop
        and  x31, x31, x23
        nop
        nop
        nop
        and  x31, x31, x24
        nop
        nop
        nop
        and  x31, x31, x25
        nop
        nop
        nop
        and  x31, x31, x26
        nop
        nop
        nop
        and  x31, x31, x27
        nop
        nop
        nop
        and  x31, x31, x28
        nop
        nop
        nop
        and  x31, x31, x29
        nop
        nop
        nop

# ===== FIM: x31 = 1 sse TUDO passou =====
        nop
        nop
        nop
        nop
        nop
        nop
        halt
