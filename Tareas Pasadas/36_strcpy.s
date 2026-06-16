.global _start

.data
string1: .string "Hello, World!\n"

.bss
string2: .skip 15

.text
_start:
    ldr x0, =string1
    ldr x1, =string2

loop:
    ldrb w2, [x0]
    cbz w2, end
    strb w2, [x1]
    add x0, x0, #1
    add x1, x1, #1
    b loop

end:
    mov x0, #1
    ldr x1, =string2
    mov x2, #15
    mov x8, #64
    svc #0

    mov x0, #0
    mov x8, #93
    svc #0

