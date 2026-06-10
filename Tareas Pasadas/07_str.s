.global _start

.data
a: .word 10

.bss
b: .space 8

.text
_start:

ldr x1, =a
ldr x2, [x1]
ldr x3, =b
str x2, [x3]
ldr x0, [x3]

mov x8, #93
svc #0
