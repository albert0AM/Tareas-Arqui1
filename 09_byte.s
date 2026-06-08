.global _start

.data
a: .byte 0

.text
_start:

ldr x1, =a
mov x2, #10
strb w2, [x1]
ldr x0, [x1]

mov x8, #93
svc #0
