.text
.globl main
main:

    # Cargar dirección de N con AUIPC+ADDI
    auipc x2, 0 #genera la base
    addi  x2, x2, 12 #offset de 12(contando los bytes desde auipc hasta .data)
    lw    x1, 0(x2)          # x1 = N

    # Cargar dirección de fibs
    auipc x2, 0
    addi  x2, x2, 16 #offset de 16. x2 apunta al inicio 

    addi x3, x0, 0           # i = 0

    # Si N < 1 → END
    slti x9, x1, 1
    bne  x9, x0, END #compara x9(0 o 1) con 0

    # fibs[0] = 0
    andi x4, x0, 0 #f[0]=0
    sw   x4, 0(x2) #guarda 0 en fibs
    addi x3, x3, 1 #incrementa i a 1

    # Si i == N → END
    xor  x10, x3, x1 #compara si i=N
    beq  x10, x0, END #si lo es salta a end

    # fibs[1] = 1
    ori  x5, x0, 1 
    sw   x5, 4(x2) #se guarda 1 en fibs[1]
    addi x3, x3, 1 #incrementamos a 2
    
	#inicializamos f[i-2] y f[i-1]
    add x4, x0, x0 # x4 = f[i-2] = 0
    add x5, x0, x5 # x5 = f[i-1] = 1
    

LOOP:
    # Si N < i → END
    sltu x9, x1, x3 #compara i> N
    bne  x9, x0, END #si es asi salta a end

    # f[i] = f[i-2] + f[i-1]
    add  x6, x4, x5

    # offset = i*4
    slli x7, x3, 2
    add  x8, x2, x7 #dirección donde guardar f[i]
    sw   x6, 0(x8) #guarda en memoria

    # actualizar f[i-2] y f[i-1]
    or   x4, x0, x5
    and  x5, x6, x6

	#incrementar i
    addi x3, x3, 1
    j LOOP

END:
    j END


.data

N: .word 10

# Espacio para 100 enteros = 400 bytes
fibs:
    .word 0 0 0 0 0 0 0 0 0 0
    .word 0 0 0 0 0 0 0 0 0 0
    .word 0 0 0 0 0 0 0 0 0 0
    .word 0 0 0 0 0 0 0 0 0 0
    .word 0 0 0 0 0 0 0 0 0 0
    .word 0 0 0 0 0 0 0 0 0 0
    .word 0 0 0 0 0 0 0 0 0 0
    .word 0 0 0 0 0 0 0 0 0 0
    .word 0 0 0 0 0 0 0 0 0 0
    .word 0 0 0 0 0 0 0 0 0 0
