.global _start

_start:

mov x1, #07400
lsr x0, x1, #04

mov x8, #93
svc #0

