
.global _start

.data
fact: .double 1.8
cons: .double 32
test: .double 57

.text
_start:
    ldr x1, =fact           // load factor, constant and celsius degree
    ldr d1, [x1]
    ldr x2, =cons
    ldr d2, [x2]
    ldr x3, =test
    ldr d3, [x3]

    fmul d0, d1, d3         // fahrenheit = (celsius * 1.8) + 32
    fadd d0, d0, d2
    fcvtzs x0, d0

    mov x8, #93             // exit
    svc #0
    