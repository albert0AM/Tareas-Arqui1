.global _start

.data
ptr: .word 0

.text
_start:
    mov x8, #214
    mov x0, #0
    svc #0

    ldr x1, =ptr
    str x0, [x1]

    add x0, x0, #4
    mov x8, #214
    svc #0

    ldr x1, =ptr
    ldr x2, [x1]
    mov x3, #100
    str x3, [x2]

ldr x1, =ptr
ldr x2, [x1]
ldr x0, [x2]
mov x8, #93
svc #0
