.global _start

.data
a: .word 1, 2, 3

.text
_start:


ldr x1, =a
mov x2, #8
ldr x0, [x1, x2]

mov x8, #93
svc #0
