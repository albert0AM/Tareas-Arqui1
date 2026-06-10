.global _start

_start:
    mov x0, #15
    mov x1, #10
    mov x2, #20
    mov x3, #20

    cmp x0,x1
    cset x4,gt

    cmp x0,x2
    cset x5,lt

    cmp x0,x3
    cset x6,ne

    and x0, x4, x5
    and x0, x0, x6

    mov x8, #93
    svc #0
