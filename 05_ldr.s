.global _start

.data
a: .word 1, 2, 3

.text
_start:

ldr x1, =a
ldr x0, [x1]

mov x8, #93
svc #0
