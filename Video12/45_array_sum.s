.global _start
.extern itoa

.data
array: .word 15, 48, 99, 56, 22, 34, 57, 19, 35, 61

.bss
buffer: .skip 11

.text
_start:
    ldr x3, =array          // load array address
    mov x4, #10             // decrement counter
    mov x5, #0              // sum result

loop:
    cbz x4, end             // if counter == 0, branch to end
    ldr w6, [x3], #4        // increment offset 4 bytes
    add x5, x5, x6          // sum += num
    subs x4, x4, #1         // counter--
    b loop

end:
    mov x0, x5              // itoa argument: number
    ldr x1, =buffer         // itoa argument: address buffer
    bl itoa                 // branch and link itoa(x0, x1)

    mov x0, #1              // print buffer
    ldr x1, =buffer
    mov x2, #11
    mov x8, #64
    svc #0

    mov x8, #93             // exit
    svc #0