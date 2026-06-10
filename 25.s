.global _start

_start:
    mov x0, #15
    mov x1, #10
    mov x2, #20

    cmp x0,x1
    cset x3,gt

    cmp x0,x2
    cset x4,lt

    and x0, x3, x4

    mov x8, #93
    svc #0
