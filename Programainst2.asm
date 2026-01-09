.data
input:      .word 0        # valor que pondrá el testbench
compare_val:.word 0        # valor de comparacion configurable
result1:    .word 0        # resultado de JAL
result2:    .word 0        # resultado de JALR
result3:    .word 0        # resultado de BLT
result4:    .word 0        # resultado de BLTU
result5:    .word 0        # resultado de BGE
result6:    .word 0        # resultado de BGEU

.text
.globl main
main:

    # Cargamos valores
    la x1, input           # guardo en direccion x1 mi input
    lw x1, 0(x1)           # traspaso el valor
    nop
    nop                    # evita hazard load-use

    la x2, compare_val     # guardo en direccion x2 mi valor de comparacion
    lw x2, 0(x2)           # traspaso el valor
    nop
    nop

    # USO DE JAL
    jal func_jal           # salta a func_jal
    nop
    nop                    # vaciado de pipeline por salto

    # USO DE JALR
    la x3, func_jalr       # llama a func_jalr que calcula input+compare_val y lo guarda en result2
    nop
    nop                    # x3 debe estar listo antes de jalr
    jalr x3                # salta a func_jalr
    nop
    nop

    # USO DE BLT
    la x3, result3
    sw x0, 0(x3)           # inicia en 0
    nop

    blt x1, x2, blt_true   # si input < compare_val salta
    nop
    nop
    j blt_end              # si no se cumple, evita ejecutar el true
    nop

blt_true:
    li x4, 1
    nop
    sw x4, 0(x3)           # si se cumple escribe 1 en result3

blt_end:

    # USO DE BLTU
    la x3, result4
    sw x0, 0(x3)           # inicia en 0
    nop

    bltu x1, x2, bltu_true # igual que blt pero unsigned
    nop
    nop
    j bltu_end
    nop

bltu_true:
    li x4, 1
    nop
    sw x4, 0(x3)           # si se cumple escribe 1 en result4

bltu_end:

    # USO DE BGE
    la x3, result5
    sw x0, 0(x3)
    nop

    bge x1, x2, bge_true   # si input >= compare_val salta
    nop
    nop
    j bge_end
    nop

bge_true:
    li x4, 1
    nop
    sw x4, 0(x3)           # si se cumple escribe 1 en result5

bge_end:

    # USO DE BGEU
    la x3, result6
    sw x0, 0(x3)
    nop

    bgeu x1, x2, bgeu_true # igual que bge pero unsigned
    nop
    nop
    j bgeu_end
    nop

bgeu_true:
    li x4, 1
    nop
    sw x4, 0(x3)           # si se cumple escribe 1 en result6

bgeu_end:

end:
    j end
    nop
    nop


# ---------------- FUNCION JAL ----------------
func_jal:
    add x4, x1, x2         # guarda en x4 input + compare_val
    nop
    la x5, result1
    sw x4, 0(x5)           # guarda en result1
    nop
    nop
    jalr x0, x1, 0         # vuelve al main
    nop
    nop


# ---------------- FUNCION JALR ----------------
func_jalr:
    add x4, x1, x2         # guarda en x4 input + compare_val
    nop
    la x5, result2
    sw x4, 0(x5)           # guarda en result2
    nop
    nop
    jalr x0, x1, 0         # vuelve al main
    nop
    nop

