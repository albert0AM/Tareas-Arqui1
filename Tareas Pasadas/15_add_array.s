.global _start

.data
a: .word -1, -2, -3

.text
_start:

ldr x0, =a
ldr x1, [x0]
ldr x2, [x0, #4]
ldr x3, [x0, #8]

add x0, x1, x2
add x0, x0, x3
neg x0, x0

mov x8, #93
svc #0 
