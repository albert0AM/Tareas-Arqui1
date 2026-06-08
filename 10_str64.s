.global _start

.data
a: .word 0xFFFFFFFF00000000
b: .word 0xFFFFFFFF

.text
_start:

ldr x1, =a 
ldr x2, =b
ldr x3, [x2]
str x3, [x1]
ldrb w0, [x1]

mov x8, #93
svc #0
