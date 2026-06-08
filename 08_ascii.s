.global _start

.data
a: .word 0
s: .string "hola"

.text
_start:

ldr x1, =s
ldr x2, [x1, #3]
ldr x3, =a
strb w2, [x3]
ldr x0, [x3]

mov x8, #93
svc #0
