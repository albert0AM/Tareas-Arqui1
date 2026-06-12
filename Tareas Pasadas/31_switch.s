.global _start

.bss
buffer: .skip 2

.text
_start:
    mov x0, #3          // number to test}
    ldr x1, =buffer // address of buffer

switch:
    cmp x0, #1
    b.eq case1

    cmp x0, #2
    b.eq case2

    cmp x0, #3
    b.eq case3

    b end

case1:
    mov x0, #49         // ASCII code for '1'
    strb w0, [x1]

case2:
    mov x0, #50         // ASCII code for '2'
    strb w0, [x1]
    b end

case3:
    mov x0, #51         // ASCII code for '3'
    strb w0, [x1]

end:
    add x1, x1, #1     // move to the next byte in the buffer
    mov x2, #10
    strb w2, [x1]    

    mov x0, #1
    ldr x1, =buffer
    mov x2, #2
    mov x8, #64
    svc 0

    mov x0, #0           // exit
    mov x8, #93
    svc #0


