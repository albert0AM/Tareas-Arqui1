.global _start

_start:
movz x1, 0xDDCC
movk x1, 0xFFEE, lsl #16
movz x2, 0x00FF
and x0, x1, x2

mov x8, #93
svc #0
