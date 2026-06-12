.global _start

.bss
buffer: .skip 2        // reserve 2 bytes

.text
_start:
do:                    // do
    mov x0, #0         // stdin read
    ldr x1, =buffer
    mov x2, #2
    mov x8, #63
    svc #0

    ldr x3, =buffer    // x3 = buffer address
    ldrb w4, [x3]      // w4 = buffer content
    sub w4, w4, #48    // w4 = ascii conversion

while:
    cbnz w4, do        // while w4 != 0

end:                   // exit
    mov x8, #93
    svc #0
    