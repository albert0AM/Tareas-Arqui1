.global _start

.data
odd:  .asciz "The number is odd\n"
even: .asciz "The number is even\n"

.text
_start:
    mov x0, #15          // test number

if:
    ands x0, x0, #1      // (15 && 1) = 1, then z = 0
    b.eq else            // if (z == 1) branch else

    mov x0, #1           // the number is odd
    ldr x1, =odd
    mov x2, #18
    mov x8, #64
    svc #0
    b endif

else:                    // the number is even
    mov x0, #1
    ldr x1, =even
    mov x2, #19
    mov x8, #64
    svc #0

endif:
    mov x0, #0           // exit
    mov x8, #93
    svc #0
    