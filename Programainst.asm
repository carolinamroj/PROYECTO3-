.data
input:      .word 0
shift_val:  .word 0

result1:    .word 0
result2:    .word 0
result3:    .word 0
result4:    .word 0
result5:    .word 0
result6:    .word 0
result7:    .word 0

.text
.globl _start
_start:

la   x5, input
lw   x6, 0(x5)

la   x5, shift_val
lw   x9, 0(x5)

srli x7, x6, 1
la   x5, result1
sw   x7, 0(x5)

srai x7, x6, 1
la   x5, result2
sw   x7, 0(x5)

srl  x7, x6, x9
la   x5, result3
sw   x7, 0(x5)

sra  x7, x6, x9
la   x5, result4
sw   x7, 0(x5)

sub  x7, x6, x9
la   x5, result5
sw   x7, 0(x5)

sltiu x7, x6, 128
la   x5, result6
sw   x7, 0(x5)

lui  x7, 0xABCDE
la   x5, result7
sw   x7, 0(x5)

end_loop:
    j end_loop          # Salta incondicionalmente a la etiqueta 'end_loop'
