.global _start

_start:
    mov x0, #0         // initialization
    mov x1, #9
    mov x2, #3

for:                   // for (x1 = 9; x1 >= 0; x1 = x1 - x2)
    cmp x1, #0
    ble end
    add x0, x0, #1     // counter
    sub x1, x1, x2
    b for

end:
    mov x8, #93        // exit
    svc #0
    