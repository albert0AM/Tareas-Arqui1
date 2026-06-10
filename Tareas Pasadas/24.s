.global _start

_start:
    mov x1, #10
    mov x2, #20

    cmp x1, x2
    mrs x0, nzcv
    lsr x0, x0, #28

    mov x8, #93
    svc #0
    