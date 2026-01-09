.text
.globl main
main:
    # --- CARGAR N (tamaño serie) ---
    auipc x2, 0
    addi  x2, x2, 260    # Offset para buscar .data
    lw    x1, 0(x2)      # x1 = N
    nop                  # [Riesgo Load-Use] Esperar dato
    nop
    nop

    # --- CARGAR DIRECCIÓN ARRAY FIBS ---
    auipc x2, 0
    addi  x2, x2, 240    # Offset al array
    addi  x3, x0, 0      # x3 = i = 0

    # --- CHECK INICIAL (Si N < 1 terminar) ---
    slti  x9, x1, 1
    nop                  # [Riesgo Datos] x9 calculado
    nop
    nop
    bne   x9, x0, END
    nop                  # [Riesgo Control]
    nop
    nop

    # --- FIBS[0] = 0 ---
    andi  x4, x0, 0      # x4 = 0
    sw    x4, 0(x2)      # Guardar 0
    
    # IMPORTANTE: Aquí fallaba antes.
    addi  x3, x3, 1      # i = 1
    nop                  # Espera 1
    nop                  # Espera 2
    nop                  # Espera 3 (Dato listo)

    # --- CHECK (Si i == N terminar) ---
    xor   x10, x3, x1    # Comparar i con N
    nop                  # [Riesgo Datos]
    nop
    nop
    beq   x10, x0, END
    nop                  # [Riesgo Control]
    nop
    nop

    # --- FIBS[1] = 1 ---
    ori   x5, x0, 1
    sw    x5, 4(x2)
    
    addi  x3, x3, 1      # i = 2
    nop                  # [Riesgo Datos]
    nop
    nop

    # --- PREPARAR BUCLE ---
    add   x4, x0, x0     # f[i-2] = 0
    add   x5, x0, x5     # f[i-1] = 1

LOOP:
    # --- CHECK LOOP (Si N < i terminar) ---
    sltu  x9, x1, x3
    nop                  # [Riesgo Datos]
    nop
    nop
    bne   x9, x0, END
    nop                  # [Riesgo Control]
    nop
    nop

    # --- CÁLCULO FIBONACCI ---
    add   x6, x4, x5     # f[i] = f[i-2] + f[i-1]
    nop                  # [Riesgo Datos]
    nop
    nop

    # --- CÁLCULO DIRECCIÓN MEMORIA ---
    slli  x7, x3, 2      # offset = i * 4
    nop
    nop
    nop
    add   x8, x2, x7     # Dir destino
    nop
    nop
    nop
    sw    x6, 0(x8)      # Guardar f[i]

    # --- ACTUALIZAR VARIABLES ---
    or    x4, x0, x5     # Nuevo f[i-2]
    and   x5, x6, x6     # Nuevo f[i-1]

    # --- INCREMENTAR i ---
    addi  x3, x3, 1
    
    # --- SALTO ---
    j     LOOP
    nop                  # [Riesgo Control]
    nop
    nop

END:
    j     END
    nop
    nop                  # Relleno final

.data
N: .word 10
fibs: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
