.global _start

_start:
    mov x0, #10
    mov x1, #15


if:
    cmp x0, x1
    b.lt endif
    add x0, x0, x1

endif:
    mov x8, #93
    svc #0

