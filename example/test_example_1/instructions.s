addi x1, x0, 5
add x2, x0, x1
add x3, x0, x0
add x3, x3, x2
addi x2, x2, -1
bne x2, x0, -8
jal x1, 4
sw x3, 4(x0)