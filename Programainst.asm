.data
input:      .word 0        # valor que pondrá el testbench
shift_val:  .word 0        # cantidad de desplazamiento

result1:    .word 0        # resultado SRLI
result2:    .word 0        # resultado SRAI
result3:    .word 0        # resultado SRL
result4:    .word 0        # resultado SRA
result5:    .word 0        # resultado SUB
result6:    .word 0        # resultado SLTIU
result7:    .word 0        # resultado LUI

.text
.globl _start
_start:

la   x5, input          # x5 = dirección de input
lw   x6, 0(x5)          # x6 = cargar valor de input

la   x5, shift_val      # x5 = dirección de shift_val
lw   x9, 0(x5)          # x9 = cargar valor de shift_val

srli x7, x6, 1          # result1 = input >> 1 lógico (pone ceros a la izquierda)
la   x5, result1
sw   x7, 0(x5)          # guardar resultado SRLI en memoria

srai x7, x6, 1          # result2 = input >> 1 aritmético (mantiene signo)
la   x5, result2
sw   x7, 0(x5)          # guardar resultado SRAI

srl  x7, x6, x9         # result3 = input >> shift_val lógico (pone ceros a la izquierda)
la   x5, result3
sw   x7, 0(x5)          # guardar resultado SRL

sra  x7, x6, x9         # result4 = input >> shift_val aritmético (mantiene signo)
la   x5, result4
sw   x7, 0(x5)          # guardar resultado SRA

sub  x7, x6, x9         # result5 = input - shift_val (resta)
la   x5, result5
sw   x7, 0(x5)          # guardar resultado SUB

sltiu x7, x6, 128       # result6 = 1 si input < 128 (unsigned), 0 si >= 128
la   x5, result6
sw   x7, 0(x5)          # guardar resultado SLTIU

lui  x7, 0xABCDE        # result7 = 0xABCDE000 (carga 20 bits más significativos)
la   x5, result7
sw   x7, 0(x5)          # guardar resultado LUI

addi x10, x0, 10        # código de salida 10 para ecall
ecall                   # terminar programa