.global _start
.extern itoa

.data
head:   .dword 0

.bss
buffer: .space 11

.text
_start:
    mov x0, #30
    ldr x1, =head
    ldr x1, [x1]
    bl push

    mov x0, #20
    ldr x1, =head
    ldr x1, [x1]
    bl push

    mov x0, #10
    ldr x1, =head
    ldr x1, [x1]
    bl push

    ldr x0, =head
    ldr x0, [x0]
    bl print

    mov x8, #93
    svc #0

push:
    mov x10, x0
    mov x11, x1

    mov x8, #214
    svc #0
    mov x12, x0

    add x0, x0, #16
    mov x8, #214
    svc #0

    str x10, [x12]
    str x11, [x12, #8]

    ldr x13, =head
    str x12, [x13]
    ret

print:
    stp lr, fp, [sp, #-16]!
    mov fp, sp
    mov x21, x0

loop:
    cbz x21, end

    ldr x0, [x21]
    ldr x1, =buffer
    bl itoa

    mov x0, #1
    ldr x1, =buffer
    mov x2, #11
    mov x8, #64
    svc #0

    ldr x21, [x21, #8]
    b loop

end:
    ldp lr, fp, [sp], #16
    ret
    