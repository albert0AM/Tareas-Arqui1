.global _start

.data
dword1: .dword 0x00FFFFFFFFFFFFFF
dword2: .dword 0x000000FF00000001

.text
_start:
    ldr x1, =dword1      // x1 = &dword1
    ldr x2, [x1]         // x2 = *dword1
    ldr x3, =dword2      // x3 = &dword2
    ldr x4, [x3]         // x4 = *dword2
    mul w0, w2, w4       // w0 = Lo:dword1 * Lo:dword2 (32-bit limited)

    mov x8, #93
    svc #0
