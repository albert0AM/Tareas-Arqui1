.global _start

.bss
str: .skip 27

.text
_start:
    ldr x0, =str
    mov x1, #26
    mov x2, #'a'

loop:
    strb w2, [x0]
    add x2, x2, #1
    sub x1, x1, #1
    add x0, x0, #1
    cbnz x1, loop

    mov x2, #10
    strb w2, [x0]

    mov x0, #1
    ldr x1, =str
    mov x2, #27
    mov x8, #64
    svc #0

    mov x0, #0
    mov x8, #93
    svc #0
    