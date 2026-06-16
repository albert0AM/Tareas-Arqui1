.global _start

.bss
pattern: .skip 36

.text
_start:
    ldr x0, =pattern
    mov x1, #'5'
    mov x2, #'1'

loop1:
    cmp x2, x1
    bgt endloop1
    mov x3, #'1'

loop2:
    cmp x3, x2
    bgt endloop2
    strb w3, [x0]
    add x0, x0, #1
    mov x4, #' '
    strb w4, [x0]
    add x0, x0, #1
    add x3, x3, #1
    b loop2

endloop2:
    add x2, x2, #1
    mov x4, #10
    strb w4, [x0]
    add x0, x0, #1
    b loop1

endloop1:
    strb wzr, [x0]

    mov x0, #1
    ldr x1, =pattern
    mov x2, #36
    mov x8, #64
    svc #0

    mov x0, #0
    mov x8, #93
    svc #0
    