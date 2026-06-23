.global _start

.extern factorial
.extern itoa

.data
buffer: .space 11

.text
_start:
    mov x0, #10           // number
    bl factorial          // x0 = factorial(number)

    ldr x1, =buffer       // load buffer
    bl itoa               // buffer = itoa(x0)

    mov x0, #1            // print buffer
    ldr x1, =buffer       //
    mov x2, #11           //
    mov x8, #64           //
    svc #0                //

    mov x8, #93           // exit
    svc #0              //
